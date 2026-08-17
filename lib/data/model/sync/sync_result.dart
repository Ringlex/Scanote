import 'package:flutter/foundation.dart';

enum SyncStatus {
  done,

  /// The user backed out of signing in or of granting access to Drive.
  cancelled,

  /// Syncing is switched off, so there was nothing to do.
  disabled,

  /// A pass was already running, and this request folded into the next one.
  skipped,
}

@immutable
class SyncResult {
  const SyncResult({required this.status, this.received = 0, this.sent = 0});

  const SyncResult.cancelled() : status = SyncStatus.cancelled, received = 0, sent = 0;

  const SyncResult.disabled() : status = SyncStatus.disabled, received = 0, sent = 0;

  const SyncResult.skipped() : status = SyncStatus.skipped, received = 0, sent = 0;

  const SyncResult.done({required this.received, required this.sent}) : status = SyncStatus.done;

  final SyncStatus status;

  /// Notes this phone took from the other side, new and updated together.
  final int received;

  /// Notes this phone put on the other side.
  final int sent;

  bool get hasChanges => received > 0 || sent > 0;
}
