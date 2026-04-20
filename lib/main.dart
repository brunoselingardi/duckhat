import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import 'pages/login.dart';
import 'pages/schedule_date.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DuckHat',
      theme: AppTheme.theme,
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
      onGenerateRoute: (settings) {
        if (settings.name == '/schedule-date') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ScheduleDatePage(
              serviceId: args['serviceId'] as int,
              prestadorId: args['prestadorId'] as int,
              serviceName: args['serviceName'] ?? '',
              establishmentName: args['establishmentName'] ?? '',
              durationMin: args['durationMin'] as int,
            ),
          );
        }
        return null;
      },
    );
  }
}
