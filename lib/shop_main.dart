import 'package:flutter/material.dart';
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
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ShopHomePage(),
          ShopSchedulePage(),
          ShopClientsPage(),
          ShopProfilePage(),
        ],
      ),
      bottomNavigationBar: ShopBottomNav(
        selectedIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
