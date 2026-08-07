import 'package:flutter_test/flutter_test.dart';
import 'package:note/data/speech/speech_service.dart';

void main() {
  group('SpeechService.languageTagOf', () {
    test('hands back an IETF tag, never the underscored form', () {
      // Android drops an underscored locale on the floor and keeps listening
      // in the language the phone is set to.
      expect(SpeechService.languageTagOf('pl', ['en_US', 'pl_PL']), 'pl-PL');
      expect(SpeechService.languageTagOf('pl', ['pl-PL']), 'pl-PL');
    });

    test('falls back to a known locale when the phone lists none', () {
      expect(SpeechService.languageTagOf('pl', const []), 'pl-PL');
      expect(SpeechService.languageTagOf('en', const []), 'en-US');
    });

    test('prefers what the phone actually has over the fallback', () {
      expect(SpeechService.languageTagOf('en', ['en_GB']), 'en-GB');
    });

    test('leaves the choice to the phone for a language the app does not speak', () {
      expect(SpeechService.languageTagOf('de', const []), isNull);
    });

    test('reads the language off the locale, not the whole string', () {
      // 'plt' is Malagasy - a prefix match would take it for Polish.
      expect(SpeechService.languageTagOf('pl', ['plt_MG']), 'pl-PL');
    });
  });
}
