import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class DemoChatPage extends StatefulWidget {
  const DemoChatPage({super.key});

  @override
  State<DemoChatPage> createState() => _DemoChatPageState();
}

class _DemoChatPageState extends State<DemoChatPage> {
  final TextEditingController _searchController = TextEditingController();

  final List<Map<String, dynamic>> _conversas = [
    {
      'name': 'Barbie\'s Salon',
      'lastMessage': 'Seu agendamento foi confirmado!',
      'time': '10:30',
      'unread': 2,
    },
    {
      'name': 'James Salon',
      'lastMessage': 'Obrigado pelo atendimento',
      'time': '09:15',
      'unread': 0,
    },
    {
      'name': 'Salão Beleza',
      'lastMessage': 'Qual horário você prefere?',
      'time': 'Ontem',
      'unread': 1,
    },
    {
      'name': 'M&L Encanamentos',
      'lastMessage': 'Ok, até lá',
      'time': 'Ontem',
      'unread': 0,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildConversationList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  Widget _buildConversationList() {
    return ListView.builder(
      key: const PageStorageKey('chat-scroll'),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _conversas.length,
      itemBuilder: (context, index) =>
          _buildConversationItem(_conversas[index]),
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> conversa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    DemoChatDetailPage(conversaName: conversa['name']),
              ),
            );
          },
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
                      conversa['name'][0].toUpperCase(),
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
                        conversa['name'],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        conversa['lastMessage'],
                        style: const TextStyle(
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      conversa['time'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                    if (conversa['unread'] > 0) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${conversa['unread']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoChatDetailPage extends StatefulWidget {
  final String conversaName;

  const DemoChatDetailPage({super.key, required this.conversaName});

  @override
  State<DemoChatDetailPage> createState() => _DemoChatDetailPageState();
}

class _DemoChatDetailPageState extends State<DemoChatDetailPage> {
  final TextEditingController _messageController = TextEditingController();

  final List<Map<String, dynamic>> _messages = [
    {
      'isMe': false,
      'message': 'Olá! Gostaria de agendar um serviço.',
      'time': '10:00',
    },
    {
      'isMe': true,
      'message': 'Claro! Qual serviço você deseja?',
      'time': '10:05',
    },
    {'isMe': false, 'message': 'Corte de cabelo e barba.', 'time': '10:10'},
    {
      'isMe': true,
      'message': 'Temos disponível amanhã às 14h. Funciona?',
      'time': '10:15',
    },
    {'isMe': false, 'message': 'Perfeito! Obrigada.', 'time': '10:20'},
  ];

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    setState(() {
      _messages.add({
        'isMe': true,
        'message': _messageController.text,
        'time': 'Agora',
      });
    });
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textBold),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.conversaName,
          style: TextStyle(
            color: AppColors.textBold,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['isMe'];
                return _buildMessageBubble(
                  isMe,
                  message['message'],
                  message['time'],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isMe, String message, String time) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? AppColors.chatBubbleSelf : AppColors.chatBubbleOther,
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
              message,
              style: TextStyle(
                color: isMe ? Colors.white : AppColors.textBold,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              time,
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white70 : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.cardShadow,
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
                  color: AppColors.inputFill,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  minLines: 1,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: 'Digite uma mensagem...',
                    hintStyle: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            IconButton.filled(
              onPressed: _sendMessage,
              style: IconButton.styleFrom(backgroundColor: AppColors.accent),
              icon: const Icon(Icons.send, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}
