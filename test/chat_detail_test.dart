import 'dart:convert';

import 'package:duckhat/pages/chat_detail.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('ChatDetailPage renders participant profile image in app bar', (
    tester,
  ) async {
    final imageBase64 = base64Encode(_transparentPng);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ChatDetailPage(
          conversaId: 10,
          participanteNome: 'Cliente Teste',
          participanteFotoPerfilBase64: imageBase64,
        ),
      ),
    );

    await tester.pump();

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
