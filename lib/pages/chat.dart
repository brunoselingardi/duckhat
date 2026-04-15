import 'package:flutter/material.dart';
import 'package:duckhat/theme.dart';
import 'package:duckhat/pages/chat_detail.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Map<String, dynamic>> conversations = [
    {
      "name": "Barbearia Vila Nova",
      "image": "barbearia",
      "lastMessage": "Pode vir amanhã às 14h?",
      "time": "10:30",
      "unread": 2,
    },
    {
      "name": "Salão Beleza",
      "image": "salao",
      "lastMessage": "Confirmado!",
      "time": "Ontem",
      "unread": 0,
    },
    {
      "name": "James Salon",
      "image": "jamessalon",
      "lastMessage": "Estaremos te esperando!",
      "time": "Ontem",
      "unread": 0,
    },
    {
      "name": "Barbie Salon",
      "image": "barbiesalon",
      "lastMessage": "Obrigada pela visita!",
      "time": "Semana",
      "unread": 0,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chatBackground,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 12),
            Expanded(child: _buildConversationsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: const Text(
        "Mensagens",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: AppColors.secondary,
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: AppColors.grayField, size: 20),
            const SizedBox(width: 12),
            Text(
              "Buscar conversas",
              style: TextStyle(
                color: AppColors.grayField.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConversationsList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: conversations.length,
      itemBuilder: (context, index) {
        final chat = conversations[index];
        return _buildConversationItem(chat);
      },
    );
  }

  Widget _buildConversationItem(Map<String, dynamic> chat) {
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
                    ChatDetailPage(name: chat["name"], image: chat["image"]),
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
                    color: AppColors.accentLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      chat["name"][0],
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
                        chat["name"],
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        chat["lastMessage"],
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.grayField,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      chat["time"],
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.grayField,
                      ),
                    ),
                    if (chat["unread"] > 0) ...[
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
                          "${chat["unread"]}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
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
