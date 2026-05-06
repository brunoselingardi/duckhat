import 'package:duckhat/pages/chat.dart';
import 'package:flutter/material.dart';

class ShopClientsPage extends StatelessWidget {
  const ShopClientsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const ChatPage(
      title: 'Chat',
      searchHint: 'Buscar clientes',
      emptyTitle: 'Nenhuma conversa com clientes',
      emptyMessage:
          'Quando um cliente abrir uma conversa pelo perfil do estabelecimento, ela aparecera aqui.',
    );
  }
}
