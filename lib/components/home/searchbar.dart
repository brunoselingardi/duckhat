import 'package:flutter/material.dart';

const barColor = Color(0xFFF2F8FF),
    textColor = Color(0xCC2F4987),
    gradientColor1 = Color(0xFF8EB5F0),
    gradientColor2 = Color(0xFF291970),
    shadowColor1 = Color(0x66A2D7EC),
    shadowColor2 = Color(0x4D80C3F8);

class SearchDuck extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const SearchDuck({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(1.7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [gradientColor1, gradientColor2],
          ),
          boxShadow: const [
            BoxShadow(
              color: shadowColor1,
              offset: Offset(0, -2),
              blurRadius: 5,
            ),
            BoxShadow(color: shadowColor2, offset: Offset(0, 2), blurRadius: 3),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,

              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              hintText: "Encontre os melhores serviços...",
              hintStyle: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),

              suffixIcon: Padding(
                padding: EdgeInsets.only(right: 20),
                child: Icon(Icons.search, size: 20, color: textColor),
              ),

              suffixIconConstraints: BoxConstraints(
                minHeight: 32,
                minWidth: 32,
              ),

              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
