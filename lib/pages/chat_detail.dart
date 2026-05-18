import 'package:duckhat/models/chat_mensagem.dart';
import 'package:duckhat/services/chat_notification_service.dart';
import 'package:duckhat/services/duckhat_api.dart';
import 'package:duckhat/theme.dart' show AppColors, AppThemeColors;
import 'package:flutter/material.dart';

class ChatDetailPage extends StatefulWidget {
  final int conversaId;
  final String participanteNome;

  const ChatDetailPage({
    super.key,
    required this.conversaId,
    required this.participanteNome,
  });

  @override
  State<ChatDetailPage> createState() => _ChatDetailPageState();
}

class _ChatDetailPageState extends State<ChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();
  final DuckHatApi _api = DuckHatApi.instance;

  List<ChatMensagem> _messages = [];
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _loadMessages() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final messages = await _api.listarMensagensChat(widget.conversaId);
      if (!mounted) return;
      setState(() {
        _messages = messages;
        _loading = false;
      });
      await ChatNotificationService.instance.markConversationRead(
        widget.conversaId,
      );
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);

    try {
      final message = await _api.enviarMensagemChat(
        conversaId: widget.conversaId,
        conteudo: text,
      );
      if (!mounted) return;
      setState(() {
        _messages = [..._messages, message];
        _messageController.clear();
      });
      await ChatNotificationService.instance.refresh();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _sending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: themeColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          Expanded(child: _buildBody()),
          _buildInputArea(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final themeColors = AppThemeColors.of(context);

    return AppBar(
      backgroundColor: themeColors.surface,
      elevation: 1,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: themeColors.primaryText),
        onPressed: () => Navigator.pop(context),
        tooltip: 'Voltar',
      ),
      title: Text(
        widget.participanteNome,
        style: TextStyle(
          color: themeColors.primaryText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.refresh, color: themeColors.primaryText),
          tooltip: 'Atualizar mensagens',
          onPressed: _loading ? null : _loadMessages,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 42,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppThemeColors.of(context).secondaryText,
                ),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: _loadMessages,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (_messages.isEmpty) {
      final themeColors = AppThemeColors.of(context);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Envie a primeira mensagem desta conversa.',
            textAlign: TextAlign.center,
            style: TextStyle(color: themeColors.secondaryText),
          ),
        ),
      );
    }

    return ListView.builder(
      key: const PageStorageKey('chat-detail-scroll'),
      padding: const EdgeInsets.all(16),
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (context, index) {
        final msg = _messages[_messages.length - 1 - index];
        return _buildMessageBubble(msg);
      },
    );
  }

  Widget _buildMessageBubble(ChatMensagem msg) {
    final isMe = msg.enviadaPorMim;
    final themeColors = AppThemeColors.of(context);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe
              ? AppColors.chatBubbleSelf
              : themeColors.isDark
              ? themeColors.elevatedSurface
              : AppColors.chatBubbleOther,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : Radius.zero,
            bottomRight: isMe ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.conteudo,
              style: TextStyle(
                color: isMe ? Colors.white : themeColors.primaryText,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.criadoEm),
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : themeColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    final themeColors = AppThemeColors.of(context);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: themeColors.surface,
        boxShadow: [
          BoxShadow(
            color: themeColors.shadow.withValues(
              alpha: themeColors.isDark ? 0.34 : 0.22,
            ),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: themeColors.inputFill,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => _sendMessage(),
                  decoration: InputDecoration(
                    hintText: 'Digite uma mensagem...',
                    hintStyle: TextStyle(
                      color: themeColors.mutedText,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _sending ? null : _sendMessage,
              style: IconButton.styleFrom(backgroundColor: AppColors.accent),
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white, size: 18),
              tooltip: 'Enviar',
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final local = date.toLocal();
    return '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }
}
