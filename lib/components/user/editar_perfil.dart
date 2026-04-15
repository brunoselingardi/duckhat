import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class EditarPerfilPage extends StatefulWidget {
  const EditarPerfilPage({super.key});

  @override
  State<EditarPerfilPage> createState() => _EditarPerfilPageState();
}

class _EditarPerfilPageState extends State<EditarPerfilPage> {
  late TextEditingController _nomeController;
  late TextEditingController _emailController;
  late TextEditingController _telefoneController;
  late TextEditingController _nascimentoController;
  late TextEditingController _enderecoController;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: 'Estadosunilson');
    _emailController = TextEditingController(
      text: 'estadosunilson@hotmail.com.br',
    );
    _telefoneController = TextEditingController(text: '(11) 99999-9999');
    _nascimentoController = TextEditingController(text: '01/01/1990');
    _enderecoController = TextEditingController(text: 'Rua Example, 123');
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _emailController.dispose();
    _telefoneController.dispose();
    _nascimentoController.dispose();
    _enderecoController.dispose();
    super.dispose();
  }

  void _salvar() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Perfil salvo com sucesso!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundAlt,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _salvar,
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: AppColors.accent,
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
                      color: AppColors.accent,
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
                        border: Border.all(color: AppColors.accent, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        size: 16,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField('Nome', _nomeController, Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField('Email', _emailController, Icons.email_outlined),
            const SizedBox(height: 16),
            _buildTextField(
              'Telefone',
              _telefoneController,
              Icons.phone_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Data de Nascimento',
              _nascimentoController,
              Icons.cake_outlined,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              'Endereço',
              _enderecoController,
              Icons.location_on_outlined,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
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
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.grayField),
          prefixIcon: Icon(icon, color: AppColors.accent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
        ),
      ),
    );
  }
}
