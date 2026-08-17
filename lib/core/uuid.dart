import 'dart:math';

/// A random identifier that survives leaving this phone.
///
/// Row ids cannot: two devices both counting from 1 would hand the same id to
/// different notes, so anything that travels is matched on one of these.
abstract class Uuid {
  const Uuid._();

  static final _random = Random.secure();

  static const _byteCount = 16;
  static const _byteCeiling = 256;

  static const _version = 4;
  static const _versionByte = 6;
  static const _variantByte = 8;

  static const _dashesAfter = {3, 5, 7, 9};

  static String v4() {
    final bytes = List<int>.generate(_byteCount, (_) => _random.nextInt(_byteCeiling));

    bytes[_versionByte] = (bytes[_versionByte] & 0x0f) | (_version << 4);
    bytes[_variantByte] = (bytes[_variantByte] & 0x3f) | 0x80;

    final buffer = StringBuffer();

    for (var index = 0; index < _byteCount; index += 2) {
      buffer.write(bytes[index].toRadixString(16).padLeft(2, '0'));
      buffer.write(bytes[index + 1].toRadixString(16).padLeft(2, '0'));

      if (_dashesAfter.contains(index + 1)) {
        buffer.write('-');
      }
    }

    return buffer.toString();
  }
}
