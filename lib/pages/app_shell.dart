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
  final Set<int> _loadedIndexes = {0};
  int _currentIndex = 0;

  static const List<Widget> _pages = [
    Home(),
    SchedulePage(),
    ChatPage(),
    PerfilPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageStorage(
        bucket: _bucket,
        child: Stack(
          children: List.generate(_pages.length, (index) {
            final isActive = index == _currentIndex;
            final isLoaded = _loadedIndexes.contains(index);

            return Offstage(
              offstage: !isActive,
              child: TickerMode(
                enabled: isActive,
                child: isLoaded
                    ? RepaintBoundary(child: _pages[index])
                    : const SizedBox.shrink(),
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: DuckHatBottomNav(
        selectedIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
            _loadedIndexes.add(index);
          });
        },
      ),
    );
  }
}
