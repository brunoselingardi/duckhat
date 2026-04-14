import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import 'pages/home.dart';

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
      home: const Home(),
    );
  }
}
