import 'package:flutter/material.dart';

class SearchDuck extends StatelessWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;

  const SearchDuck({super.key, this.controller, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            colors: [
              Color.fromRGBO(141, 181, 240, 1),
              Color.fromRGBO(41, 25, 112, 1),
            ],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(128, 194, 248, 0.5),
              offset: Offset(0, 4),
              blurRadius: 4,
            ),
            BoxShadow(
              color: Color.fromRGBO(162, 215, 236, 1),
              offset: Offset(0, -2),
              blurRadius: 4,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 239, 245, 255),
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: const InputDecoration(
              isDense: true,

              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),

              hintText: "Encontre os melhores serviços...",
              hintStyle: TextStyle(color: Color.fromRGBO(41, 25, 112, 0.8)),

              suffixIcon: Icon(Icons.search, size: 20),

              // 🔑 ISSO resolve
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
