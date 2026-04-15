import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  bool _promocoes = true;
  bool _agendamentos = true;
  bool _mensagens = true;
  bool _novidades = false;

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
          'Notificações',
          style: TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionTitle('PUSH NOTIFICATIONS'),
          const SizedBox(height: 8),
          _buildToggle(
            title: 'Promoções e Ofertas',
            subtitle: 'Receba notificações sobre descontos',
            value: _promocoes,
            onChanged: (v) => setState(() => _promocoes = v),
          ),
          _buildToggle(
            title: 'Agendamentos',
            subtitle: 'Lembretes dos seus horários',
            value: _agendamentos,
            onChanged: (v) => setState(() => _agendamentos = v),
          ),
          _buildToggle(
            title: 'Mensagens',
            subtitle: 'Notificações de novas mensagens',
            value: _mensagens,
            onChanged: (v) => setState(() => _mensagens = v),
          ),
          _buildToggle(
            title: 'Novidades',
            subtitle: 'Novidades do app',
            value: _novidades,
            onChanged: (v) => setState(() => _novidades = v),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('E-MAIL'),
          const SizedBox(height: 8),
          _buildToggle(
            title: 'Resumo Semanal',
            subtitle: 'Receba um resumo por e-mail',
            value: true,
            onChanged: (v) {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildToggle({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.darkAlt,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: AppColors.grayField),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}
