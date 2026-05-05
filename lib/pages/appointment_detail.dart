import 'package:duckhat/models/agendamento.dart';
import 'package:duckhat/theme.dart';
import 'package:flutter/material.dart';

class AppointmentDetailPage extends StatefulWidget {
  final Agendamento agendamento;
  final Future<void> Function(Agendamento agendamento)? onCancel;

  const AppointmentDetailPage({
    super.key,
    required this.agendamento,
    this.onCancel,
  });

  @override
  State<AppointmentDetailPage> createState() => _AppointmentDetailPageState();
}

class _AppointmentDetailPageState extends State<AppointmentDetailPage> {
  final _commentController = TextEditingController();

  int _rating = 0;
  bool _reviewSent = false;
  bool _cancelling = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _cancel() async {
    if (widget.onCancel == null || _cancelling) return;

    setState(() => _cancelling = true);
    try {
      await widget.onCancel!(widget.agendamento);
      if (!mounted) return;
      Navigator.pop(context, true);
    } finally {
      if (mounted) setState(() => _cancelling = false);
    }
  }

  void _sendReview() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Escolha uma nota para avaliar.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _reviewSent = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Avaliacao registrada para teste.'),
        backgroundColor: AppColors.accent,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.agendamento;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textBold),
        title: const Text(
          'Agendamento',
          style: TextStyle(
            color: AppColors.textBold,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
        children: [
          _HeroSummary(agendamento: item),
          const SizedBox(height: 16),
          _DetailCard(
            title: 'Resumo',
            children: [
              _InfoRow(
                icon: Icons.content_cut,
                label: 'Servico',
                value: item.servicoNome ?? 'Servico #${item.servicoId}',
              ),
              _InfoRow(
                icon: Icons.storefront_outlined,
                label: 'Prestador',
                value:
                    item.prestadorNome ??
                    (item.prestadorId == null
                        ? 'Prestador nao informado'
                        : 'Prestador #${item.prestadorId}'),
              ),
              _InfoRow(
                icon: Icons.calendar_today_outlined,
                label: 'Data',
                value: _formatDate(item.inicioEm),
              ),
              _InfoRow(
                icon: Icons.schedule,
                label: 'Horario',
                value:
                    '${_formatTime(item.inicioEm)} - ${_formatTime(item.fimEm)}',
              ),
              if (item.observacoes != null &&
                  item.observacoes!.trim().isNotEmpty)
                _InfoRow(
                  icon: Icons.notes_outlined,
                  label: 'Observacoes',
                  value: item.observacoes!,
                ),
            ],
          ),
          const SizedBox(height: 16),
          if (item.podeCancelar)
            _DangerActionCard(cancelling: _cancelling, onCancel: _cancel),
          if (item.podeCancelar) const SizedBox(height: 16),
          _DetailCard(
            title: 'Status do atendimento',
            children: [
              _InfoRow(
                icon: item.status == 'CANCELADO'
                    ? Icons.cancel_outlined
                    : Icons.verified_outlined,
                label: 'Situacao',
                value: _statusText(item.status),
                color: _statusColor(item.status),
              ),
              _InfoRow(
                icon: Icons.info_outline,
                label: 'Origem',
                value: 'Agendado pelo app DuckHat',
              ),
            ],
          ),
          if (item.status == 'CONCLUIDO') ...[
            const SizedBox(height: 16),
            _ReviewCard(
              rating: _rating,
              sent: _reviewSent,
              controller: _commentController,
              onRatingChanged: (value) => setState(() => _rating = value),
              onSubmit: _sendReview,
            ),
          ],
        ],
      ),
    );
  }

  String _statusText(String status) {
    return switch (status) {
      'CONFIRMADO' => 'Confirmado pelo prestador',
      'CANCELADO' => 'Agendamento cancelado',
      'CONCLUIDO' => 'Atendimento concluido',
      _ => 'Aguardando confirmacao',
    };
  }

  Color _statusColor(String status) {
    return switch (status) {
      'CONFIRMADO' => AppColors.success,
      'CANCELADO' => AppColors.error,
      'CONCLUIDO' => AppColors.textMuted,
      _ => AppColors.warning,
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _DangerActionCard extends StatelessWidget {
  final bool cancelling;
  final VoidCallback onCancel;

  const _DangerActionCard({required this.cancelling, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.event_busy, color: AppColors.error),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cancelar agendamento',
                  style: TextStyle(
                    color: AppColors.textBold,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Use esta acao se nao puder comparecer.',
                  style: TextStyle(color: AppColors.textMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: cancelling ? null : onCancel,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.error,
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: cancelling
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

class _HeroSummary extends StatelessWidget {
  final Agendamento agendamento;

  const _HeroSummary({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (agendamento.status) {
      'CONFIRMADO' => AppColors.success,
      'CANCELADO' => AppColors.error,
      'CONCLUIDO' => AppColors.textMuted,
      _ => AppColors.warning,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.secondary, AppColors.accent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.event_available, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agendamento.servicoNome ??
                      'Servico #${agendamento.servicoId}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _HeroPill(
                      icon: Icons.schedule,
                      label: _formatHeroTime(agendamento.inicioEm),
                    ),
                    _HeroPill(
                      icon: Icons.circle,
                      label: agendamento.status,
                      color: statusColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatHeroTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _HeroPill({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    final foreground = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: foreground, size: icon == Icons.circle ? 8 : 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textBold,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color = AppColors.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppColors.textBold,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final int rating;
  final bool sent;
  final TextEditingController controller;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onSubmit;

  const _ReviewCard({
    required this.rating,
    required this.sent,
    required this.controller,
    required this.onRatingChanged,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return _DetailCard(
      title: 'Avaliacao',
      children: [
        Row(
          children: [
            Icon(
              sent ? Icons.check_circle_outline : Icons.star_border,
              color: AppColors.accent,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                sent ? 'Avaliacao enviada' : 'Escolha sua nota',
                style: const TextStyle(
                  color: AppColors.textBold,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (!sent) ...[
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => onRatingChanged(value),
                icon: Icon(
                  value <= rating ? Icons.star : Icons.star_border,
                  color: AppColors.star,
                  size: 30,
                ),
              );
            }),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: controller,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Conte como foi o atendimento',
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onSubmit,
              icon: const Icon(Icons.send_outlined),
              label: const Text('Enviar avaliacao'),
            ),
          ),
        ] else
          const Text(
            'Obrigado por ajudar outros clientes a escolherem melhor.',
            style: TextStyle(color: AppColors.textRegular),
          ),
      ],
    );
  }
}
