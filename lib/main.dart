import 'package:duckhat/login.dart';
import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import 'package:duckhat/components/bottomnav.dart';
import 'pages/home.dart';
import 'pages/schedule.dart';
import 'pages/schedule_date.dart';
import 'pages/chat.dart';
import 'pages/user.dart';

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
      home: const MainNavigator(),
      onGenerateRoute: (settings) {
        if (settings.name == '/schedule-date') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => ScheduleDatePage(
              serviceName: args['serviceName'] ?? '',
              establishmentName: args['establishmentName'] ?? '',
            ),
          );
        }
        return null;
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const Home(),
    const SchedulePage(),
    const ChatPage(),
    const PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: DuckHatBottomNav(
        selectedIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
