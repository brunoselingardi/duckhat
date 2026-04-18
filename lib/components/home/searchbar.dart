import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

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
            colors: [AppColors.accentLight, AppColors.secondary],
          ),
          boxShadow: const [
            BoxShadow(
              color: AppColors.cardShadow,
              offset: Offset(0, -2),
              blurRadius: 5,
            ),
            BoxShadow(
              color: AppColors.cardShadow,
              offset: Offset(0, 2),
              blurRadius: 3,
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
          ),
          child: TextField(
            controller: controller,
            onChanged: onChanged,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              hintText: "Encontre os melhores serviços...",
              hintStyle: TextStyle(
                color: AppColors.textRegular,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 20),
                child: Icon(
                  Icons.search,
                  size: 20,
                  color: AppColors.textRegular,
                ),
              ),
              suffixIconConstraints: const BoxConstraints(
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
