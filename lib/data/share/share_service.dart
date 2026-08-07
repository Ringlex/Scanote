import 'package:flutter/services.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/data/share/shared_text.dart';

class ShareService {
  static const _channel = MethodChannel('io.robert.note/share');
  static const _consumeMethod = 'consumeSharedText';

  static const _textKey = 'text';
  static const _subjectKey = 'subject';

  Future<SharedText?> consume() async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(_consumeMethod);
      final text = result?[_textKey] as String?;

      if (text == null || text.trim().isEmpty) {
        return null;
      }

      return SharedText(text: text, subject: result?[_subjectKey] as String?);
    } on PlatformException catch (error, stackTrace) {
      logSevere('Reading the shared text failed', error, stackTrace);

      return null;
    } on MissingPluginException catch (error, stackTrace) {
      logInfo('The platform does not answer $_consumeMethod', error, stackTrace);

      return null;
    }
  }
}
