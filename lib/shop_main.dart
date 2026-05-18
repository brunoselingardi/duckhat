import 'package:flutter/material.dart';
import 'package:duckhat/services/chat_notification_service.dart';
import 'package:duckhat/theme.dart';
import 'shop_components/shop_bottomnav.dart';
import 'shop_pages/shop_home.dart';
import 'shop_pages/shop_schedule.dart';
import 'shop_pages/shop_clients.dart';
import 'shop_pages/shop_profile.dart';

class ShopMainNavigator extends StatefulWidget {
  const ShopMainNavigator({super.key});

  @override
  State<ShopMainNavigator> createState() => _ShopMainNavigatorState();
}

class _ShopMainNavigatorState extends State<ShopMainNavigator> {
  final PageStorageBucket _bucket = PageStorageBucket();
  final Set<int> _loadedIndexes = {0};
  int _currentIndex = 0;
  final ChatNotificationService _chatNotifications =
      ChatNotificationService.instance;

  static const List<Widget> _pages = [
    ShopHomePage(),
    ShopSchedulePage(),
    ShopClientsPage(),
    ShopProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    _chatNotifications.start();
  }

  @override
  void dispose() {
    _chatNotifications.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: themeColors.background,
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
      bottomNavigationBar: ValueListenableBuilder<int>(
        valueListenable: _chatNotifications.unreadMessages,
        builder: (context, unreadCount, _) {
          return ShopBottomNav(
            selectedIndex: _currentIndex,
            unreadChatCount: unreadCount,
            onTap: (index) => setState(() {
              _currentIndex = index;
              _loadedIndexes.add(index);
            }),
          );
        },
      ),
    );
  }
}
