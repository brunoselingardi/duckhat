import 'package:flutter/material.dart';

class FilterSection extends StatelessWidget {
  const FilterSection({super.key});

  final List<Map<String, dynamic>> filters = const [
    {"name": "Corte", "icon": Icons.content_cut},
    {"name": "Barba", "icon": Icons.face},
    {"name": "Manicure", "icon": Icons.back_hand},
    {"name": "Pedicure", "icon": Icons.spa},
    {"name": "Massagem", "icon": Icons.self_improvement},
    {"name": "Depilação", "icon": Icons.auto_fix_high},
    {"name": "Sobrancelha", "icon": Icons.remove_red_eye},
    {"name": "Estética", "icon": Icons.spa_outlined},
    {"name": "Encanador", "icon": Icons.plumbing},
    {"name": "Ar Cond.", "icon": Icons.ac_unit},
    {"name": "Eletricista", "icon": Icons.electrical_services},
    {"name": "Chaveiro", "icon": Icons.key},
  ];

  @override
  Widget build(BuildContext context) {
    List<List<Map<String, dynamic>>> rows = [[], [], []];

    for (int i = 0; i < filters.length; i++) {
      rows[i % 3].add(filters[i]);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows.map((row) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: row.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _filterButton(
                      icon: filter["icon"],
                      label: filter["name"],
                    ),
                  );
                }).toList(),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _filterButton({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 218, 235, 255),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 9, 65, 0.08),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color.fromRGBO(41, 25, 112, 0.8)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color.fromRGBO(41, 25, 112, 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
