import 'dart:convert';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';

abstract class NoteCipher {
  const NoteCipher._();

  static final _algorithm = AesGcm.with256bits();

  static const _nonceBytes = 12;
  static const _macBytes = 16;
  static const _saltBytes = 16;

  static const _version = 1;

  static const _iterations = 210000;

  static const keyBytes = 32;

  static Future<List<int>> newKey() async {
    final key = await _algorithm.newSecretKey();

    return key.extractBytes();
  }

  static Future<String> encrypt({required String plainText, required List<int> key}) async {
    final box = await _algorithm.encrypt(utf8.encode(plainText), secretKey: SecretKey(key));

    return base64Encode([_version, ...box.nonce, ...box.mac.bytes, ...box.cipherText]);
  }

  static Future<String> decrypt({required String payload, required List<int> key}) async {
    final raw = base64Decode(payload);

    if (raw.isEmpty || raw.first != _version) {
      throw const FormatException('The stored value was not written by this version');
    }

    const start = 1;

    if (raw.length <= start + _nonceBytes + _macBytes) {
      throw const FormatException('The stored value is too short to hold a note');
    }

    final box = SecretBox(
      raw.sublist(start + _nonceBytes + _macBytes),
      nonce: raw.sublist(start, start + _nonceBytes),
      mac: Mac(raw.sublist(start + _nonceBytes, start + _nonceBytes + _macBytes)),
    );

    return utf8.decode(await _algorithm.decrypt(box, secretKey: SecretKey(key)));
  }

  static Future<List<int>> keyFromPassphrase({required String passphrase, required List<int> salt}) async {
    final algorithm = Pbkdf2(macAlgorithm: Hmac.sha256(), iterations: _iterations, bits: keyBytes * 8);

    final key = await algorithm.deriveKey(secretKey: SecretKey(utf8.encode(passphrase)), nonce: salt);

    return key.extractBytes();
  }

  static Uint8List newSalt() {
    final random = SecretKeyData.random(length: _saltBytes);

    return Uint8List.fromList(random.bytes);
  }
}
