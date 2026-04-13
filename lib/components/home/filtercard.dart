import 'package:flutter/material.dart';

const cardColor = Color.fromARGB(255, 255, 255, 255),
    color = Color(0xFFC0C2D56),
    filterBackground = Color.fromARGB(255, 244, 245, 248),
    filterShadow = Color(0x330C0041),
    filterSelected = Color.fromARGB(255, 100, 149, 237);

class FilterCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const FilterCard({
    super.key,
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 100,
        height: 80,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(blurRadius: 6, color: filterShadow)],
          border: isSelected
              ? Border.all(color: filterSelected, width: 2)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.15 : 1,
              duration: const Duration(milliseconds: 200),
              child: Icon(icon, size: 28, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
