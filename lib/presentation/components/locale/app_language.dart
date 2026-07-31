import 'package:flutter/widgets.dart';

enum AppLanguage {
  system(null),
  english('en'),
  polish('pl');

  const AppLanguage(this.languageCode);

  final String? languageCode;

  Locale? get locale {
    final languageCode = this.languageCode;

    return languageCode == null ? null : Locale(languageCode);
  }

  static AppLanguage of(String? languageCode) => values.firstWhere(
        (language) => language.languageCode == languageCode,
        orElse: () => system,
      );
}
