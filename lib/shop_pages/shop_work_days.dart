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
    final themeColors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: themeColors.background,
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
          Text(
            'Selecione os dias que o estabelecimento funcionará',
            style: TextStyle(color: themeColors.mutedText),
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
    final themeColors = AppThemeColors.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: buildShopCardDecorationFor(context, radius: 12),
      child: SwitchListTile(
        value: isOpen,
        onChanged: (value) => setState(() => _days[day] = value),
        title: Text(
          day,
          style: TextStyle(
            color: isOpen ? themeColors.primaryText : themeColors.mutedText,
            fontWeight: FontWeight.w500,
          ),
        ),
        activeThumbColor: themeColors.accent,
        secondary: Icon(
          isOpen ? Icons.check_circle : Icons.cancel,
          color: isOpen ? AppColors.success : themeColors.mutedText,
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
