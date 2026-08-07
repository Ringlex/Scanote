import 'package:flutter/widgets.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/data/protection/note_protection_service.dart';

String protectionMessage(BuildContext context, ProtectionFailure failure) => switch (failure) {
  ProtectionFailure.unavailable => context.translations.noteProtectUnavailable,
  ProtectionFailure.cancelled => context.translations.noteProtectCancelled,
  ProtectionFailure.keyLost => context.translations.noteProtectKeyLost,
  ProtectionFailure.failed => context.translations.noteProtectFailed,
};
