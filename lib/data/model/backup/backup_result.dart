import 'package:flutter/foundation.dart';

enum BackupStatus { done, cancelled, nothingFound, passphraseNeeded, wrongPassphrase }

@immutable
class BackupResult {
  const BackupResult({required this.status, this.noteCount = 0});

  const BackupResult.cancelled() : status = BackupStatus.cancelled, noteCount = 0;

  const BackupResult.nothingFound() : status = BackupStatus.nothingFound, noteCount = 0;

  const BackupResult.passphraseNeeded() : status = BackupStatus.passphraseNeeded, noteCount = 0;

  const BackupResult.wrongPassphrase() : status = BackupStatus.wrongPassphrase, noteCount = 0;

  const BackupResult.done({required this.noteCount}) : status = BackupStatus.done;

  final BackupStatus status;

  final int noteCount;
}
