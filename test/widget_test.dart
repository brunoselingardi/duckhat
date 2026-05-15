import 'package:duckhat/pages/launch_intro.dart';
import 'package:duckhat/main.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
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
    expect(find.text('Modo dev'), findsNothing);
    expect(find.text('Entrar como cliente'), findsNothing);
    expect(find.text('Entrar como estabelecimento'), findsNothing);
  });
}
