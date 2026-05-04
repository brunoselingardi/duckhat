import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopWorkDaysPage extends StatefulWidget {
  const ShopWorkDaysPage({super.key});

  @override
  State<ShopWorkDaysPage> createState() => _ShopWorkDaysPageState();
}

class _ShopWorkDaysPageState extends State<ShopWorkDaysPage> {
  final Map<String, bool> _days = {
    'Segunda-feira': true,
    'Terça-feira': true,
    'Quarta-feira': true,
    'Quinta-feira': true,
    'Sexta-feira': true,
    'Sábado': false,
    'Domingo': false,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildShopAppBar(
        context,
        title: 'Dias de Funcionamento',
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
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Selecione os dias que o estabelecimento funcionará',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ..._days.entries.map(
            (entry) => _buildDayTile(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile(String day, bool isOpen) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SwitchListTile(
        value: isOpen,
        onChanged: (value) => setState(() => _days[day] = value),
        title: Text(
          day,
          style: TextStyle(
            color: isOpen ? AppColors.darkAlt : AppColors.textMuted,
            fontWeight: FontWeight.w500,
          ),
        ),
        activeThumbColor: AppColors.accent,
        secondary: Icon(
          isOpen ? Icons.check_circle : Icons.cancel,
          color: isOpen ? AppColors.success : AppColors.textMuted,
        ),
      ),
    );
  }

  void _save(BuildContext context) {
    final openDays = _days.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Dias de funcionamento: $openDays')));
    Navigator.pop(context);
  }
}
