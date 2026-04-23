import 'package:duckhat/core/app_route.dart';
import 'package:duckhat/models/chat_conversa.dart';
import 'package:duckhat/pages/chat_detail.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart' show AppColors;
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _searchController = TextEditingController();
  final DuckHatApi _api = DuckHatApi.instance;

  List<ChatConversa> _conversas = [];
  bool _loading = true;
  String? _error;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _loadConversas();
    _searchController.addListener(() {
      setState(() => _query = _searchController.text.trim().toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadConversas() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final conversas = await _api.listarConversasChat();
      if (!mounted) return;
      setState(() {
        _conversas = conversas;
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

  List<ChatConversa> get _filteredConversas {
    if (_query.isEmpty) return _conversas;
    return _conversas.where((conversa) {
      final nome = conversa.participanteNome.toLowerCase();
      final ultima = (conversa.ultimaMensagem ?? '').toLowerCase();
      return nome.contains(_query) || ultima.contains(_query);
    }).toList();
  }

  Future<void> _openConversa(ChatConversa conversa) async {
    await Navigator.push(
      context,
      AppRoute(
        builder: (context) => ChatDetailPage(
          conversaId: conversa.id,
          participanteNome: conversa.participanteNome,
        ),
      ),
    );

    if (mounted) {
      _loadConversas();
    }
  }

  @override
  Widget build(BuildContext context) {
    final conversas = _filteredConversas;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadConversas,
                child: _buildBody(conversas),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Mensagens',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textBold,
              ),
            ),
          ),
          IconButton(
            onPressed: _loading ? null : _loadConversas,
            tooltip: 'Atualizar',
            icon: const Icon(Icons.refresh),
            color: AppColors.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar conversas',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(List<ChatConversa> conversas) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _ChatStateMessage(
            icon: Icons.error_outline,
            title: 'Não foi possível carregar as conversas',
            message: _error!,
            actionLabel: 'Tentar novamente',
            onAction: _loadConversas,
          ),
        ],
      );
    }

    if (conversas.isEmpty) {
      return ListView(
        padding: const EdgeInsets.all(24),
        children: const [
          _ChatStateMessage(
            icon: Icons.chat_bubble_outline_rounded,
            title: 'Nenhuma conversa',
            message: 'Abra um estabelecimento e toque em Enviar Mensagem.',
          ),
        ],
      );
    }

    return ListView.builder(
      key: const PageStorageKey('chat-scroll'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: conversas.length,
      itemBuilder: (context, index) => _buildConversationItem(conversas[index]),
    );
  }

  Widget _buildConversationItem(ChatConversa conversa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openConversa(conversa),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppColors.accentLight.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      conversa.participanteNome.isEmpty
                          ? '?'
                          : conversa.participanteNome[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.accent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        conversa.participanteNome,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conversa.ultimaMensagem ?? 'Conversa criada',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textRegular,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatTime(conversa.ultimaMensagemEm),
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final now = DateTime.now();
    final local = date.toLocal();
    final sameDay =
        now.year == local.year && now.month == local.month && now.day == local.day;
    if (sameDay) {
      return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    }
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }
}

class _ChatStateMessage extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _ChatStateMessage({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
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
              fontWeight: FontWeight.w700,
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
