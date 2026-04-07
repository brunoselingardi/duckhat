import 'package:flutter/material.dart';

class HomeHeader extends StatelessWidget {
  final String username;

  const HomeHeader({super.key, this.username = "Ricardo"});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          /// Duck icon
          Image.asset("assets/icon.png", width: 80, height: 80),

          const SizedBox(width: 12),

          /// Greeting text
          Expanded(
            child: Text(
              'Quack,$username!',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
              ),
            ),
          ),

          /// Notification / profile dot
        ],
      ),
    );
  }
}
