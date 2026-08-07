part of 'locale_bloc.dart';

@freezed
abstract class LocaleState with _$LocaleState {
  const factory LocaleState({
    required AppLanguage language,
  }) = _LocaleState;

  const LocaleState._();

  factory LocaleState.initial() => const LocaleState(language: AppLanguage.system);

  Locale? get locale => language.locale;
}
