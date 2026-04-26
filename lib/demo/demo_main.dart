import 'package:flutter/material.dart';
import 'package:duckhat/components/bottomnav.dart';
import 'package:duckhat/demo/demo_chat.dart';
import 'package:duckhat/demo/demo_home.dart';
import 'package:duckhat/demo/demo_schedule.dart';
import 'package:duckhat/demo/demo_profile.dart';

class DemoMainNavigator extends StatefulWidget {
  const DemoMainNavigator({super.key});

  @override
  State<DemoMainNavigator> createState() => _DemoMainNavigatorState();
}

class _DemoMainNavigatorState extends State<DemoMainNavigator> {
  final PageStorageBucket _bucket = PageStorageBucket();
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    RepaintBoundary(child: DemoHomePage()),
    RepaintBoundary(child: DemoSchedulePage()),
    RepaintBoundary(child: DemoChatPage()),
    RepaintBoundary(child: DemoProfilePage()),
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
