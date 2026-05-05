import 'package:flutter/services.dart';

class ExternalContactLauncher {
  ExternalContactLauncher._();

  static final ExternalContactLauncher instance = ExternalContactLauncher._();
  static const _channel = MethodChannel('duckhat/external_contact');

  Future<void> openWhatsApp(Uri url) async {
    final opened = await _channel.invokeMethod<bool>('openUrl', {
      'url': url.toString(),
    });

    if (opened != true) {
      throw Exception('Nao foi possivel abrir o WhatsApp neste aparelho.');
    }
  }
}
