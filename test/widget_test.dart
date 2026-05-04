import 'package:duckhat/pages/app_shell.dart';
import 'package:duckhat/main.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  tearDown(() {
    DuckHatApi.instance.clearSession();
  });

  testWidgets('DuckHat renders login screen', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());

    expect(find.text('Quack,\nBem-vindo de volta!'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Modo dev'), findsOneWidget);
    expect(find.text('Entrar como cliente'), findsOneWidget);
    expect(find.text('Entrar como estabelecimento'), findsOneWidget);
  });

  testWidgets('dev mode enters as client without credentials', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Entrar como cliente'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(DuckHatApi.instance.isDevMode, isTrue);
    expect(DuckHatApi.instance.currentSession?.tipo, 'CLIENTE');
    expect(find.byType(MainNavigator), findsOneWidget);
  });

  testWidgets('dev mode enters as establishment without credentials', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Entrar como estabelecimento'));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(milliseconds: 100));

    expect(DuckHatApi.instance.isDevMode, isTrue);
    expect(DuckHatApi.instance.currentSession?.tipo, 'PRESTADOR');
    expect(find.byType(ShopMainNavigator), findsOneWidget);
  });
}
