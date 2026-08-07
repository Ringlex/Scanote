import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/model/backup/backup_result.dart';
import 'package:note/data/model/error_detail.dart';
import 'package:note/data/notifications/notification_service.dart';
import 'package:note/data/repository/backup_repository.dart';
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
  }) : _backupRepository = backupRepository,
       _notificationService = notificationService,
       super(SettingsState.initial(argument: argument)) {
    on<_OnInitiated>(_onInitiated);
    on<_OnNotificationsChecked>(_onNotificationsChecked);
    on<_OnNotificationsRequested>(_onNotificationsRequested);
    on<_OnExportRequested>(_onExportRequested);
    on<_OnImportRequested>(_onImportRequested);
  }

  final BackupRepository _backupRepository;
  final NotificationService _notificationService;

  Future<void> _onInitiated(_OnInitiated event, Emitter<SettingsState> emit) async {
    await _readNotifications(emit);
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

  Future<void> _readNotifications(Emitter<SettingsState> emit) async {
    emit(state.copyWith(isNotificationsEnabled: await _notificationService.areEnabled()));
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
