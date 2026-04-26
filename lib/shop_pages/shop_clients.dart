import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';

class ShopClientsPage extends StatefulWidget {
  const ShopClientsPage({super.key});

  @override
  State<ShopClientsPage> createState() => _ShopClientsPageState();
}

class _ShopClientsPageState extends State<ShopClientsPage> {
  final _searchController = TextEditingController();

  final List<Map<String, dynamic>> _clients = [
    {
      'id': 1,
      'name': 'João Silva',
      'photo': 'J',
      'lastMessage': 'Obrigado pelo atendimento!',
      'time': '10:30',
      'unread': 2,
    },
    {
      'id': 2,
      'name': 'Pedro Santos',
      'photo': 'P',
      'lastMessage': 'Quando consigo agendar?',
      'time': '09:15',
      'unread': 0,
    },
    {
      'id': 3,
      'name': 'Maria Costa',
      'photo': 'M',
      'lastMessage': 'Quero agendar para semana que vem',
      'time': 'Ontem',
      'unread': 1,
    },
    {
      'id': 4,
      'name': 'Carlos Lima',
      'photo': 'C',
      'lastMessage': 'Ok, até lá',
      'time': 'Ontem',
      'unread': 0,
    },
    {
      'id': 5,
      'name': 'Ana Paula',
      'photo': 'A',
      'lastMessage': 'O serviço ficou ótimo, obrigada',
      'time': 'Seg',
      'unread': 0,
    },
    {
      'id': 6,
      'name': 'Roberto Alves',
      'photo': 'R',
      'lastMessage': 'Posso mudar o horário?',
      'time': 'Seg',
      'unread': 0,
    },
  ];

  List<Map<String, dynamic>> _filteredClients = [];

  @override
  void initState() {
    super.initState();
    _filteredClients = _clients;
    _searchController.addListener(_filterClients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredClients = _clients;
      } else {
        _filteredClients = _clients.where((client) {
          return client['name'].toString().toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            Expanded(child: _buildClientList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        'Clientes',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.darkAlt,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar clientes...',
          hintStyle: TextStyle(color: AppColors.grayField),
          prefixIcon: const Icon(Icons.search, color: AppColors.accent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: AppColors.cardBackground,
        ),
      ),
    );
  }

  Widget _buildClientList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredClients.length,
      itemBuilder: (context, index) {
        final client = _filteredClients[index];
        return _ClientCard(
          name: client['name'],
          photo: client['photo'],
          lastMessage: client['lastMessage'],
          time: client['time'],
          unread: client['unread'],
          onTap: () => _openChat(client),
        );
      },
    );
  }

  void _openChat(Map<String, dynamic> client) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => ShopChatDetailPage(clientName: client['name']),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  final String name;
  final String photo;
  final String lastMessage;
  final String time;
  final int unread;
  final VoidCallback onTap;

  const _ClientCard({
    required this.name,
    required this.photo,
    required this.lastMessage,
    required this.time,
    required this.unread,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              photo,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.darkAlt,
          ),
        ),
        subtitle: Text(
          lastMessage,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(color: AppColors.textMuted, fontSize: 13),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              time,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            if (unread > 0) ...[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$unread',
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
      ),
    );
  }
}

class ShopChatDetailPage extends StatefulWidget {
  final String clientName;

  const ShopChatDetailPage({super.key, required this.clientName});

  @override
  State<ShopChatDetailPage> createState() => _ShopChatDetailPageState();
}

class _ShopChatDetailPageState extends State<ShopChatDetailPage> {
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
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accentLight.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text(
                  widget.clientName[0],
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.clientName,
              style: TextStyle(
                color: AppColors.textBold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
                return _MessageBubble(
                  isMe: isMe,
                  message: message['message'],
                  time: message['time'],
                );
              },
            ),
          ),
          _buildInputArea(),
        ],
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

class _MessageBubble extends StatelessWidget {
  final bool isMe;
  final String message;
  final String time;

  const _MessageBubble({
    required this.isMe,
    required this.message,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
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
}
