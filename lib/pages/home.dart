import 'package:flutter/material.dart';
import 'package:duckhat/components/card.dart';
import 'package:duckhat/components/empty.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(128, 194, 248, 0.5),
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          splashColor: const Color.fromRGBO(142, 181, 240, 0.3),
          highlightColor: const Color.fromRGBO(142, 181, 240, 0.15),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,

          selectedItemColor: const Color.fromRGBO(58, 127, 213, 1),
          unselectedItemColor: const Color.fromRGBO(41, 25, 112, 0.5),

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

class _HomeState extends State<Home> {
  int _selectedIndex = 0;
  int _selectedFilter = 0;
  Widget _buildFilterChip(String label, int index) {
    bool selected = _selectedFilter == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color.fromRGBO(45, 34, 91, 1)
              : const Color.fromARGB(255, 223, 236, 255),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            if (selected)
              const Padding(
                padding: EdgeInsets.only(right: 6),
                child: Icon(Icons.check, size: 16, color: Colors.white),
              ),
            Text(
              label,
              style: TextStyle(color: selected ? Colors.white : Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  final List<String> _filters = [
    "Todos",
    "Barbearia",
    "Manicure",
    "Salão de beleza",
    "Massagem",
    "Estética",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("DuckHat"),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(240, 244, 248, 1),
      ),

      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 64, left: 16, right: 16),
            child: Container(
              padding: EdgeInsets.all(2), // espessura da borda
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: LinearGradient(
                  colors: [
                    Color.fromRGBO(142, 181, 240, 1),
                    Color.fromRGBO(41, 25, 112, 1),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(128, 194, 248, 0.5),
                    offset: Offset(0, 4),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),

                  BoxShadow(
                    color: Color.fromRGBO(162, 215, 236, 1),
                    offset: Offset(0, -2),
                    blurRadius: 4,
                    spreadRadius: 0,
                  ),
                ],
              ),

              child: Container(
                decoration: BoxDecoration(
                  color: Color.fromRGBO(240, 244, 248, 1),
                  borderRadius: BorderRadius.circular(28),
                ),

                child: TextField(
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    hintText: "Busque os melhores serviços...",
                    hintStyle: TextStyle(
                      color: Color.fromRGBO(41, 25, 112, 0.8),
                    ),
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),

          SizedBox(
            height: 75,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  _filters.length,
                  (index) => _buildFilterChip(_filters[index], index),
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                ServiceCard(
                  name: "Barbie's Salon",
                  rating: 4.9,
                  image: "assets/barbiesalon.png",
                  distance: 1.2,
                  tags: ["Cabelo", "Maquiagem"],
                ),

                ServiceCard(
                  name: "James's Hairstyle",
                  rating: 4.7,
                  image: "assets/jamessalon.png",
                  distance: 2.4,
                  tags: ["Cabelo", "Barbearia"],
                ),

                ServiceCard(
                  name: "Salão Elegance",
                  rating: 4.8,
                  image: "assets/salao.png",
                  distance: 0.9,
                  tags: ["Cabelo", "Noiva"],
                ),
              ],
            ),
          ),
        ],
      ),

      backgroundColor: Color.fromRGBO(240, 244, 248, 1),
      bottomNavigationBar: DuckHatBottomNav(
        selectedIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
