import 'dart:convert';

import 'package:http/http.dart' as http;

import '../core/api_config.dart';
import '../models/agendamento.dart';
import '../models/disponibilidade_catalogo.dart';
import '../models/ocupacao_prestador.dart';
import '../models/servico_catalogo.dart';

class DuckHatApi {
  DuckHatApi._();

  static final DuckHatApi instance = DuckHatApi._();

  final http.Client _client = http.Client();

  String? _token;

  Future<void> ensureAuthenticated() async {
    if (_token != null && _token!.isNotEmpty) return;

    if (ApiConfig.loginEmail.isEmpty || ApiConfig.loginPassword.isEmpty) {
      throw Exception(
        'Defina DUCKHAT_LOGIN_EMAIL e DUCKHAT_LOGIN_PASSWORD via --dart-define.',
      );
    }

    final response = await _client.post(
      Uri.parse('${ApiConfig.baseUrl}/api/auth/login'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': ApiConfig.loginEmail,
        'senha': ApiConfig.loginPassword,
      }),
    );

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

    _token = token;
  }

  Future<List<Agendamento>> listarAgendamentos() async {
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

    return Agendamento.fromJson(body);
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

    return Agendamento.fromJson(body);
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
}
