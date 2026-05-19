import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class HomeHeader extends StatelessWidget {
  final String? username;

  const HomeHeader({super.key, this.username});

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);
    final trimmedName = username?.trim();
    final greeting = trimmedName == null || trimmedName.isEmpty
        ? 'Quack!'
        : 'Quack, $trimmedName!';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Image.asset(
              "assets/logologo.png",
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              greeting,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: themeColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
