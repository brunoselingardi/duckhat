import 'package:duckhat/pages/app_shell.dart';
import 'package:duckhat/pages/launch_intro.dart';
import 'package:duckhat/main.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_main.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pump();
}

Future<void> _pumpLoginSuccessSequence(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 60));
  await tester.pump(const Duration(milliseconds: 780));
  await tester.pump(const Duration(milliseconds: 80));
  await tester.pump();
}

void main() {
  tearDown(() {
    DuckHatApi.instance.clearSession();
  });

  testWidgets('DuckHat renders login screen', (tester) async {
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await _pumpApp(tester);
    expect(find.byType(LaunchIntroPage), findsOneWidget);
    expect(
      find.byKey(const ValueKey('launchIntroDetectiveLogo')),
      findsOneWidget,
    );
    expect(find.text('Carregando DuckHat'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 2400));
    expect(find.byType(LaunchIntroPage), findsOneWidget);
    expect(find.text('Quack,\nBem-vindo de volta!'), findsNothing);
    await tester.pump(const Duration(milliseconds: 1900));
    await tester.pumpAndSettle();

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

    await _pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 4300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar como cliente'));
    await tester.pump();
    await _pumpLoginSuccessSequence(tester);

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

    await _pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 4300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Entrar como estabelecimento'));
    await tester.pump();
    await _pumpLoginSuccessSequence(tester);

    expect(DuckHatApi.instance.isDevMode, isTrue);
    expect(DuckHatApi.instance.currentSession?.tipo, 'PRESTADOR');
    expect(find.byType(ShopMainNavigator), findsOneWidget);
  });
}
