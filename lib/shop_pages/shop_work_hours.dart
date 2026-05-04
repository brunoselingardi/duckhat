import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import '../shop_components/shop_ui.dart';

class ShopWorkHoursPage extends StatefulWidget {
  const ShopWorkHoursPage({super.key});

  @override
  State<ShopWorkHoursPage> createState() => _ShopWorkHoursPageState();
}

class _ShopWorkHoursPageState extends State<ShopWorkHoursPage> {
  TimeOfDay _startTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildShopAppBar(
        context,
        title: 'Horários de Serviço',
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
            'Defina o horário de funcionamento do estabelecimento',
            style: TextStyle(color: AppColors.textMuted),
          ),
          const SizedBox(height: 24),
          _buildTimeSelector(
            'Abertura',
            _startTime,
            (time) => setState(() => _startTime = time),
          ),
          const SizedBox(height: 16),
          _buildTimeSelector(
            'Fechamento',
            _endTime,
            (time) => setState(() => _endTime = time),
          ),
          const SizedBox(height: 24),
          _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildTimeSelector(
    String label,
    TimeOfDay time,
    Function(TimeOfDay) onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.darkAlt,
            ),
          ),
          OutlinedButton(
            onPressed: () async {
              final newTime = await showTimePicker(
                context: context,
                initialTime: time,
              );
              if (newTime != null) {
                onChanged(newTime);
              }
            },
            child: Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    final hours = _endTime.hour - _startTime.hour;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.accent),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Horário de funcionamento: $hours horas por dia (${_startTime.hour}:00 às ${_endTime.hour}:00)',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Horário: ${_startTime.hour}:00 às ${_endTime.hour}:00'),
      ),
    );
    Navigator.pop(context);
  }
}
