import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:duckhat/theme.dart';

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
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Serviços e Preços',
          style: TextStyle(
            color: AppColors.textBold,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
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
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              'Defina o tempo médio e o preço de cada serviço',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            _services.length,
            (index) => _buildServiceTile(index),
          ),
          const SizedBox(height: 20),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
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
                    fontWeight: FontWeight.w600,
                    color: isActive ? AppColors.textBold : AppColors.textMuted,
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
            const SizedBox(height: 16),
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
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$duration min',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textBold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: duration > 10
                    ? () => setState(
                        () => _services[index]['duration'] = duration - 5,
                      )
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.remove_circle_outline,
                    color: duration > 10 ? AppColors.accent : AppColors.textMuted,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: duration < 120
                    ? () => setState(
                        () => _services[index]['duration'] = duration + 5,
                      )
                    : null,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.cardShadow,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: duration < 120 ? AppColors.accent : AppColors.textMuted,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Duração',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
      height: 100,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.textBold,
            ),
            decoration: const InputDecoration(
              prefixText: 'R\$ ',
              prefixStyle: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.textBold,
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
          const SizedBox(height: 4),
          const Text(
            'Preço',
            style: TextStyle(fontSize: 11, color: AppColors.textMuted),
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
