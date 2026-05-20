import 'dart:convert';

import 'package:duckhat/components/shared/profile_avatar.dart';
import 'package:duckhat/models/usuario_perfil.dart';
import 'package:duckhat/pages/user.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    DuckHatApi.instance.clearSession();
  });

  testWidgets('ProfileAvatar renders base64 image when available', (
    tester,
  ) async {
    final imageBase64 = base64Encode(_transparentPng);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(name: 'Cliente Teste', imageBase64: imageBase64),
        ),
      ),
    );

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('C'), findsNothing);
  });

  testWidgets('ProfileAvatar falls back to initial without image', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: ProfileAvatar(name: 'Cliente Teste')),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('ProfileAvatar falls back to initial with invalid base64', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: ProfileAvatar(
            name: 'Cliente Teste',
            imageBase64: 'base64-invalido',
          ),
        ),
      ),
    );

    expect(find.byType(Image), findsNothing);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('PerfilPage renders logged client profile image', (tester) async {
    final imageBase64 = base64Encode(_transparentPng);
    DuckHatApi.instance.startDevSession(tipo: 'CLIENTE');
    await DuckHatApi.instance.atualizarMeuPerfil(
      UsuarioPerfil(
        id: 9001,
        nome: 'Cliente Teste',
        email: 'cliente.dev@duckhat.local',
        telefone: null,
        cnpj: null,
        responsavelNome: null,
        dataNascimento: null,
        endereco: null,
        categoria: null,
        categoriaLabel: null,
        descricao: null,
        horarioAtendimento: null,
        bannerImagemBase64: null,
        fotoPerfilBase64: imageBase64,
        tipo: 'CLIENTE',
      ),
    );

    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const PerfilPage()),
    );
    await tester.pumpAndSettle();

    final profileImages = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is MemoryImage);

    expect(profileImages, isNotEmpty);
  });
}

const _transparentPng = <int>[
  137,
  80,
  78,
  71,
  13,
  10,
  26,
  10,
  0,
  0,
  0,
  13,
  73,
  72,
  68,
  82,
  0,
  0,
  0,
  1,
  0,
  0,
  0,
  1,
  8,
  6,
  0,
  0,
  0,
  31,
  21,
  196,
  137,
  0,
  0,
  0,
  13,
  73,
  68,
  65,
  84,
  120,
  156,
  99,
  248,
  15,
  4,
  0,
  9,
  251,
  3,
  253,
  160,
  121,
  93,
  199,
  0,
  0,
  0,
  0,
  73,
  69,
  78,
  68,
  174,
  66,
  96,
  130,
];
