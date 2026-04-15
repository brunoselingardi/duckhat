import 'package:flutter/material.dart';

class EditarPerfilPage extends StatelessWidget {
  const EditarPerfilPage({super.key});

  static const Color kPrimaryColor = Color(0xFF3A7FD5);
  static const Color kPrimaryLightOpaque = Color(0xFF8EB5F0);
  static const Color kBackgroundColor = Color(0xFFF0F4F8);
  static const Color kSecondaryBackgroundColor = Color(0xFFFFFFFF);
  static const Color kBlackColor = Color(0xFF0C0041);
  static const Color kGrayColor = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: kPrimaryColor,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: kPrimaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      color: kPrimaryColor,
                    ),
                    child: const Center(
                      child: Text(
                        'E',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 2,
                    bottom: 2,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: kPrimaryColor, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Nome', 'Estadosunilson', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(
              'Email',
              'estadosunilson@hotmail.com.br',
              Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Telefone',
              '(11) 99999-9999',
              Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Data de Nascimento',
              '01/01/1990',
              Icons.cake_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Endereço',
              'Rua Example, 123',
              Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: kSecondaryBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: TextStyle(color: kGrayColor),
          hintStyle: TextStyle(color: kGrayColor.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: kPrimaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: kSecondaryBackgroundColor,
        ),
      ),
    );
  }
}
