import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/model/backup/backup_result.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/model/sync/sync_result.dart';
import 'package:note/data/notifications/notification_service.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/data/repository/backup_repository.dart';
import 'package:note/data/repository/event_repository.dart';
import 'package:note/data/repository/settings_repository.dart';
import 'package:note/data/sync/sync_scheduler.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/settings/settings_argument.dart';

part 'settings_bloc.freezed.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required SettingsArgument argument,
    required BackupRepository backupRepository,
    required NotificationService notificationService,
    required SettingsRepository settingsRepository,
    required SyncScheduler syncScheduler,
    required EventRepository eventRepository,
  }) : _backupRepository = backupRepository,
       _notificationService = notificationService,
       _settingsRepository = settingsRepository,
       _syncScheduler = syncScheduler,
       _eventRepository = eventRepository,
       super(SettingsState.initial(argument: argument)) {
    on<_OnInitiated>(_onInitiated);
    on<_OnNotificationsChecked>(_onNotificationsChecked);
    on<_OnNotificationsRequested>(_onNotificationsRequested);
    on<_OnExactRemindersRequested>(_onExactRemindersRequested);
    on<_OnExportRequested>(_onExportRequested);
    on<_OnImportRequested>(_onImportRequested);
    on<_OnSyncToggled>(_onSyncToggled);
    on<_OnSyncRequested>(_onSyncRequested);
  }

  final BackupRepository _backupRepository;
  final NotificationService _notificationService;
  final SettingsRepository _settingsRepository;
  final SyncScheduler _syncScheduler;
  final EventRepository _eventRepository;

  Future<void> _onInitiated(_OnInitiated event, Emitter<SettingsState> emit) async {
    await _readNotifications(emit);
    await _readSync(emit);
  }

  Future<void> _onNotificationsChecked(_OnNotificationsChecked event, Emitter<SettingsState> emit) async {
    await _readNotifications(emit);
  }

  Future<void> _onNotificationsRequested(_OnNotificationsRequested event, Emitter<SettingsState> emit) async {
    if (!state.isNotificationsEnabled && await _notificationService.requestPermissions()) {
      emit(state.copyWith(isNotificationsEnabled: true));

      return;
    }

    if (await _notificationService.openSystemSettings()) {
      return;
    }

    emit(state.copyWith(isNotificationsDenied: true));
    emit(state.copyWith(isNotificationsDenied: false));
  }

  Future<void> _onExactRemindersRequested(_OnExactRemindersRequested event, Emitter<SettingsState> emit) async {
    await _notificationService.requestExactReminders();
  }

  Future<void> _readNotifications(Emitter<SettingsState> emit) async {
    final wasExact = state.isExactRemindersEnabled;
    final isExact = await _notificationService.canScheduleExactReminders();

    emit(
      state.copyWith(isNotificationsEnabled: await _notificationService.areEnabled(), isExactRemindersEnabled: isExact),
    );

    if (isExact && !wasExact) {
      final rescheduled = await _eventRepository.rescheduleReminders().run();

      rescheduled.match(
        (error) => logSevere('Re-setting reminders after exact alarms were granted failed', error.throwable),
        (count) => logInfo('Re-set $count reminders to the minute'),
      );
    }
  }

  Future<void> _onExportRequested(_OnExportRequested event, Emitter<SettingsState> emit) async {
    await _runBackup(
      emit,
      task: BackupTask.export,
      run: () => _backupRepository.exportToDrive(passphrase: event.passphrase, dataKey: event.dataKey),
    );
  }

  Future<void> _onImportRequested(_OnImportRequested event, Emitter<SettingsState> emit) async {
    await _runBackup(
      emit,
      task: BackupTask.import,
      run: () => _backupRepository.importFromDrive(passphrase: event.passphrase, dataKey: event.dataKey),
    );
  }

  Future<void> _onSyncToggled(_OnSyncToggled event, Emitter<SettingsState> emit) async {
    if (state.isSyncRunning) {
      return;
    }

    if (!event.isEnabled) {
      await _settingsRepository.writeSyncEnabled(isEnabled: false).run();
      emit(state.copyWith(isSyncEnabled: false, lastSyncedAt: null));

      return;
    }

    final result = await _runSync(emit, force: true);

    if (result?.status != SyncStatus.done) {
      return;
    }

    await _settingsRepository.writeSyncEnabled(isEnabled: true).run();
    emit(state.copyWith(isSyncEnabled: true));
  }

  Future<void> _onSyncRequested(_OnSyncRequested event, Emitter<SettingsState> emit) async {
    await _runSync(emit, force: true);
  }

  Future<SyncResult?> _runSync(Emitter<SettingsState> emit, {required bool force}) async {
    if (state.isSyncRunning) {
      return null;
    }

    emit(state.copyWith(syncType: StateType.loading, syncResult: null));

    final result = await _syncScheduler.run(force: force);

    final synced = result.match((error) {
      emit(state.copyWith(syncType: StateType.error));

      return null;
    }, (success) => success);

    if (synced != null) {
      await _readSync(emit);
      emit(state.copyWith(syncType: StateType.success, syncResult: synced));
    }

    emit(state.copyWith(syncType: StateType.initial, syncResult: null));

    return synced;
  }

  Future<void> _readSync(Emitter<SettingsState> emit) async {
    final isEnabled = await _settingsRepository.readSyncEnabled().run();
    final lastSyncedAt = await _settingsRepository.readLastSyncedAt().run();

    emit(
      state.copyWith(
        isSyncEnabled: isEnabled.getOrElse((error) => false),
        lastSyncedAt: lastSyncedAt.getOrElse((error) => null),
      ),
    );
  }

  Future<void> _runBackup(
    Emitter<SettingsState> emit, {
    required BackupTask task,
    required TaskEither<ErrorDetail, BackupResult> Function() run,
  }) async {
    if (state.isBackupRunning) {
      return;
    }

    emit(state.copyWith(backupType: StateType.loading, backupTask: task, backupResult: null));

    final result = await run().run();

    result.match(
      (error) => emit(state.copyWith(backupType: StateType.error)),
      (backup) => emit(state.copyWith(backupType: StateType.success, backupResult: backup)),
    );

    emit(state.copyWith(backupType: StateType.initial, backupResult: null, backupTask: null));
  }
}
