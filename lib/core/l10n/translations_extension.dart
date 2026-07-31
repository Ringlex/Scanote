import 'package:flutter/widgets.dart';
import 'package:note/core/l10n/translations.dart';

extension TranslationsExtension on BuildContext {
  Translations get translations => Translations.of(this);
}
