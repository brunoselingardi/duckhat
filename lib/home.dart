import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        
        title: const Text("DuckHat"),
        centerTitle: true,
      ),

body: Column(
  children: [
    Padding(
  padding: EdgeInsets.all(16),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),

      child: TextField(
        decoration: InputDecoration(
          hintText: "Pesquisar...",
          hintStyle: TextStyle(color: Color.fromRGBO(41, 25, 112, 0.8)),
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
        ),
      ),
    ),
  ),
)
  ],
),

      bottomNavigationBar: BottomNavigationBar(
        
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Início'),
          BottomNavigationBarItem(icon: Icon(Icons.schedule), label: 'Agenda'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
      ),
    );
  }
}
