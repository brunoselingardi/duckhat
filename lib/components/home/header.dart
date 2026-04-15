import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class HomeHeader extends StatelessWidget {
  final String username;

  const HomeHeader({super.key, this.username = "Ricardo"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          Image.asset("assets/icon.png", width: 80, height: 80),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Quack, $username!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.dark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
