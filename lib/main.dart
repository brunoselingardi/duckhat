import 'package:duckhat/components/service/service_models.dart';
import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/core/app_scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import 'pages/login.dart';
import 'pages/schedule_date.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _precacheStarted = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;

    for (final asset in const [
      'assets/ondas.jpg',
      'assets/Ducklogo.jpg',
      'assets/niceduck.jpg',
      'assets/barbiesalon.jpg',
      'assets/jamessalon.jpg',
      'assets/mariano.jpg',
      'assets/salao.jpg',
      'assets/duck-dance.gif',
    ]) {
      precacheImage(AssetImage(asset), context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.mode,
      builder: (context, themeMode, _) {
        return MaterialApp(
          title: 'DuckHat',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          debugShowCheckedModeBanner: false,
          scrollBehavior: const AppScrollBehavior(),
          home: const LoginPage(),
          onGenerateRoute: (settings) {
            if (settings.name == '/schedule-date') {
              final args = settings.arguments as Map<String, dynamic>;
              return AppRoute(
                builder: (context) => ScheduleDatePage(
                  prestadorId: args['prestadorId'] as int,
                  establishmentName: args['establishmentName'] ?? '',
                  serviceOffers: (args['serviceOffers'] as List<dynamic>)
                      .cast<ServiceOffer>(),
                  initialServiceId: args['initialServiceId'] as int?,
                ),
              );
            }
            return null;
          },
        );
      },
    );
  }
}
