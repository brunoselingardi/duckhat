import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/agendamento.dart';
import '../models/avaliacao.dart';
import '../models/chat_conversa.dart';
import '../models/chat_mensagem.dart';
import '../models/catalogo_prestador_busca.dart';
import '../models/disponibilidade_catalogo.dart';
import '../models/estabelecimento_catalogo.dart';
import '../models/estabelecimento_publico.dart';
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
        categoria: tipo == 'PRESTADOR' ? 'barbearia' : null,
        categoriaLabel: tipo == 'PRESTADOR' ? 'Barbearia' : null,
        descricao: tipo == 'PRESTADOR'
            ? 'Perfil de desenvolvimento do estabelecimento.'
            : null,
        horarioAtendimento: tipo == 'PRESTADOR'
            ? 'Segunda a sexta 9h - 20h'
            : null,
        bannerImagemBase64: null,
        fotoPerfilBase64: null,
        tipo: tipo,
        token: _token!,
      ),
    );
  }

  void clearSession() {
    _devMode = false;
    _token = null;
    ApiConfig.resetResolvedBaseUrl();
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
    if (_devMode) {
      final session = _session;
      if (session == null) {
        throw Exception('Sessão de desenvolvimento não iniciada.');
      }
      return _perfilFromSession(session);
    }

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
    if (_devMode) {
      _mergePerfilIntoSession(perfil);
      final session = _session;
      if (session == null) {
        throw Exception('Sessão de desenvolvimento não iniciada.');
      }
      return _perfilFromSession(session);
    }

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
    String? categoria,
  }) async {
    final response = await _postPublicJson('/api/usuarios', {
      'nome': nome.trim(),
      'email': email.trim().toLowerCase(),
      'senha': senha,
      'telefone': telefone.trim(),
      'cnpj': _nullableTrim(cnpj),
      'responsavelNome': _nullableTrim(responsavelNome),
      'categoria': _nullableTrim(categoria),
      'tipo': tipo,
    });

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
    final response = await _postPublicJson(
      '/api/auth/recuperar-senha/solicitar',
      {'email': email.trim().toLowerCase()},
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
    final response =
        await _postPublicJson('/api/auth/recuperar-senha/redefinir', {
          'email': email.trim().toLowerCase(),
          'codigo': codigo.trim(),
          'novaSenha': novaSenha,
        });

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
    final response = await _postPublicJson('/api/auth/login', {
      'email': email.trim(),
      'senha': password,
    });

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
      categoria: body['categoria'] as String?,
      categoriaLabel: body['categoriaLabel'] as String?,
      descricao: body['descricao'] as String?,
      horarioAtendimento: body['horarioAtendimento'] as String?,
      bannerImagemBase64: body['bannerImagemBase64'] as String?,
      fotoPerfilBase64: body['fotoPerfilBase64'] as String?,
      tipo: body['tipo'] as String? ?? '',
      token: token,
    );
  }

  Future<List<ServicoCatalogo>> listarMeusServicos() async {
    if (_devMode) {
      return [
        ServicoCatalogo(
          id: 1,
          prestadorId: _session?.id ?? 9002,
          nome: 'Corte de cabelo',
          descricao: 'Servico de exemplo para ajustar a vitrine.',
          duracaoMin: 30,
          preco: 35,
          ativo: true,
        ),
        ServicoCatalogo(
          id: 2,
          prestadorId: _session?.id ?? 9002,
          nome: 'Barba',
          descricao: 'Acabamento e desenho de barba.',
          duracaoMin: 25,
          preco: 28,
          ativo: true,
        ),
      ];
    }

    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/servicos'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar seus serviços.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar seus serviços.');
    }

    return body
        .map(
          (item) =>
              ServicoCatalogo.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  Future<ServicoCatalogo> criarServico({
    required String nome,
    required String descricao,
    required int duracaoMin,
    required double preco,
    required bool ativo,
  }) async {
    if (_devMode) {
      return ServicoCatalogo(
        id: DateTime.now().microsecondsSinceEpoch,
        prestadorId: _session?.id ?? 9002,
        nome: nome.trim(),
        descricao: _nullableTrim(descricao),
        duracaoMin: duracaoMin,
        preco: preco,
        ativo: ativo,
      );
    }

    await ensureAuthenticated();

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/servicos'),
      headers: _authorizedHeaders(),
      body: jsonEncode(
        _servicoPayload(
          nome: nome,
          descricao: descricao,
          duracaoMin: duracaoMin,
          preco: preco,
          ativo: ativo,
        ),
      ),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível criar o serviço.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao criar serviço.');
    }

    return ServicoCatalogo.fromJson(body);
  }

  Future<ServicoCatalogo> atualizarServico({
    required int id,
    required String nome,
    required String descricao,
    required int duracaoMin,
    required double preco,
    required bool ativo,
  }) async {
    if (_devMode) {
      return ServicoCatalogo(
        id: id,
        prestadorId: _session?.id ?? 9002,
        nome: nome.trim(),
        descricao: _nullableTrim(descricao),
        duracaoMin: duracaoMin,
        preco: preco,
        ativo: ativo,
      );
    }

    await ensureAuthenticated();

    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/servicos/$id'),
      headers: _authorizedHeaders(),
      body: jsonEncode(
        _servicoPayload(
          nome: nome,
          descricao: descricao,
          duracaoMin: duracaoMin,
          preco: preco,
          ativo: ativo,
        ),
      ),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível salvar o serviço.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao salvar serviço.');
    }

    return ServicoCatalogo.fromJson(body);
  }

  Future<void> criarDisponibilidade({
    required int diaSemana,
    required String horaInicio,
    required String horaFim,
    bool ativo = true,
  }) async {
    if (_devMode) return;

    await ensureAuthenticated();

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/disponibilidades'),
      headers: _authorizedHeaders(),
      body: jsonEncode({
        'diaSemana': diaSemana,
        'horaInicio': horaInicio,
        'horaFim': horaFim,
        'ativo': ativo,
      }),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível criar disponibilidade.',
      );
    }
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

  Future<EstabelecimentoPublico> carregarEstabelecimentoPublico(
    int prestadorId,
  ) async {
    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/catalogo/prestadores/$prestadorId'),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível carregar o estabelecimento público.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao carregar estabelecimento.');
    }

    return EstabelecimentoPublico.fromJson(body);
  }

  Future<List<EstabelecimentoCatalogo>> listarEstabelecimentosCatalogo({
    String? termo,
  }) async {
    final normalized = termo?.trim();
    final uri = normalized == null || normalized.isEmpty
        ? Uri.parse('${ApiConfig.baseUrl}/api/catalogo/estabelecimentos')
        : Uri.parse(
            '${ApiConfig.baseUrl}/api/catalogo/estabelecimentos/busca',
          ).replace(queryParameters: {'termo': normalized});

    final response = await _client.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível carregar os estabelecimentos.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar estabelecimentos.');
    }

    return body
        .map(
          (item) => EstabelecimentoCatalogo.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<List<Avaliacao>> listarAvaliacoesPublicasPorPrestador(
    int prestadorId,
  ) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/catalogo/prestadores/$prestadorId/avaliacoes',
      ),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar as avaliações.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar avaliações.');
    }

    return body
        .map((item) => Avaliacao.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<List<CatalogoPrestadorBusca>> buscarPrestadoresCatalogo(
    String nome,
  ) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/catalogo/prestadores/busca?nome=${Uri.encodeQueryComponent(nome)}',
      ),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar o catálogo.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao buscar catálogo.');
    }

    return body
        .map(
          (item) => CatalogoPrestadorBusca.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();
  }

  Future<EstabelecimentoCatalogo> buscarEstabelecimentoCatalogo(
    int prestadorId,
  ) async {
    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/catalogo/estabelecimentos/$prestadorId',
      ),
      headers: {'Accept': 'application/json'},
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar o estabelecimento.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao carregar estabelecimento.');
    }

    return EstabelecimentoCatalogo.fromJson(body);
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

  Future<Avaliacao?> buscarAvaliacaoPorAgendamento(int agendamentoId) async {
    if (_devMode) return null;

    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse(
        '${ApiConfig.baseUrl}/api/avaliacoes/agendamento/$agendamentoId',
      ),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar a avaliação.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao carregar avaliação.');
    }

    return Avaliacao.fromJson(body);
  }

  Future<List<Avaliacao>> listarAvaliacoes() async {
    if (_devMode) {
      return const [];
    }

    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/avaliacoes'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível carregar as avaliações.',
      );
    }

    if (body is! List) {
      throw Exception('Resposta inválida ao listar avaliações.');
    }

    return body
        .map((item) => Avaliacao.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  Future<Avaliacao> criarAvaliacao({
    int? prestadorId,
    required int nota,
    String? comentario,
    int? servicoId,
    int? agendamentoId,
  }) async {
    if (_devMode) {
      return Avaliacao(
        id: 0,
        agendamentoId: agendamentoId ?? 0,
        prestadorId: prestadorId,
        servicoId: servicoId,
        nota: nota,
        comentario: _nullableTrim(comentario),
        criadoEm: DateTime.now(),
      );
    }

    await ensureAuthenticated();

    if (agendamentoId == null) {
      throw Exception('Para avaliar, abra um agendamento concluído.');
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/avaliacoes'),
      headers: _authorizedHeaders(),
      body: jsonEncode({
        'agendamentoId': agendamentoId,
        'nota': nota,
        'comentario': _nullableTrim(comentario),
      }),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 201) {
      throw Exception(
        _extractMessage(body) ?? 'Não foi possível enviar a avaliação.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao enviar avaliação.');
    }

    return Avaliacao.fromJson(body);
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

    final agendamento = Agendamento.fromJson(body);
    _emitAgendamentoSync(focusDate: agendamento.inicioEm);
    return agendamento;
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

    final agendamento = Agendamento.fromJson(body);
    _emitAgendamentoSync(focusDate: agendamento.inicioEm);
    return agendamento;
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

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível marcar as notificações como lidas.',
      );
    }
  }

  Future<NotificacaoPreferencias> carregarPreferenciasNotificacoes() async {
    await ensureAuthenticated();

    final response = await _client.get(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes/preferencias'),
      headers: _authorizedHeaders(),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível carregar as preferências de notificações.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao carregar preferências.');
    }

    return NotificacaoPreferencias.fromJson(body);
  }

  Future<NotificacaoPreferencias> atualizarPreferenciasNotificacoes(
    NotificacaoPreferencias preferencias,
  ) async {
    await ensureAuthenticated();

    final response = await _client.put(
      Uri.parse('${ApiConfig.baseUrl}/api/notificacoes/preferencias'),
      headers: _authorizedHeaders(),
      body: jsonEncode(preferencias.toJson()),
    );

    final body = _decodeBody(response);

    if (response.statusCode != 200) {
      throw Exception(
        _extractMessage(body) ??
            'Não foi possível salvar as preferências de notificações.',
      );
    }

    if (body is! Map<String, dynamic>) {
      throw Exception('Resposta inválida ao salvar preferências.');
    }

    return NotificacaoPreferencias.fromJson(body);
  }

  void _setSession(LoginSession? session) {
    _session = session;
    sessionNotifier.value = session;
  }

  void _mergePerfilIntoSession(UsuarioPerfil perfil) {
    final session = _session;
    if (session == null) return;

    _setSession(
      session.copyWith(
        id: perfil.id,
        nome: perfil.nome,
        email: perfil.email,
        telefone: perfil.telefone,
        cnpj: perfil.cnpj,
        responsavelNome: perfil.responsavelNome,
        dataNascimento: perfil.dataNascimento,
        endereco: perfil.endereco,
        categoria: perfil.categoria,
        categoriaLabel: perfil.categoriaLabel,
        descricao: perfil.descricao,
        horarioAtendimento: perfil.horarioAtendimento,
        bannerImagemBase64: perfil.bannerImagemBase64,
        fotoPerfilBase64: perfil.fotoPerfilBase64,
        tipo: perfil.tipo,
      ),
    );
  }

  UsuarioPerfil _perfilFromSession(LoginSession session) {
    return UsuarioPerfil(
      id: session.id,
      nome: session.nome,
      email: session.email,
      telefone: session.telefone,
      cnpj: session.cnpj,
      responsavelNome: session.responsavelNome,
      dataNascimento: session.dataNascimento,
      endereco: session.endereco,
      categoria: session.categoria,
      categoriaLabel: session.categoriaLabel,
      descricao: session.descricao,
      horarioAtendimento: session.horarioAtendimento,
      bannerImagemBase64: session.bannerImagemBase64,
      fotoPerfilBase64: session.fotoPerfilBase64,
      tipo: session.tipo,
    );
  }

  Map<String, dynamic> _servicoPayload({
    required String nome,
    required String descricao,
    required int duracaoMin,
    required double preco,
    required bool ativo,
  }) {
    return {
      'nome': nome.trim(),
      'descricao': _nullableTrim(descricao),
      'duracaoMin': duracaoMin,
      'preco': preco,
      'ativo': ativo,
    };
  }

  Map<String, String> _authorizedHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_token',
    };
  }

  Map<String, String> _jsonHeaders() {
    return {'Content-Type': 'application/json', 'Accept': 'application/json'};
  }

  Future<http.Response> _postPublicJson(
    String path,
    Map<String, dynamic> payload,
  ) async {
    Object? lastError;
    for (final baseUrl in ApiConfig.baseUrlCandidates) {
      try {
        final response = await _client
            .post(
              Uri.parse('$baseUrl$path'),
              headers: _jsonHeaders(),
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 8));
        ApiConfig.useBaseUrl(baseUrl);
        return response;
      } catch (error) {
        lastError = error;
      }
    }

    final tested = ApiConfig.baseUrlCandidates.join(', ');
    throw Exception(
      'Não foi possível conectar à API. Endereços testados: $tested. '
      'Confirme se o Spring Boot está rodando em 8081. No celular físico, '
      'autorize a depuração USB e rode: adb reverse tcp:8081 tcp:8081.'
      '${lastError == null ? '' : ' Erro: ${lastError.runtimeType}.'}',
    );
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
  final String? categoria;
  final String? categoriaLabel;
  final String? descricao;
  final String? horarioAtendimento;
  final String? bannerImagemBase64;
  final String? fotoPerfilBase64;
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
    required this.categoria,
    required this.categoriaLabel,
    required this.descricao,
    required this.horarioAtendimento,
    required this.bannerImagemBase64,
    required this.fotoPerfilBase64,
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
    String? categoria,
    String? categoriaLabel,
    String? descricao,
    String? horarioAtendimento,
    String? bannerImagemBase64,
    String? fotoPerfilBase64,
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
      categoria: categoria,
      categoriaLabel: categoriaLabel,
      descricao: descricao,
      horarioAtendimento: horarioAtendimento,
      bannerImagemBase64: bannerImagemBase64,
      fotoPerfilBase64: fotoPerfilBase64,
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
