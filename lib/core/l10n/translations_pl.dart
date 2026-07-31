import 'translations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class TranslationsPl extends Translations {
  TranslationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Note';

  @override
  String get splash => 'Ekran startowy';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get homeEmpty => 'Nie masz jeszcze notatek. Dotknij +, aby napisać pierwszą.';

  @override
  String get homeLoadError => 'Nie udało się wczytać notatek.';

  @override
  String homeChecklistProgress(int done, int total) {
    return '$done/$total zrobione';
  }

  @override
  String get noteEditorNewTitle => 'Nowa notatka';

  @override
  String get noteEditorEditTitle => 'Edytuj notatkę';

  @override
  String get noteEditorNameHint => 'Nazwa notatki';

  @override
  String get noteEditorNameRequired => 'Podaj nazwę notatki';

  @override
  String get noteEditorCategoryHint => 'Kategoria (nieistniejąca zostanie utworzona)';

  @override
  String get noteEditorContentsHint => 'Napisz notatkę…';

  @override
  String get noteEditorChecklist => 'Lista zadań';

  @override
  String get noteEditorChecklistDescription => 'Lista pozycji do odznaczania zamiast notatki tekstowej';

  @override
  String get noteEditorItemHint => 'Pozycja listy';

  @override
  String get noteEditorAddItem => 'Dodaj pozycję';

  @override
  String get noteEditorRemoveItem => 'Usuń pozycję';

  @override
  String get noteEditorSaveError => 'Nie udało się zapisać notatki';

  @override
  String get noteFormatBold => 'Pogrubienie';

  @override
  String get noteFormatItalic => 'Kursywa';

  @override
  String get noteFormatStrikethrough => 'Przekreślenie';

  @override
  String get noteFormatCode => 'Kod';

  @override
  String get noteFormatHeading => 'Nagłówek';

  @override
  String get noteFormatBulletList => 'Lista punktowana';

  @override
  String get noteFormatChecklist => 'Lista zadań';

  @override
  String get noteDetailsEdit => 'Edytuj notatkę';

  @override
  String get noteDetailsFavoriteAdd => 'Dodaj do ulubionych';

  @override
  String get noteDetailsFavoriteRemove => 'Usuń z ulubionych';

  @override
  String get noteDetailsMissing => 'Ta notatka nie jest już dostępna.';

  @override
  String get noteDetailsEmptyChecklist => 'Ta lista nie ma jeszcze żadnych pozycji.';

  @override
  String get favoritesTitle => 'Ulubione';

  @override
  String get favoritesEmpty => 'Notatki oznaczone jako ulubione pojawią się tutaj.';

  @override
  String get calendarEmpty => 'Brak wydarzeń tego dnia. Dotknij +, aby dodać.';

  @override
  String get eventEditorNewTitle => 'Nowe wydarzenie';

  @override
  String get eventEditorEditTitle => 'Edytuj wydarzenie';

  @override
  String get eventEditorNameHint => 'Nazwa wydarzenia';

  @override
  String get eventEditorNameRequired => 'Podaj nazwę wydarzenia';

  @override
  String get eventEditorDescriptionHint => 'Opis (opcjonalnie)';

  @override
  String get eventEditorDate => 'Data';

  @override
  String get eventEditorTime => 'Godzina';

  @override
  String get eventEditorDelete => 'Usuń wydarzenie';

  @override
  String get eventEditorDeleteTitle => 'Usunąć wydarzenie?';

  @override
  String get eventEditorDeleteMessage => 'Wydarzenie i jego przypomnienie zostaną usunięte.';

  @override
  String get eventEditorSaveError => 'Nie udało się zapisać wydarzenia';

  @override
  String get reminderNone => 'Bez przypomnienia';

  @override
  String get reminderAtStart => 'W czasie wydarzenia';

  @override
  String get reminderFiveMinutes => '5 minut wcześniej';

  @override
  String get reminderFifteenMinutes => '15 minut wcześniej';

  @override
  String get reminderThirtyMinutes => '30 minut wcześniej';

  @override
  String get reminderOneHour => 'Godzinę wcześniej';

  @override
  String get reminderOneDay => 'Dzień wcześniej';

  @override
  String get loginHeadline => 'Witaj';

  @override
  String get loginSubtitle => 'Zaloguj się, aby mieć notatki i wydarzenia zawsze przy sobie.';

  @override
  String get loginGoogleButton => 'Zaloguj się przez Google';

  @override
  String get loginError => 'Logowanie się nie powiodło. Spróbuj ponownie.';

  @override
  String get loginContinueAsGuest => 'Kontynuuj bez konta';

  @override
  String get settingsTitle => 'Ustawienia';

  @override
  String get settingsAppearance => 'Wygląd';

  @override
  String get settingsTheme => 'Motyw';

  @override
  String get settingsThemeSystem => 'Systemowy';

  @override
  String get settingsLanguage => 'Język';

  @override
  String get settingsLanguageSystem => 'Język systemu';

  @override
  String get settingsNotes => 'Notatki';

  @override
  String get settingsCategories => 'Kategorie';

  @override
  String get settingsCategoriesDescription => 'Zarządzaj kategoriami notatek';

  @override
  String get settingsReminders => 'Przypomnienia';

  @override
  String get settingsRemindersDescription => 'Powiadomienia o notatkach';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsSignOut => 'Wyloguj się';

  @override
  String get settingsGuest => 'Bez konta';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String get settingsAppVersion => 'Wersja aplikacji';
}
