import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/protection/note_cipher.dart';

void main() {
  group('NoteCipher', () {
    test('gives back exactly what was encrypted', () async {
      final key = await NoteCipher.newKey();
      const plainText = 'Numer konta: 12 3456 7890\nHasło do routera: literki';

      final sealed = await NoteCipher.encrypt(plainText: plainText, key: key);

      expect(await NoteCipher.decrypt(payload: sealed, key: key), plainText);
    });

    test('holds Polish letters and emoji, not just ASCII', () async {
      final key = await NoteCipher.newKey();
      const plainText = 'Zażółć gęślą jaźń 🔒 — myślnik';

      final sealed = await NoteCipher.encrypt(plainText: plainText, key: key);

      expect(await NoteCipher.decrypt(payload: sealed, key: key), plainText);
    });

    test('never stores the text in a readable form', () async {
      final key = await NoteCipher.newKey();
      const plainText = 'tajne hasło';

      final sealed = await NoteCipher.encrypt(plainText: plainText, key: key);

      expect(sealed, isNot(contains('tajne')));
      expect(utf8.decode(base64Decode(sealed), allowMalformed: true), isNot(contains('tajne')));
    });

    test('encrypting twice gives two different results, so repeats do not show', () async {
      final key = await NoteCipher.newKey();
      const plainText = 'ta sama treść';

      final first = await NoteCipher.encrypt(plainText: plainText, key: key);
      final second = await NoteCipher.encrypt(plainText: plainText, key: key);

      expect(first, isNot(second));
    });

    test('turns down the wrong key rather than handing back rubbish', () async {
      final key = await NoteCipher.newKey();
      final other = await NoteCipher.newKey();

      final sealed = await NoteCipher.encrypt(plainText: 'treść', key: key);

      expect(
        () => NoteCipher.decrypt(payload: sealed, key: other),
        throwsA(isA<Exception>()),
      );
    });

    test('notices text that was tampered with', () async {
      final key = await NoteCipher.newKey();
      final sealed = await NoteCipher.encrypt(plainText: 'treść', key: key);

      // Flip the last byte of the ciphertext.
      final raw = base64Decode(sealed);
      raw[raw.length - 1] = raw[raw.length - 1] ^ 0xFF;

      expect(
        () => NoteCipher.decrypt(payload: base64Encode(raw), key: key),
        throwsA(isA<Exception>()),
      );
    });

    test('stamps a version on the front, so a later format can be told apart', () async {
      final key = await NoteCipher.newKey();
      final sealed = await NoteCipher.encrypt(plainText: 'treść', key: key);

      expect(base64Decode(sealed).first, 1);
    });

    test('turns down a payload some other scheme wrote, rather than blaming the key', () async {
      final key = await NoteCipher.newKey();

      // What the old native scheme produced: iv, ciphertext, tag, no version.
      // It is the same length and shape as ours, which is exactly why the
      // version byte has to be there.
      final legacy = base64Encode(List.filled(46, 7));

      await expectLater(
        () => NoteCipher.decrypt(payload: legacy, key: key),
        throwsA(isA<FormatException>()),
      );
    });

    test('turns down a value too short to be one of ours', () async {
      final key = await NoteCipher.newKey();

      expect(
        () => NoteCipher.decrypt(payload: base64Encode([1, 2, 3]), key: key),
        throwsA(isA<FormatException>()),
      );
    });

    test('makes a key of the length AES-256 wants, and a new one each time', () async {
      final first = await NoteCipher.newKey();
      final second = await NoteCipher.newKey();

      expect(first, hasLength(NoteCipher.keyBytes));
      expect(first, isNot(second));
    });
  });

  group('NoteCipher.keyFromPassphrase', () {
    test('the same passphrase and salt always give the same key', () async {
      final salt = NoteCipher.newSalt();

      final first = await NoteCipher.keyFromPassphrase(passphrase: 'moje hasło', salt: salt);
      final second = await NoteCipher.keyFromPassphrase(passphrase: 'moje hasło', salt: salt);

      expect(first, second);
    });

    test('a different salt gives a different key, so one guess cannot answer for every backup', () async {
      final first = await NoteCipher.keyFromPassphrase(
        passphrase: 'moje hasło',
        salt: NoteCipher.newSalt(),
      );
      final second = await NoteCipher.keyFromPassphrase(
        passphrase: 'moje hasło',
        salt: NoteCipher.newSalt(),
      );

      expect(first, isNot(second));
    });

    test('a different passphrase gives a different key', () async {
      final salt = NoteCipher.newSalt();

      final first = await NoteCipher.keyFromPassphrase(passphrase: 'jedno', salt: salt);
      final second = await NoteCipher.keyFromPassphrase(passphrase: 'drugie', salt: salt);

      expect(first, isNot(second));
    });

    test('the derived key opens what it sealed', () async {
      final salt = NoteCipher.newSalt();
      final key = await NoteCipher.keyFromPassphrase(passphrase: 'hasło do kopii', salt: salt);

      final sealed = await NoteCipher.encrypt(plainText: 'notatka z kopii', key: key);
      final again = await NoteCipher.keyFromPassphrase(passphrase: 'hasło do kopii', salt: salt);

      expect(await NoteCipher.decrypt(payload: sealed, key: again), 'notatka z kopii');
    });

    test('salts are not repeated', () {
      final salts = {for (var i = 0; i < 20; i++) base64Encode(NoteCipher.newSalt())};

      expect(salts, hasLength(20));
    });
  });
}
