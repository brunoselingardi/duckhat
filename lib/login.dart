import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _selectedOption = 'Cliente';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xEFF3F7),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/onda_azul.png"),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOPO
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage("assets/onda_de_cima.png"),
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                      ),
                    ),
                  ),
                  const Positioned(
  bottom: 50, // 👈 era 30, sobe o texto
  left: 0,
  right: 0,
  child: Text(
    "Criação de conta",
    textAlign: TextAlign.center,
    style: TextStyle(
      color: Colors.white,
      fontSize: 30,
      fontWeight: FontWeight.bold,
      shadows: [
        Shadow(
          color: Colors.black45,
          offset: Offset(1, 1),
          blurRadius: 6,
        ),
        Shadow(
          color: Colors.black26,
          offset: Offset(2, 2),
          blurRadius: 10,
        ),
      ],
    ),
  ),
),
                ],
              ),

              const SizedBox(height: 24),

              // CARDS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildOptionCard(
                        "Cliente",
                        Icons.person_outline,
                        "Encontre os melhores\nserviços",
                        isSelected: _selectedOption == 'Cliente',
                        onTap: () => setState(() => _selectedOption = 'Cliente'),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildOptionCard(
                        "Empresa",
                        Icons.store_outlined,
                        "Gerencie a sua\nempresa",
                        isSelected: _selectedOption == 'Empresa',
                        onTap: () => setState(() => _selectedOption = 'Empresa'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // TÍTULO FORMULÁRIO
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  "Cadastre-se",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // FORMULÁRIO
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildTextField("Nome completo", Icons.person_outline),
                    _buildTextField("seu@email.com", Icons.email_outlined),
                    _buildTextField("Senha", Icons.lock_outline, isPassword: true),
                    _buildTextField("Confirmar senha", Icons.lock_outline, isPassword: true),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          "Já tem uma conta? ",
                          style: TextStyle(color: Color.fromARGB(255, 249, 247, 247)),
                        ),
                        Text(
                          "Entrar",
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 120),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard(
    String title,
    IconData icon,
    String subtitle, {
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8EEFF) : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.blue.shade200,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon,
                color: isSelected ? Colors.blue : Colors.blue.shade300,
                size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                color: Colors.black45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, IconData icon,
      {bool isPassword = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        obscureText: isPassword,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black38),
          prefixIcon: Icon(icon, color: Colors.black45),
          suffixIcon: isPassword
              ? const Icon(Icons.visibility_off_outlined, color: Colors.black38)
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: const BorderSide(color: Colors.blue, width: 1.5),
          ),
        ),
      ),
    );
  }
}