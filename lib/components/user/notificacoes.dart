import 'package:duckhat/models/notificacao.dart';
import 'package:duckhat/models/notificacao_preferencias.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  final DuckHatApi _api = DuckHatApi.instance;

  List<Notificacao> _notificacoes = [];
  NotificacaoPreferencias? _preferencias;
  bool _loading = true;
  bool _savingPreferences = false;
  bool _markingAll = false;
  String? _error;

  int get _naoLidas => _notificacoes.where((item) => !item.lida).length;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _api.listarNotificacoes(),
        _api.carregarPreferenciasNotificacoes(),
      ]);
      if (!mounted) return;
      setState(() {
        _notificacoes = results[0] as List<Notificacao>;
        _preferencias = results[1] as NotificacaoPreferencias;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _markAsRead(Notificacao notificacao) async {
    if (notificacao.lida) return;

    try {
      final updated = await _api.marcarNotificacaoComoLida(notificacao.id);
      if (!mounted) return;
      setState(() {
        _notificacoes = _notificacoes
            .map((item) => item.id == updated.id ? updated : item)
            .toList();
      });
    } catch (error) {
      if (!mounted) return;
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _markAllAsRead() async {
    if (_naoLidas == 0 || _markingAll) return;

    setState(() => _markingAll = true);
    try {
      await _api.marcarTodasNotificacoesComoLidas();
      await _load();
    } catch (error) {
      if (!mounted) return;
      setState(() => _markingAll = false);
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _updatePreferences(NotificacaoPreferencias preferencias) async {
    setState(() {
      _savingPreferences = true;
      _preferencias = preferencias;
    });

    try {
      final saved = await _api.atualizarPreferenciasNotificacoes(preferencias);
      if (!mounted) return;
      setState(() {
        _preferencias = saved;
        _savingPreferences = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() => _savingPreferences = false);
      _showSnack(error.toString().replaceFirst('Exception: ', ''));
      _load();
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

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
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh, color: AppColors.accent),
          ),
        ],
      ),
      body: RefreshIndicator(onRefresh: _load, child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _StateMessage(
            icon: Icons.notifications_off_outlined,
            title: 'Não foi possível carregar',
            message: _error!,
            actionLabel: 'Tentar novamente',
            onAction: _load,
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      children: [
        _SummaryCard(
          total: _notificacoes.length,
          unread: _naoLidas,
          markingAll: _markingAll,
          onMarkAll: _markAllAsRead,
        ),
        const SizedBox(height: 18),
        _buildSectionTitle('CENTRAL'),
        const SizedBox(height: 8),
        if (_notificacoes.isEmpty)
          const _StateMessage(
            icon: Icons.notifications_none_outlined,
            title: 'Nenhuma notificação',
            message:
                'Agendamentos, confirmações e mensagens aparecerão aqui automaticamente.',
          )
        else
          ..._notificacoes.map(
            (notificacao) => _NotificationTile(
              notificacao: notificacao,
              onTap: () => _markAsRead(notificacao),
            ),
          ),
        const SizedBox(height: 24),
        _buildSectionTitle('PREFERÊNCIAS'),
        const SizedBox(height: 8),
        if (_preferencias != null) ..._buildPreferenceToggles(_preferencias!),
      ],
    );
  }

  List<Widget> _buildPreferenceToggles(NotificacaoPreferencias preferencias) {
    return [
      _PreferenceToggle(
        title: 'Agendamentos',
        subtitle: 'Criação, confirmação, cancelamento e conclusão',
        value: preferencias.agendamentos,
        saving: _savingPreferences,
        onChanged: (value) =>
            _updatePreferences(preferencias.copyWith(agendamentos: value)),
      ),
      _PreferenceToggle(
        title: 'Mensagens',
        subtitle: 'Avisos de novas mensagens no chat',
        value: preferencias.mensagens,
        saving: _savingPreferences,
        onChanged: (value) =>
            _updatePreferences(preferencias.copyWith(mensagens: value)),
      ),
      _PreferenceToggle(
        title: 'Promoções e ofertas',
        subtitle: 'Campanhas e descontos dentro do app',
        value: preferencias.promocoes,
        saving: _savingPreferences,
        onChanged: (value) =>
            _updatePreferences(preferencias.copyWith(promocoes: value)),
      ),
      _PreferenceToggle(
        title: 'Novidades',
        subtitle: 'Atualizações de produto e recursos novos',
        value: preferencias.novidades,
        saving: _savingPreferences,
        onChanged: (value) =>
            _updatePreferences(preferencias.copyWith(novidades: value)),
      ),
      _PreferenceToggle(
        title: 'Resumo por e-mail',
        subtitle: 'Resumo semanal de atividade da conta',
        value: preferencias.resumoEmail,
        saving: _savingPreferences,
        onChanged: (value) =>
            _updatePreferences(preferencias.copyWith(resumoEmail: value)),
      ),
    ];
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: AppColors.textMuted,
        letterSpacing: 1,
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int total;
  final int unread;
  final bool markingAll;
  final VoidCallback onMarkAll;

  const _SummaryCard({
    required this.total,
    required this.unread,
    required this.markingAll,
    required this.onMarkAll,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.22),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.notifications_active_outlined,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Central ativa',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$unread não lidas de $total notificações',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: unread == 0 || markingAll ? null : onMarkAll,
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              disabledForegroundColor: Colors.white54,
            ),
            child: markingAll
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Ler todas'),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final Notificacao notificacao;
  final VoidCallback onTap;

  const _NotificationTile({required this.notificacao, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(notificacao.tipo);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: notificacao.lida
                  ? AppColors.cardBackground
                  : AppColors.accentLight.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: notificacao.lida
                    ? AppColors.divider
                    : AppColors.accent.withValues(alpha: 0.22),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_iconFor(notificacao.tipo), color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notificacao.titulo,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textBold,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          if (!notificacao.lida)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        notificacao.mensagem,
                        style: const TextStyle(
                          color: AppColors.textRegular,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _formatDate(
                          notificacao.criadoEm ?? notificacao.agendadoPara,
                        ),
                        style: TextStyle(
                          color: AppColors.textMuted.withValues(alpha: 0.9),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static IconData _iconFor(String tipo) {
    return switch (tipo) {
      'AGENDAMENTO' => Icons.event_available_outlined,
      'MENSAGEM' => Icons.chat_bubble_outline_rounded,
      'PROMOCAO' => Icons.local_offer_outlined,
      _ => Icons.info_outline,
    };
  }

  static Color _colorFor(String tipo) {
    return switch (tipo) {
      'AGENDAMENTO' => AppColors.accent,
      'MENSAGEM' => AppColors.purple,
      'PROMOCAO' => AppColors.warning,
      _ => AppColors.success,
    };
  }

  static String _formatDate(DateTime date) {
    final local = date.toLocal();
    final now = DateTime.now();
    final sameDay =
        local.year == now.year &&
        local.month == now.month &&
        local.day == now.day;
    final hour =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    if (sameDay) return 'Hoje, $hour';
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}, $hour';
  }
}

class _PreferenceToggle extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final bool saving;
  final ValueChanged<bool> onChanged;

  const _PreferenceToggle({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.saving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
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
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkAlt,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textRegular,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: saving ? null : onChanged,
            activeThumbColor: AppColors.accent,
          ),
        ],
      ),
    );
  }
}

class _StateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _StateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 36),
      child: Column(
        children: [
          Icon(icon, size: 42, color: AppColors.accent),
          const SizedBox(height: 12),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textBold,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textRegular, height: 1.45),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 14),
            FilledButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
