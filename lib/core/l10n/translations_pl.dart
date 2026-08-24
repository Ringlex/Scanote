// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'translations.dart';

// ignore_for_file: type=lint

/// The translations for Polish (`pl`).
class TranslationsPl extends Translations {
  TranslationsPl([String locale = 'pl']) : super(locale);

  @override
  String get appTitle => 'Scanote';

  @override
  String get splash => 'Ekran startowy';

  @override
  String get commonSave => 'Zapisz';

  @override
  String get commonCancel => 'Anuluj';

  @override
  String get commonClose => 'Zamknij';

  @override
  String get commonDelete => 'Usuń';

  @override
  String get commonShare => 'Udostępnij';

  @override
  String get commonUndo => 'Cofnij';

  @override
  String get backupPassphraseTitle => 'Hasło kopii zapasowej';

  @override
  String get backupPassphraseExportHint =>
      'Tym hasłem zostaną zaszyfrowane chronione notatki przed wysłaniem na Drive. Bez niego nie odczytasz ich na innym telefonie — nikt ich nie odczyta.';

  @override
  String get backupPassphraseImportHint =>
      'Ta kopia zawiera chronione notatki. Podaj hasło, którym zostały zaszyfrowane.';

  @override
  String get backupPassphraseHint => 'Hasło';

  @override
  String get backupPassphraseRepeatHint => 'Powtórz hasło';

  @override
  String backupPassphraseTooShort(int count) {
    return 'Co najmniej $count znaków';
  }

  @override
  String get backupPassphraseMismatch => 'Podane hasła się różnią';

  @override
  String get backupWrongPassphrase => 'To hasło nie otwiera tej kopii';

  @override
  String get homeWriteNote => 'Napisz notatkę';

  @override
  String get noteProtectTextOnly =>
      'Chronić można tylko notatki tekstowe, nie listy zadań.';

  @override
  String get noteProtectPromptTitle => 'Chroniona notatka';

  @override
  String get noteProtectPromptSubtitle =>
      'Potwierdź tożsamość, aby zabezpieczyć tę notatkę';

  @override
  String get noteProtectOpenSubtitle =>
      'Potwierdź tożsamość, aby otworzyć tę notatkę';

  @override
  String get noteProtectUnavailable =>
      'Najpierw ustaw odcisk palca albo blokadę ekranu — bez tego nie ma czym chronić notatki.';

  @override
  String get noteProtectCancelled => 'Notatka pozostaje bez zmian';

  @override
  String get noteProtectKeyLost =>
      'Klucz do tej notatki zniknął z tego telefonu i nie da się go odzyskać. Notatki nie można już odczytać.';

  @override
  String get noteProtectUnreadable =>
      'Ta notatka jest oznaczona jako chroniona, ale jej treść nigdy nie została zaszyfrowana. Otwórz ją w edytorze, wyłącz ochronę i ustaw ją ponownie.';

  @override
  String get noteProtectFailed => 'Nie udało się otworzyć notatki';

