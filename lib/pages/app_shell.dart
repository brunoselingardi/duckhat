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
  final PageStorageBucket _bucket = PageStorageBucket();
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    RepaintBoundary(child: Home()),
    RepaintBoundary(child: SchedulePage()),
    RepaintBoundary(child: ChatPage()),
    RepaintBoundary(child: PerfilPage()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: DuckHatBottomNav(
        selectedIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
