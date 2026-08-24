import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

class SpeechService {
  final SpeechToText _speech = SpeechToText();

  bool _isReady = false;
  void Function()? _onStopped;

  static const _listenFor = Duration(minutes: 2);
  static const _pauseFor = Duration(seconds: 4);

  bool get isListening => _speech.isListening;

  Future<bool> prepare() async {
    if (_isReady) {
      return true;
    }

    _isReady = await _speech.initialize(onError: _onError, onStatus: _onStatus);

    return _isReady;
  }

  Future<void> start({
    required void Function(String text, bool isFinal) onResult,
    required void Function() onStopped,
    String? languageCode,
  }) async {
    if (!_isReady) {
      return;
    }

    _onStopped = onStopped;

    await _speech.listen(
      onResult: (result) => onResult(result.recognizedWords, result.finalResult),
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
        listenFor: _listenFor,
        pauseFor: _pauseFor,
        localeId: await _localeIdOf(languageCode),
      ),
    );
  }

  Future<void> stop() async {
    if (_speech.isListening) {
      await _speech.stop();
    }
  }

  Future<String?> _localeIdOf(String? languageCode) async {
    if (languageCode == null || languageCode.isEmpty) {
      return null;
    }

    final tag = languageTagOf(languageCode, await _installedLocaleIds());

    logInfo('Dictating in ${tag ?? 'the phone default locale'}');

    return tag;
  }

  @visibleForTesting
  static String? languageTagOf(String languageCode, List<String> installedLocaleIds) {
    final language = languageCode.toLowerCase();

    final installed = installedLocaleIds.firstWhereOrNull(
      (localeId) => localeId.split(RegExp('[-_]')).first.toLowerCase() == language,
    );

    return (installed ?? _fallbackLocales[language])?.replaceAll('_', '-');
  }

  Future<List<String>> _installedLocaleIds() async {
    try {
      final locales = await _speech.locales();

      return [for (final locale in locales) locale.localeId];
    } catch (error, stackTrace) {
      logInfo('The phone did not say which languages it recognises: $error\n$stackTrace');

      return const [];
    }
  }

  static const _fallbackLocales = {'pl': 'pl_PL', 'en': 'en_US'};

  void _onError(SpeechRecognitionError error) {
    logInfo('Speech recognition stopped: ${error.errorMsg}');

    _notifyStopped();
  }

  void _onStatus(String status) {
    if (!_speech.isListening) {
      _notifyStopped();
    }
  }

  void _notifyStopped() {
    final onStopped = _onStopped;

    _onStopped = null;
    onStopped?.call();
  }
}
