import 'package:duckhat/components/user/configuracoes.dart';
import 'package:duckhat/pages/search.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/shop_pages/shop_placeholder.dart';
import 'package:duckhat/shop_pages/shop_profile.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _themedApp(Widget child) {
  return ValueListenableBuilder<ThemeMode>(
    valueListenable: AppThemeController.mode,
    builder: (context, themeMode, _) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeMode,
        home: child,
      );
    },
  );
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    AppThemeController.resetForTests();
  });

  tearDown(() {
    DuckHatApi.instance.clearSession();
    AppThemeController.resetForTests();
  });

  testWidgets('configuracoes alterna e aplica modo escuro', (tester) async {
    await tester.pumpWidget(_themedApp(const ConfiguracoesPage()));
    await tester.pumpAndSettle();

    expect(find.text('Claro'), findsOneWidget);

    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Escuro'), findsOneWidget);
    expect(AppThemeController.isDark, isTrue);
    expect(
      Theme.of(tester.element(find.byType(ConfiguracoesPage))).brightness,
      Brightness.dark,
    );
  });

  testWidgets('perfil do estabelecimento tem controle de tema', (tester) async {
    DuckHatApi.instance.startDevSession(tipo: 'PRESTADOR');

    await tester.pumpWidget(_themedApp(const ShopProfilePage()));
    await tester.pumpAndSettle();

    expect(find.text('PREFERÊNCIAS DO APP'), findsOneWidget);
    expect(find.text('Tema do aplicativo'), findsOneWidget);
    expect(find.text('Modo claro ativo'), findsOneWidget);

    await tester.ensureVisible(find.text('Tema do aplicativo'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch).first);
    await tester.pumpAndSettle();

    expect(find.text('Modo escuro ativo'), findsOneWidget);
    expect(AppThemeController.isDark, isTrue);
  });

  testWidgets('telas principais usam fundo do tema escuro', (tester) async {
    AppThemeController.resetForTests(value: ThemeMode.dark);

    await tester.pumpWidget(_themedApp(const SearchPage()));
    await tester.pumpAndSettle();

    var scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(
      scaffold.backgroundColor,
      AppThemeColors.of(tester.element(find.byType(SearchPage))).background,
    );

    await tester.pumpWidget(_themedApp(const ShopPlaceholderPage()));
    await tester.pumpAndSettle();

    scaffold = tester.widget<Scaffold>(find.byType(Scaffold).first);
    expect(
      scaffold.backgroundColor,
      AppThemeColors.of(
        tester.element(find.byType(ShopPlaceholderPage)),
      ).background,
    );
  });
}
