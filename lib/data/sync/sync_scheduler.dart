import 'dart:async';

import 'package:fpdart/fpdart.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/sync/sync_result.dart';
import 'package:note/data/repository/sync_repository.dart';

class SyncScheduler {
  SyncScheduler({required SyncRepository syncRepository}) : _syncRepository = syncRepository;

  final SyncRepository _syncRepository;

  final _results = StreamController<SyncResult>.broadcast();

  Timer? _timer;
  bool _isRunning = false;
  bool _isPending = false;

  static const _quietPeriod = Duration(seconds: 6);

  Stream<SyncResult> get results => _results.stream;

  void schedule() {
    _timer?.cancel();
    _timer = Timer(_quietPeriod, () => unawaited(run()));
  }

  Future<Either<ErrorDetail, SyncResult>> run({bool force = false}) async {
    _timer?.cancel();

    if (_isRunning) {
      _isPending = true;

      return right(const SyncResult.skipped());
    }

    _isRunning = true;

    try {
      final result = await _syncRepository.sync(force: force).run();

      result.match((error) => logSevere('Sync failed', error.throwable, error.stackTrace), (success) {
        if (success.hasChanges) {
          _results.add(success);
        }
      });

      return result;
    } finally {
      _isRunning = false;

      if (_isPending) {
        _isPending = false;
        schedule();
      }
    }
  }

  Future<void> dispose() async {
    _timer?.cancel();
    await _results.close();
  }
}
