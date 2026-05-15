import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/notificacao.dart';
import 'duckhat_api.dart';

class ChatNotificationService {
  ChatNotificationService._();

  static final ChatNotificationService instance = ChatNotificationService._();

  final ValueNotifier<int> unreadMessages = ValueNotifier<int>(0);
  final DuckHatApi _api = DuckHatApi.instance;
  Timer? _timer;
  bool _refreshing = false;

  void start() {
    refresh();
    _timer ??= Timer.periodic(const Duration(seconds: 20), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    unreadMessages.value = 0;
  }

  Future<void> refresh() async {
    if (_refreshing || _api.currentSession == null) return;
    _refreshing = true;
    try {
      final notifications = await _api.listarNotificacoes();
      unreadMessages.value = notifications.where(_isUnreadChat).length;
    } catch (_) {
      // Notification polling should not break navigation or chat screens.
    } finally {
      _refreshing = false;
    }
  }

  Future<void> markConversationRead(int conversaId) async {
    if (_api.currentSession == null) return;
    try {
      final notifications = await _api.listarNotificacoes();
      final targets = notifications.where(
        (item) => _isUnreadChat(item) && item.chatConversaId == conversaId,
      );
      for (final notification in targets) {
        await _api.marcarNotificacaoComoLida(notification.id);
      }
      await refresh();
    } catch (_) {
      // Best-effort only; unread state will be corrected on the next refresh.
    }
  }

  bool _isUnreadChat(Notificacao notification) {
    return !notification.lida &&
        (notification.tipo == 'MENSAGEM' ||
            notification.chatConversaId != null);
  }
}
