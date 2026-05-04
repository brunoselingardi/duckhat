import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopServiceDurationPage extends StatefulWidget {
  const ShopServiceDurationPage({super.key});

  @override
  State<ShopServiceDurationPage> createState() =>
      _ShopServiceDurationPageState();
}

class _ShopServiceDurationPageState extends State<ShopServiceDurationPage> {
  final List<Map<String, dynamic>> _services = [
    {
      'name': 'Corte de Cabelo',
      'duration': 30,
      'price': '35,00',
      'active': true,
    },
    {'name': 'Corte + Barba', 'duration': 45, 'price': '50,00', 'active': true},
    {'name': 'Barba', 'duration': 20, 'price': '25,00', 'active': true},
    {'name': 'Depilação', 'duration': 30, 'price': '40,00', 'active': false},
    {'name': 'Sobrancelha', 'duration': 15, 'price': '15,00', 'active': true},
    {'name': 'Penteado', 'duration': 40, 'price': '45,00', 'active': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildShopAppBar(
        context,
        title: 'Serviços e Preços',
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
            'Defina o tempo médio e o preço de cada serviço',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 16),
          ...List.generate(
            _services.length,
            (index) => _buildServiceTile(index),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _addService(context),
            icon: const Icon(Icons.add),
            label: const Text('Adicionar Serviço'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.accent,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceTile(int index) {
    final service = _services[index];
    final name = service['name'] as String;
    final duration = service['duration'] as int;
    final isActive = service['active'] as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: buildShopCardDecoration(radius: 12).boxShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isActive ? AppColors.darkAlt : AppColors.textMuted,
                  ),
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) =>
                    setState(() => _services[index]['active'] = value),
                activeThumbColor: AppColors.accent,
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: _buildDurationControl(index, duration)),
                const SizedBox(width: 12),
                Expanded(child: _buildPriceField(index)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDurationControl(int index, int duration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: duration > 10
                ? () => setState(
                    () => _services[index]['duration'] = duration - 5,
                  )
                : null,
            child: Icon(
              Icons.remove_circle_outline,
              color: duration > 10 ? AppColors.accent : AppColors.textMuted,
              size: 24,
            ),
          ),
          Column(
            children: [
              Text(
                '$duration min',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const Text(
                'Duração',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
          GestureDetector(
            onTap: duration < 120
                ? () => setState(
                    () => _services[index]['duration'] = duration + 5,
                  )
                : null,
            child: Icon(
              Icons.add_circle_outline,
              color: duration < 120 ? AppColors.accent : AppColors.textMuted,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(int index) {
    final priceController = TextEditingController(
      text: _services[index]['price'],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            decoration: InputDecoration(
              prefixText: 'R\$ ',
              prefixStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: AppColors.darkAlt,
              ),
              hintText: '0,00',
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[\d,]')),
              LengthLimitingTextInputFormatter(7),
            ],
            onChanged: (value) {
              _services[index]['price'] = value;
            },
          ),
          const Text(
            'Preço',
            style: TextStyle(fontSize: 10, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Serviços salvos')));
    Navigator.pop(context);
  }

  void _addService(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Em breve: adicionar novo serviço')),
    );
  }
}
