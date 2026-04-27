import 'package:flutter/material.dart';
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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary.withValues(alpha: 0),
      body: PageStorage(
        bucket: _bucket,
        child: IndexedStack(
          index: _currentIndex,
          children: const [
            RepaintBoundary(child: ShopHomePage()),
            RepaintBoundary(child: ShopSchedulePage()),
            RepaintBoundary(child: ShopClientsPage()),
            RepaintBoundary(child: ShopProfilePage()),
          ],
        ),
      ),
      bottomNavigationBar: ShopBottomNav(
        selectedIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
