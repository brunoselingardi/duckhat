import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/agendamento.dart';
import '../models/chat_conversa.dart';
import '../models/chat_mensagem.dart';
import '../models/avaliacao.dart';
import '../models/disponibilidade_catalogo.dart';
import '../models/notificacao.dart';
import '../models/notificacao_preferencias.dart';
import '../models/ocupacao_prestador.dart';
import '../models/servico_catalogo.dart';
import '../models/usuario_perfil.dart';

class DuckHatApi {
  DuckHatApi._();

  static final DuckHatApi instance = DuckHatApi._();

  final http.Client _client = http.Client();
  final ValueNotifier<AgendamentoSyncSignal> agendamentoSync = ValueNotifier(
    const AgendamentoSyncSignal.initial(),
  );

  String? _token;
  LoginSession? _session;
  bool _devMode = false;
  final ValueNotifier<LoginSession?> sessionNotifier = ValueNotifier(null);

  LoginSession? get currentSession => _session;

  bool get isPrestador => _session?.tipo == 'PRESTADOR';

  bool get isDevMode => _devMode;

  Future<LoginSession> login({
    required String email,
    required String password,
  }) async {
    final session = await _requestSession(email: email, password: password);
    _devMode = false;
    _token = session.token;
    _setSession(session);
    return session;
  }

  void startDevSession({required String tipo}) {
    _devMode = true;
    _token = 'dev-token';
    _setSession(
      LoginSession(
        id: tipo == 'PRESTADOR' ? 9002 : 9001,
        nome: tipo == 'PRESTADOR' ? 'Estabelecimento Dev' : 'Cliente Dev',
        email: tipo == 'PRESTADOR'
            ? 'estabelecimento.dev@duckhat.local'
            : 'cliente.dev@duckhat.local',
        telefone: null,
        cnpj: tipo == 'PRESTADOR' ? '00.000.000/0001-00' : null,
        responsavelNome: tipo == 'PRESTADOR' ? 'Responsável Dev' : null,
        dataNascimento: null,
        endereco: null,
        tipo: tipo,
        token: _token!,
      ),
    );
  }

  void clearSession() {
    _devMode = false;
    _token = null;
    _setSession(null);
  }

  Future<void> ensureAuthenticated() async {
    if (_token != null && _token!.isNotEmpty) return;

    if (ApiConfig.loginEmail.isEmpty || ApiConfig.loginPassword.isEmpty) {
      throw Exception(
        'Defina DUCKHAT_LOGIN_EMAIL e DUCKHAT_LOGIN_PASSWORD via --dart-define.',
      );
    }

    final session = await _requestSession(
      email: ApiConfig.loginEmail,
      password: ApiConfig.loginPassword,
    );
    _token = session.token;
    _setSession(session);
  }

