import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class ServiceTabMenu extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const ServiceTabMenu({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: themeColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: tabs.length,
              itemBuilder: (context, index) {
                final isSelected = index == selectedIndex;
                return InkWell(
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: isSelected
                              ? AppColors.accent
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        tabs[index],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? themeColors.primaryText
                              : themeColors.secondaryText,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Divider(height: 1, color: themeColors.border),
        ],
      ),
    );
  }
}
