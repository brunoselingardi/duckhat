import 'package:flutter/material.dart';

import 'filtercard.dart';
import 'filteritem.dart';

class FilterSection extends StatefulWidget {
  const FilterSection({super.key});

  @override
  State<FilterSection> createState() => _FilterSectionState();
}

class _FilterSectionState extends State<FilterSection> {
  int selectedIndex = -1;

  final filters = const [
    FilterItem(Icons.cut, "Cabelereiro"),
    FilterItem(Icons.spa, "Manicure"),
    FilterItem(Icons.key, "Chaveiro"),
    FilterItem(Icons.plumbing, "Encanador"),
    FilterItem(Icons.lightbulb, "Eletricista"),
    FilterItem(Icons.car_crash, "Mecânico"),
    FilterItem(Icons.face, "Barbeiro"),
    FilterItem(Icons.favorite, "Esteticista"),
    FilterItem(Icons.build, "Pedreiro"),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: [
            const SizedBox(width: 16),

            ...List.generate(filters.length, (index) {
              final filter = filters[index];

              return FilterCard(
                icon: filter.icon,
                label: filter.label,
                isSelected: selectedIndex == index,
                onTap: () {
                  setState(() {
                    selectedIndex = index;
                  });
                },
              );
            }),

            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}
