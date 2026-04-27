import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopEstablishmentDataPage extends StatefulWidget {
  const ShopEstablishmentDataPage({super.key});

  @override
  State<ShopEstablishmentDataPage> createState() =>
      _ShopEstablishmentDataPageState();
}

class _ShopEstablishmentDataPageState extends State<ShopEstablishmentDataPage> {
  final _nameController = TextEditingController(text: 'Barbearia Silva');
  final _phoneController = TextEditingController(text: '(11) 99999-9999');
  final _emailController = TextEditingController(
    text: 'barbeariasilva@email.com',
  );
  final _addressController = TextEditingController(
    text: 'Rua Example, 123 - Centro',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildShopAppBar(
        context,
        title: 'Dados do Estabelecimento',
        actions: [
          TextButton(
            onPressed: () => _save(context),
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
            _buildTextField(
              'Nome do Estabelecimento',
              _nameController,
              Icons.store,
            ),
            const SizedBox(height: 16),
            _buildTextField('Telefone', _phoneController, Icons.phone),
            const SizedBox(height: 16),
            _buildTextField('E-mail', _emailController, Icons.email),
            const SizedBox(height: 16),
            _buildTextField('Endereço', _addressController, Icons.location_on),
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
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColors.textMuted),
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

  void _save(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Dados salvos')));
    Navigator.pop(context);
  }
}
