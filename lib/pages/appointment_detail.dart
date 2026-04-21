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
          backgroundColor: Colors.redAccent,
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
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
        children: [
          _HeroSummary(agendamento: item),
          const SizedBox(height: 16),
          _DetailCard(
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
            OutlinedButton.icon(
              onPressed: _cancelling ? null : _cancel,
              icon: _cancelling
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.close),
              label: Text(
                _cancelling ? 'Cancelando...' : 'Cancelar agendamento',
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.redAccent,
                side: const BorderSide(color: Colors.redAccent),
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
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

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

class _HeroSummary extends StatelessWidget {
  final Agendamento agendamento;

  const _HeroSummary({required this.agendamento});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(18),
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
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.event_available, color: Colors.white),
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
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Text(
                    agendamento.status,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
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

class _DetailCard extends StatelessWidget {
  final List<Widget> children;

  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(children: children),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
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
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
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
                sent ? 'Avaliacao enviada' : 'Avaliar atendimento',
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
