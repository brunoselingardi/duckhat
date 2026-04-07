import 'package:flutter/material.dart';

const primaryColor = Color(0xFFFFFFFF),
    shadowColor = Color(0x803A7FD5),
    splashColor = Color.fromRGBO(142, 181, 240, 0.302),
    selectedColor = Color.fromRGBO(58, 127, 213, 1),
    unselectedColor = Color(0xCC2F4987),
    highlightColor = Color.fromRGBO(142, 181, 240, 0.15);

class DuckHatBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const DuckHatBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: primaryColor,
        boxShadow: [
          BoxShadow(color: shadowColor, offset: Offset(0, -2), blurRadius: 4),
        ],
      ),
      child: Theme(
        data: Theme.of(
          context,
        ).copyWith(splashColor: splashColor, highlightColor: highlightColor),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,

          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
            BottomNavigationBarItem(
              icon: Icon(Icons.schedule),
              label: 'Agenda',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
            BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          ],
        ),
      ),
    );
  }
}