  Future<UsuarioPerfil> carregarMeuPerfil() async {
    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/me'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar o perfil.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao carregar perfil.');
    }

    final perfil = UsuarioPerfil.fromJson(body);
    _mergePerfilIntoSession(perfil);
    return perfil;
  }

  Future<UsuarioPerfil> atualizarMeuPerfil(UsuarioPerfil perfil) async {
    await ensureAuthenticated();

    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/me'),
      headers: _authorizedHeaders(),
      body: jsonEncode(perfil.toUpdateJson()),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível salvar o perfil.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao salvar perfil.');
    }

    final atualizado = UsuarioPerfil.fromJson(body);
    _mergePerfilIntoSession(atualizado);
    return atualizado;
  }

  Future<UsuarioCadastroResponse> criarUsuario({
    required String nome,
    required String email,
    required String senha,
    required String telefone,
    required String tipo,
    String? cnpj,
    String? responsavelNome,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/usuarios'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'nome': nome.trim(),
        'email': email.trim().toLowerCase(),
        'senha': senha,
        'telefone': telefone.trim(),
        'cnpj': _nullableTrim(cnpj),
        'responsavelNome': _nullableTrim(responsavelNome),
        'tipo': tipo,
      }),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível criar a conta.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao criar usuário.');
    }

    return UsuarioCadastroResponse(
      id: _parseInt(body['id']),
      nome: body['nome'] as String? ?? nome.trim(),
      email: body['email'] as String? ?? email.trim().toLowerCase(),
      telefone: body['telefone'] as String?,
      cnpj: body['cnpj'] as String?,
      responsavelNome: body['responsavelNome'] as String?,
      tipo: body['tipo'] as String? ?? tipo,
    );
  }

  Future<SolicitacaoRecuperacaoSenhaResponse> solicitarRecuperacaoSenha({
    required String email,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/recuperar-senha/solicitar'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({'email': email.trim().toLowerCase()}),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível iniciar a recuperação de senha.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao solicitar recuperação.');
    }

    return SolicitacaoRecuperacaoSenhaResponse(
      mensagem: body['mensagem'] as String? ?? 'Código gerado com sucesso.',
      codigoRecuperacao: body['codigoRecuperacao'] as String?,
    );
  }

  Future<void> redefinirSenha({
    required String email,
    required String codigo,
    required String novaSenha,
  }) async {
    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/recuperar-senha/redefinir'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email.trim().toLowerCase(),
        'codigo': codigo.trim(),
        'novaSenha': novaSenha,
      }),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível redefinir a senha.',
      );
    }
  }

  Future<LoginSession> _requestSession({
    required String email,
    required String password,
  }) async {
    final http.Response response;
    try {
      response = await _client
          .post(
            Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email.trim(), 'senha': password}),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      throw Exception(
        'Não foi possível conectar à API em ${ApiConfig.baseUrl}. Verifique se o backend está rodando e se o endereço está correto para o emulador ou dispositivo.',
      );
    }

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(_extractMessage(body) ?? 'Falha ao autenticar na API.');
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta de login inválida.');
    }

    final token = body['token'] as String?;
    if (token == null || token.isEmpty) {
      throw Exception('A API não retornou um token JWT válido.');
    }

    return LoginSession(
      id: _parseInt(body['id']),
      nome: body['nome'] as String? ?? '',
      email: body['email'] as String? ?? email.trim(),
      telefone: body['telefone'] as String?,
      cnpj: body['cnpj'] as String?,
      responsavelNome: body['responsavelNome'] as String?,
      dataNascimento: _parseDate(body['dataNascimento']),
      endereco: body['endereco'] as String?,
      tipo: body['tipo'] as String? ?? '',
      token: token,
    );
  }

  Future<List<Agendamento>> listarAgendamentos() async {
    if (_devMode) return [];

    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/agendamentos'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar os agendamentos.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar agendamentos.');
    }

    return body
        .map(
          (item) =>
              Agendamento.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<Agendamento>> listarAgendamentosPrestador() async {
    if (_devMode) return [];

    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/agendamentos/prestador'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível carregar a agenda do prestador.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar agendamentos do prestador.');
    }

    return body
        .map(
          (item) =>
              Agendamento.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<ServicoCatalogo>> listarServicosAtivos() async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/catalogo/servicos'),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar os serviços.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar serviços.');
    }

    return body
        .map(
          (item) =>
              ServicoCatalogo.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<ServicoCatalogo>> listarServicosPorPrestador(
    int prestadorId,
  ) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/catalogo/servicos/prestador/$prestadorId',
      ),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar os serviços.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar serviços.');
    }

    return body
        .map(
          (item) =>
              ServicoCatalogo.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<List<DisponibilidadeCatalogo>> listarDisponibilidadesPorPrestador(
    int prestadorId,
  ) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/catalogo/disponibilidades/prestador/$prestadorId',
      ),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível carregar os horários disponíveis.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar disponibilidades.');
    }

    return body
        .map(
          (item) => DisponibilidadeCatalogo.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<OcupacaoPrestador>> listarOcupacoesPorPrestador(
    int prestadorId,
  ) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/catalogo/agendamentos/prestador/$prestadorId/ocupados',
      ),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível carregar os horários ocupados.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar horários ocupados.');
    }

    return body
        .map(
          (item) => OcupacaoPrestador.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<Agendamento> criarAgendamento({
    required int servicoId,
    required DateTime inicioEm,
    required DateTime fimEm,
    String? observacoes,
  }) async {
    await ensureAuthenticated();

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/agendamentos'),
      headers: _authorizedHeaders(),
      body: jsonEncode({
        'servicoId': servicoId,
        'inicioEm': inicioEm.toIso8601String(),
        'fimEm': fimEm.toIso8601String(),
        'observacoes': observacoes?.trim().isEmpty == true
            ? null
            : observacoes?.trim(),
      }),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível criar o agendamento.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao criar agendamento.');
    }

    final agendamento = Agendamento.fromJson(body);
    _emitAgendamentoSync(focusDate: agendamento.inicioEm);
    return agendamento;
  }

  Future<Agendamento> cancelarAgendamento(int id) async {
    await ensureAuthenticated();

    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/agendamentos/$id/cancelar'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível cancelar o agendamento.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao cancelar agendamento.');
    }

    final agendamento = Agendamento.fromJson(body);
    _emitAgendamentoSync(focusDate: agendamento.inicioEm);
    return agendamento;
  }

  void _emitAgendamentoSync({DateTime? focusDate}) {
    final current = agendamentoSync.value;
    agendamentoSync.value = AgendamentoSyncSignal(
      revision: current.revision + 1,
      focusDate: focusDate,
    );
  }

  Future<Agendamento> confirmarAgendamento(int id) async {
    await ensureAuthenticated();

    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/agendamentos/$id/confirmar'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível confirmar o agendamento.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao confirmar agendamento.');
    }

    return Agendamento.fromJson(body);
  }

  Future<Agendamento> concluirAgendamento(int id) async {
    await ensureAuthenticated();

    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/agendamentos/$id/concluir'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível concluir o agendamento.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao concluir agendamento.');
    }

    return Agendamento.fromJson(body);
  }

  Future<List<ChatConversa>> listarConversasChat() async {
    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/conversas'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar as conversas.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar conversas.');
    }

    return body
        .map((item) => ChatConversa.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ChatConversa> criarOuBuscarConversaChat(int participanteId) async {
    await ensureAuthenticated();

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/chat/conversas'),
      headers: _authorizedHeaders(),
      body: jsonEncode({'participanteId': participanteId}),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível abrir a conversa.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao abrir conversa.');
    }

    return ChatConversa.fromJson(body);
  }

  Future<List<ChatMensagem>> listarMensagensChat(int conversaId) async {
    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/chat/conversas/$conversaId/mensagens',
      ),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar as mensagens.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar mensagens.');
    }

    return body
        .map((item) => ChatMensagem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<ChatMensagem> enviarMensagemChat({
    required int conversaId,
    required String conteudo,
  }) async {
    await ensureAuthenticated();

    final response = await _client.post(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/chat/conversas/$conversaId/mensagens',
      ),
      headers: _authorizedHeaders(),
      body: jsonEncode({'conteudo': conteudo.trim()}),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível enviar a mensagem.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao enviar mensagem.');
    }

    return ChatMensagem.fromJson(body);
  }

  Future<List<Notificacao>> listarNotificacoes() async {
    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar as notificações.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar notificações.');
    }

    return body
        .map((item) => Notificacao.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<int> contarNotificacoesNaoLidas() async {
    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes/nao-lidas/contagem'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível carregar a contagem de notificações.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao contar notificações.');
    }

    return _parseInt(body['naoLidas'] ?? 0);
  }

  Future<Notificacao> marcarNotificacaoComoLida(int id) async {
    await ensureAuthenticated();

    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes/$id/lida'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível atualizar a notificação.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao marcar notificação como lida.');
    }

    return Notificacao.fromJson(body);
  }

  Future<void> marcarTodasNotificacoesComoLidas() async {
    await ensureAuthenticated();

    final response = await _client.patch(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes/lidas'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível enviar a avaliação.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao criar avaliação.');
    }

    return Avaliacao.fromJson(body);
  }

  Map<String, String> _authorizedHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  dynamic _decodeBody(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    final decoded = utf8.decode(response.bodyBytes);
    if (decoded.trim().isEmpty) return null;
    return jsonDecode(decoded);
  }

  String? _extractMessage(dynamic body) {
    if (body is Map<String, dynamic>) {
      final message = body['message'] ?? body['mensagem'] ?? body['error'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  int _parseInt(dynamic value) =>
      value is int ? value : int.parse(value.toString());

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString();
    if (text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  String? _nullableTrim(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}

class AgendamentoSyncSignal {
  final int revision;
  final DateTime? focusDate;

  const AgendamentoSyncSignal({required this.revision, this.focusDate});

  const AgendamentoSyncSignal.initial() : this(revision: 0);
}

class LoginSession {
  final int id;
  final String nome;
  final String email;
  final String? telefone;
  final String? cnpj;
  final String? responsavelNome;
  final DateTime? dataNascimento;
  final String? endereco;
  final String tipo;
  final String token;

  LoginSession({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cnpj,
    required this.responsavelNome,
    required this.dataNascimento,
    required this.endereco,
    required this.tipo,
    required this.token,
  });

  LoginSession copyWith({
    int? id,
    String? nome,
    String? email,
    String? telefone,
    String? cnpj,
    String? responsavelNome,
    DateTime? dataNascimento,
    String? endereco,
    String? tipo,
    String? token,
  }) {
    return LoginSession(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      email: email ?? this.email,
      telefone: telefone,
      cnpj: cnpj,
      responsavelNome: responsavelNome,
      dataNascimento: dataNascimento,
      endereco: endereco,
      tipo: tipo ?? this.tipo,
      token: token ?? this.token,
    );
  }
}

class UsuarioCadastroResponse {
  final int id;
  final String nome;
  final String email;
  final String? telefone;
  final String? cnpj;
  final String? responsavelNome;
  final String tipo;

  UsuarioCadastroResponse({
    required this.id,
    required this.nome,
    required this.email,
    required this.telefone,
    required this.cnpj,
    required this.responsavelNome,
    required this.tipo,
  });
}

class SolicitacaoRecuperacaoSenhaResponse {
  final String mensagem;
  final String? codigoRecuperacao;

  SolicitacaoRecuperacaoSenhaResponse({
    required this.mensagem,
    required this.codigoRecuperacao,
  });
}
