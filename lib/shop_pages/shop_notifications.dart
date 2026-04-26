import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class ShopNotificationsPage extends StatefulWidget {
  const ShopNotificationsPage({super.key});

  @override
  State<ShopNotificationsPage> createState() => _ShopNotificationsPageState();
}

class _ShopNotificationsPageState extends State<ShopNotificationsPage> {
  bool _pushPromocoes = true;
  bool _pushAgendamentos = true;
  bool _pushMensagens = true;
  bool _pushNovidades = false;
  bool _emailResumo = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.accent),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificações',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('PUSH'),
          _buildToggle(
            'Promoções',
            'Receba ofertas e descontos',
            _pushPromocoes,
            (v) => setState(() => _pushPromocoes = v),
          ),
          _buildToggle(
            'Agendamentos',
            'Lembretes de horários',
            _pushAgendamentos,
            (v) => setState(() => _pushAgendamentos = v),
          ),
          _buildToggle(
            'Mensagens',
            'Novas mensagens de clientes',
            _pushMensagens,
            (v) => setState(() => _pushMensagens = v),
          ),
          _buildToggle(
            'Novidades',
            'Atualizações do app',
            _pushNovidades,
            (v) => setState(() => _pushNovidades = v),
          ),
          const SizedBox(height: 16),
          _buildSectionTitle('E-MAIL'),
          _buildToggle(
            'Resumo Semanal',
            'Resumo dos agendamentos',
            _emailResumo,
            (v) => setState(() => _emailResumo = v),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textMuted,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildToggle(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkAlt,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.accent,
          ),
        ],
      ),
    );
  }

  void _save(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notificações salvas')));
    Navigator.pop(context);
  }
}
