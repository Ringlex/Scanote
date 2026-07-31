import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:note/data/repository/settings_repository.dart';
import 'package:note/presentation/components/locale/app_language.dart';

part 'locale_bloc.freezed.dart';

part 'locale_event.dart';

part 'locale_state.dart';

class LocaleBloc extends Bloc<LocaleEvent, LocaleState> {
  LocaleBloc({
    required SettingsRepository settingsRepository,
  })  : _settingsRepository = settingsRepository,
        super(LocaleState.initial()) {
    on<_OnInitiated>(_onInitiated);
    on<_OnLanguageChanged>(_onLanguageChanged);
  }

  final SettingsRepository _settingsRepository;

  Future<void> _onInitiated(_OnInitiated event, Emitter<LocaleState> emit) async {
    final result = await _settingsRepository.readLanguageCode().run();

    result.match(
      (error) => emit(state.copyWith(language: AppLanguage.system)),
      (languageCode) => emit(state.copyWith(language: AppLanguage.of(languageCode))),
    );
  }

  Future<void> _onLanguageChanged(_OnLanguageChanged event, Emitter<LocaleState> emit) async {
    emit(state.copyWith(language: event.language));

    await _settingsRepository.writeLanguageCode(event.language.languageCode).run();
  }
}