  @override
  String noteProtectPinDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count notatki straciły PIN w tej aktualizacji. Zabezpiecz je ponownie, aby zostały naprawdę zaszyfrowane.',
      many:
          '$count notatek straciło PIN w tej aktualizacji. Zabezpiecz je ponownie, aby zostały naprawdę zaszyfrowane.',
      few:
          '$count notatki straciły PIN w tej aktualizacji. Zabezpiecz je ponownie, aby zostały naprawdę zaszyfrowane.',
      one:
          '1 notatka straciła PIN w tej aktualizacji. Zabezpiecz ją ponownie, aby została naprawdę zaszyfrowana.',
    );
    return '$_temp0';
  }

  @override
  String scanPagesTaken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zeskanowano $count strony',
      many: 'Zeskanowano $count stron',
      few: 'Zeskanowano $count strony',
      one: 'Zeskanowano 1 stronę',
    );
    return '$_temp0';
  }

  @override
  String get scanAddPage => 'Zeskanuj kolejną stronę';

  @override
  String get scanFinish => 'To już całość';

  @override
  String get widgetRecentTitle => 'Ostatnie notatki';

  @override
  String get widgetEmpty => 'Brak notatek.';

  @override
  String get noteMovedToBin => 'Notatka przeniesiona do kosza';

  @override
  String get binTitle => 'Kosz';

  @override
  String get binEmpty => 'Kosz jest pusty.';

  @override
  String get binRetentionHint =>
      'Notatki są tu trwale usuwane 30 dni po wyrzuceniu.';

  @override
  String binPurgesIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Znika za $count dni',
      many: 'Znika za $count dni',
      few: 'Znika za $count dni',
      one: 'Znika za 1 dzień',
      zero: 'Znika dziś',
    );
    return '$_temp0';
  }

  @override
  String get binRestore => 'Przywróć';

  @override
  String get binNoteRestored => 'Notatka przywrócona';

  @override
  String get binDeleteForever => 'Usuń trwale';

  @override
  String get binEmptyAction => 'Opróżnij kosz';

  @override
  String get binDeleteForeverTitle => 'Usunąć trwale?';

  @override
  String binDeleteForeverMessage(String title) {
    return '„$title” nie będzie można przywrócić.';
  }

  @override
  String get binEmptyTitle => 'Opróżnić kosz?';

  @override
  String binEmptyMessage(int count) {
    return 'Wszystkie notatki w koszu ($count) zostaną trwale usunięte.';
  }

  @override
  String get homeEmpty =>
      'Nie masz jeszcze notatek. Dotknij aparatu, aby zeskanować kartkę, albo ołówka, aby napisać.';

  @override
  String get homeSearchHint => 'Szukaj w notatkach';

  @override
  String homeSearchEmpty(String query) {
    return 'Nic nie pasuje do „$query”';
  }

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
  String get noteEditorCategoryHint =>
      'Kategoria (nieistniejąca zostanie utworzona)';

  @override
  String get noteEditorContentsHint => 'Napisz notatkę…';

  @override
  String get noteEditorChecklist => 'Lista zadań';

  @override
  String get noteEditorChecklistDescription =>
      'Lista pozycji do odznaczania zamiast notatki tekstowej';

  @override
  String get noteEditorItemHint => 'Pozycja listy';

  @override
  String get noteEditorAddItem => 'Dodaj pozycję';

  @override
  String get noteEditorRemoveItem => 'Usuń pozycję';

  @override
  String get noteEditorDate => 'Data w kalendarzu';

  @override
  String get noteEditorDateNone => 'Nie ustawiono';

  @override
  String get noteEditorDateClear => 'Wyczyść datę';

  @override
  String get noteDeleteTitle => 'Usunąć notatkę?';

  @override
  String noteDeleteMessage(String title) {
    return '„$title” zostanie trwale usunięta.';
  }

  @override
  String get noteEditorSaveError => 'Nie udało się zapisać notatki';

  @override
  String get noteEditorDictate => 'Dyktuj';

  @override
  String get noteEditorDictateStop => 'Zakończ dyktowanie';

  @override
  String get noteEditorDictateListening => 'Słucham…';

  @override
  String get noteEditorDictateUnavailable =>
      'Ten telefon nie zapisze tego, co mówisz';

  @override
  String get noteEditorLock => 'Ochrona notatki';

  @override
  String get noteEditorLockOn =>
      'Zaszyfrowana. Otworzysz ją odciskiem palca lub blokadą ekranu.';

  @override
  String get noteEditorLockOff => 'Notatkę przeczyta każdy, kto ma telefon';

  @override
  String get noteEditorLockRemove => 'Wyłącz ochronę';

  @override
  String get noteLocked => 'Chroniona';

  @override
  String get noteEditorScanTitle => 'Tekst ze zdjęcia';

  @override
  String get noteEditorScanCamera => 'Zrób zdjęcie';

  @override
  String get noteEditorScanGallery => 'Wybierz z galerii';

  @override
  String get noteEditorScanEmpty => 'Nie znaleziono tekstu na tym zdjęciu';

  @override
  String get noteEditorScanError => 'Nie udało się odczytać zdjęcia';

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
  String get noteDetailsDatesFound => 'Daty w tej notatce';

  @override
  String get noteDetailsDateAdded => 'Dodano do kalendarza';

  @override
  String get noteDetailsDateAlreadyAdded => 'Już jest w kalendarzu';

  @override
  String get noteQrShare => 'Udostępnij kodem QR';

  @override
  String get noteQrImport => 'Dodaj z kodu QR';

  @override
  String get noteQrHint =>
      'Zeskanuj ten kod w edytorze notatki na drugim telefonie.';

  @override
  String get noteQrTooLong =>
      'Ta notatka jest za długa, żeby zmieścić ją w kodzie QR.';

  @override
  String get noteQrUnreadable => 'Ten kod nie zawiera notatki';

  @override
  String get noteQrError => 'Nie udało się odczytać zdjęcia';

  @override
  String get noteQrShareFailed => 'Nie udało się udostępnić kodu';

  @override
  String get noteDetailsMissing => 'Ta notatka nie jest już dostępna.';

  @override
  String get noteDetailsEmptyChecklist =>
      'Ta lista nie ma jeszcze żadnych pozycji.';

  @override
  String get favoritesTitle => 'Ulubione';

  @override
  String get favoritesEmpty =>
      'Notatki oznaczone jako ulubione pojawią się tutaj.';

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
  String get eventEditorDeleteMessage =>
      'Wydarzenie i jego przypomnienie zostaną usunięte.';

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
  String get loginSubtitle =>
      'Zaloguj się, aby mieć notatki i wydarzenia zawsze przy sobie.';

  @override
  String get loginGoogleButton => 'Zaloguj się przez Google';

  @override
  String get loginError => 'Logowanie się nie powiodło. Spróbuj ponownie.';

  @override
  String get loginContinueAsGuest => 'Kontynuuj bez konta';

  @override
  String get categoriesAdd => 'Nowa kategoria';

  @override
  String get categoriesRename => 'Zmień nazwę kategorii';

  @override
  String get categoriesNameHint => 'Nazwa kategorii';

  @override
  String get categoriesEmpty =>
      'Nie masz jeszcze kategorii. Dodaj ją tutaj albo wpisz nową nazwę przy notatce.';

  @override
  String get categoriesDuplicate => 'Kategoria o tej nazwie już istnieje';

  @override
  String get categoriesDeleteTitle => 'Usunąć kategorię?';

  @override
  String get categoriesDeleteMessage =>
      'Notatki zostaną, stracą tylko tę kategorię.';

  @override
  String categoriesNoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notatki',
      many: '$count notatek',
      few: '$count notatki',
      one: '1 notatka',
      zero: 'Brak notatek',
    );
    return '$_temp0';
  }

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
  String get settingsThemeLight => 'Jasny';

  @override
  String get settingsThemeDark => 'Ciemny';

  @override
  String get settingsReminders => 'Przypomnienia';

  @override
  String get settingsRemindersOn =>
      'Przypomnienia o wydarzeniach mogą przychodzić';

  @override
  String get settingsRemindersOff =>
      'Powiadomienia są wyłączone, przypomnienia nie dotrą';

  @override
  String get settingsRemindersDenied =>
      'Włącz powiadomienia dla aplikacji Scanote w ustawieniach telefonu';

  @override
  String get settingsExactReminders => 'Przypomnienia co do minuty';

  @override
  String get settingsExactRemindersOff =>
      'Przypomnienia przychodzą teraz w przybliżonym czasie. Dotknij, aby zezwolić na dokładne alarmy.';

  @override
  String get settingsAccount => 'Konto';

  @override
  String get settingsManageAccount => 'Zarządzaj kontem';

  @override
  String get accountTitle => 'Konto';

  @override
  String get accountSignOutDescription => 'Kończy sesję na tym telefonie';

  @override
  String get accountDisconnect => 'Odłącz konto';

  @override
  String get accountDisconnectDescription =>
      'Cofa dostęp przyznany aplikacji Scanote';

  @override
  String get accountDisconnectTitle => 'Odłączyć to konto?';

  @override
  String get accountDisconnectMessage =>
      'Scanote straci dostęp do Twojego profilu Google. Notatki zostaną na tym telefonie.';

  @override
  String get settingsSignOut => 'Wyloguj się';

  @override
  String get settingsGuest => 'Bez konta';

  @override
  String get settingsAbout => 'O aplikacji';

  @override
  String get settingsAppVersion => 'Wersja aplikacji';

  @override
  String get settingsBackup => 'Kopia zapasowa';

  @override
  String get settingsBackupExport => 'Eksportuj na Dysk Google';

  @override
  String get settingsBackupExportDescription =>
      'Zapisuje wszystkie notatki jako plik na Twoim Dysku';

  @override
  String get settingsBackupImport => 'Importuj z Dysku Google';

  @override
  String get settingsBackupImportDescription =>
      'Dodaje notatki z najnowszej kopii';

  @override
  String backupExportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zapisano $count notatki na Dysku Google',
      many: 'Zapisano $count notatek na Dysku Google',
      few: 'Zapisano $count notatki na Dysku Google',
      one: 'Zapisano 1 notatkę na Dysku Google',
      zero: 'Nie było czego zapisać',
    );
    return '$_temp0';
  }

  @override
  String backupImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Dodano $count notatki z kopii',
      many: 'Dodano $count notatek z kopii',
      few: 'Dodano $count notatki z kopii',
      one: 'Dodano 1 notatkę z kopii',
      zero: 'Wszystko z kopii już tu jest',
    );
    return '$_temp0';
  }

  @override
  String get backupNothingFound => 'Nie znaleziono kopii na Twoim Dysku';

  @override
  String get backupError => 'Nie udało się połączyć z Dyskiem Google';

  @override
  String get noteEditorScanImageRemove => 'Usuń to zdjęcie';

  @override
  String noteScanImageCounter(int position, int total) {
    return 'Skan $position z $total';
  }

  @override
  String get noteScanImageMissing => 'Tego zdjęcia już nie ma w telefonie';

  @override
  String get settingsSync => 'Synchronizacja';

  @override
  String get settingsSyncEnabled => 'Synchronizuj między urządzeniami';

  @override
  String get settingsSyncDescription =>
      'Utrzymuje te same notatki na każdym telefonie zalogowanym na to konto Google. Notatki chronione i zdjęcia ze skanów zostają tylko tutaj.';

  @override
  String get settingsSyncNow => 'Synchronizuj teraz';

  @override
  String get settingsSyncNever => 'Jeszcze nie synchronizowano';

  @override
  String get settingsSyncJustNow => 'Zsynchronizowano przed chwilą';

  @override
  String settingsSyncMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zsynchronizowano $count minuty temu',
      many: 'Zsynchronizowano $count minut temu',
      few: 'Zsynchronizowano $count minuty temu',
      one: 'Zsynchronizowano minutę temu',
    );
    return '$_temp0';
  }

  @override
  String settingsSyncHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Zsynchronizowano $count godziny temu',
      many: 'Zsynchronizowano $count godzin temu',
      few: 'Zsynchronizowano $count godziny temu',
      one: 'Zsynchronizowano godzinę temu',
    );
    return '$_temp0';
  }

  @override
  String get settingsSyncUpToDate => 'Wszystko jest już aktualne';

  @override
  String settingsSyncReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notatki przyszły z innych urządzeń',
      many: '$count notatek przyszło z innych urządzeń',
      few: '$count notatki przyszły z innych urządzeń',
      one: '1 notatka przyszła z innego urządzenia',
    );
    return '$_temp0';
  }

  @override
  String get settingsSyncError => 'Nie udało się zsynchronizować notatek';

  @override
  String get checklistCompleted => 'Wszystko odhaczone!';

  @override
  String get homeChecklistCompleted => 'Lista ukończona';
}
