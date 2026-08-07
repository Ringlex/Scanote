part of 'locale_bloc.dart';

@freezed
sealed class LocaleEvent with _$LocaleEvent {
  const factory LocaleEvent.onInitiated() = _OnInitiated;

  const factory LocaleEvent.onLanguageChanged({required AppLanguage language}) = _OnLanguageChanged;
}
