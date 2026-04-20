import 'package:duckhat/components/bottomnav.dart';
import 'package:duckhat/pages/chat.dart';
import 'package:duckhat/pages/home.dart';
import 'package:duckhat/pages/schedule.dart';
import 'package:duckhat/pages/user.dart';
import 'package:flutter/material.dart';

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
