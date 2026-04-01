import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F8),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // TOPO (onda + título)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A6CF7), Color(0xFF6A8DFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(30),
                ),
              ),
              child: const Text(
                "Criação de conta",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOTÕES CLIENTE / EMPRESA
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildOptionCard("Cliente", Icons.person),
                const SizedBox(width: 10),
                _buildOptionCard("Empresa", Icons.store),
              ],
            ),

            const SizedBox(height: 30),

            // FORMULÁRIO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildTextField("Nome completo", Icons.person),
                  _buildTextField("seu@email.com", Icons.email),
                  _buildTextField("senha", Icons.lock, isPassword: true),
                  _buildTextField("Confirmar senha", Icons.lock, isPassword: true),

                  const SizedBox(height: 20),

                  // LOGIN LINK
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text("Já tem uma conta? "),
                      Text(
                        "Entrar",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // CARD CLIENTE/EMPRESA
  Widget _buildOptionCard(String title, IconData icon) {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 30),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // INPUT PADRÃO
  Widget _buildTextField(String hint, IconData icon,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: Icon(icon),
          suffixIcon: isPassword
              ? const Icon(Icons.visibility_off)
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}