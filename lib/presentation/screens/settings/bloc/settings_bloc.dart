import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/settings/settings_argument.dart';

part 'settings_bloc.freezed.dart';

part 'settings_event.dart';

part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required SettingsArgument argument,
  }) : super(SettingsState.initial(argument: argument)) {
    on<_OnInitiated>(_onInitiated);
  }

  Future<void> _onInitiated(_OnInitiated event, Emitter<SettingsState> emit) async {}
}
