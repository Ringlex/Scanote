import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/model/auth/auth_user.dart';
import 'package:note/data/notifications/notification_service.dart';
import 'package:note/data/repository/auth_repository.dart';
import 'package:note/presentation/common/state_type.dart';

part 'auth_bloc.freezed.dart';

part 'auth_event.dart';

part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required DBHelper dbHelper,
    required NotificationService notificationService,
    required AuthRepository authRepository,
  })  : _dbHelper = dbHelper,
        _notificationService = notificationService,
        _authRepository = authRepository,
        super(AuthState.initial()) {
    on<_OnInitiated>(_onInitiated);
    on<_OnSignInRequested>(_onSignInRequested);
    on<_OnGuestRequested>(_onGuestRequested);
    on<_OnSignOutRequested>(_onSignOutRequested);
  }

  final DBHelper _dbHelper;
  final NotificationService _notificationService;
  final AuthRepository _authRepository;

  Future<void> _onInitiated(_OnInitiated event, Emitter<AuthState> emit) async {
    await _dbHelper.initDatabase();
    await _notificationService.init();
    await _notificationService.requestPermissions();

    final session = await _authRepository.restoreSession().run();
    final guest = await _authRepository.readIsGuest().run();

    emit(
      state.copyWith(
        userStateType: StateType.loaded,
        user: session.getOrElse((error) => null),
        isGuest: guest.getOrElse((error) => false),
      ),
    );
  }

  Future<void> _onGuestRequested(_OnGuestRequested event, Emitter<AuthState> emit) async {
    await _authRepository.writeIsGuest(isGuest: true).run();

    emit(state.copyWith(isGuest: true));
  }

  Future<void> _onSignInRequested(_OnSignInRequested event, Emitter<AuthState> emit) async {
    emit(state.copyWith(signInType: StateType.loading));

    final result = await _authRepository.signIn().run();

    result.match(
      (error) => emit(state.copyWith(signInType: StateType.error)),
      (user) => emit(
        state.copyWith(
          signInType: user == null ? StateType.initial : StateType.success,
          user: user,
        ),
      ),
    );
  }

  Future<void> _onSignOutRequested(_OnSignOutRequested event, Emitter<AuthState> emit) async {
    await _authRepository.signOut().run();
    await _authRepository.writeIsGuest(isGuest: false).run();

    emit(
      state.copyWith(
        user: null,
        isGuest: false,
        signInType: StateType.initial,
      ),
    );
  }
}
