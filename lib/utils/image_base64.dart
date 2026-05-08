import 'dart:convert';
import 'dart:io';

const int establishmentBannerMaxBytes = 900 * 1024;

Future<String?> encodeImageFileAsBase64(
  File? image, {
  int maxBytes = establishmentBannerMaxBytes,
}) async {
  if (image == null) return null;

  final bytes = await image.readAsBytes();
  if (bytes.length > maxBytes) {
    final maxKb = (maxBytes / 1024).round();
    throw Exception('A imagem precisa ter até $maxKb KB.');
  }

  return base64Encode(bytes);
}
