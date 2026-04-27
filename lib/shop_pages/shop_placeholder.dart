import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class ShopPlaceholderPage extends StatelessWidget {
  const ShopPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.storefront, size: 80, color: AppColors.accent),
            const SizedBox(height: 24),
            const Text(
              'Shop Version',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkAlt,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Em desenvolvimento...',
              style: TextStyle(fontSize: 16, color: AppColors.grayField),
            ),
          ],
        ),
      ),
    );
  }
}
