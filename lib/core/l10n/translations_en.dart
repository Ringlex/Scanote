// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'translations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class TranslationsEn extends Translations {
  TranslationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Scanote';

  @override
  String get splash => 'Splash';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonClose => 'Close';

  @override
  String get commonDelete => 'Delete';

  @override
  String get commonShare => 'Share';

  @override
  String get commonUndo => 'Undo';

  @override
  String get backupPassphraseTitle => 'Backup passphrase';

  @override
  String get backupPassphraseExportHint =>
      'Your protected notes are sealed with this before they go to Drive. Without it they cannot be read back on another phone — not even by you.';

  @override
  String get backupPassphraseImportHint =>
      'This backup holds protected notes. Give the passphrase they were sealed with.';

  @override
  String get backupPassphraseHint => 'Passphrase';

  @override
  String get backupPassphraseRepeatHint => 'Repeat the passphrase';

  @override
  String backupPassphraseTooShort(int count) {
    return 'At least $count characters';
  }

  @override
  String get backupPassphraseMismatch => 'The two passphrases are different';

  @override
  String get backupWrongPassphrase =>
      'That passphrase does not open this backup';

  @override
  String get homeWriteNote => 'Write a note';

  @override
  String get noteProtectTextOnly =>
      'Only text notes can be protected, not checklists.';

  @override
  String get noteProtectPromptTitle => 'Protected note';

  @override
  String get noteProtectPromptSubtitle => 'Prove it is you to seal this note';

  @override
  String get noteProtectOpenSubtitle => 'Prove it is you to open this note';

  @override
  String get noteProtectUnavailable =>
      'Set up a fingerprint or a screen lock first, so there is something to guard the note with.';

  @override
  String get noteProtectCancelled => 'The note stays as it was';

  @override
  String get noteProtectKeyLost =>
      'The key to this note is gone from this phone and cannot be brought back. The note cannot be read again.';

  @override
  String get noteProtectUnreadable =>
      'This note is marked as protected but its contents were never encrypted. Open it in the editor, turn protection off, and set it again.';

  @override
  String get noteProtectFailed => 'The note could not be opened';

  @override
  String noteProtectPinDropped(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other:
          '$count notes lost their PIN in this update. Protect them again to have them encrypted properly.',
      one:
          '1 note lost its PIN in this update. Protect it again to have it encrypted properly.',
    );
    return '$_temp0';
  }

  @override
  String scanPagesTaken(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count pages scanned',
      one: '1 page scanned',
    );
    return '$_temp0';
  }

  @override
  String get scanAddPage => 'Scan another page';

  @override
  String get scanFinish => 'That is the whole thing';

  @override
  String get widgetRecentTitle => 'Recent notes';

  @override
  String get widgetEmpty => 'No notes yet.';

  @override
  String get noteMovedToBin => 'Note moved to the bin';

  @override
  String get binTitle => 'Bin';

  @override
  String get binEmpty => 'The bin is empty.';

  @override
  String get binRetentionHint =>
      'Notes here are deleted for good 30 days after they were thrown away.';

  @override
  String binPurgesIn(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Goes in $count days',
      one: 'Goes in 1 day',
      zero: 'Goes today',
    );
    return '$_temp0';
  }

  @override
  String get binRestore => 'Restore';

  @override
  String get binNoteRestored => 'Note restored';

  @override
  String get binDeleteForever => 'Delete for good';

  @override
  String get binEmptyAction => 'Empty the bin';

  @override
  String get binDeleteForeverTitle => 'Delete for good?';

  @override
  String binDeleteForeverMessage(String title) {
    return '\"$title\" cannot be brought back.';
  }

  @override
  String get binEmptyTitle => 'Empty the bin?';

  @override
  String binEmptyMessage(int count) {
    return 'All $count notes in the bin will be deleted for good.';
  }

  @override
  String get homeEmpty => 'No notes yet. Tap + to write the first one.';

  @override
  String get homeSearchHint => 'Search notes';

  @override
  String homeSearchEmpty(String query) {
    return 'Nothing matches \"$query\"';
  }

  @override
  String get homeLoadError => 'Your notes could not be loaded.';

  @override
  String homeChecklistProgress(int done, int total) {
    return '$done/$total done';
  }

  @override
  String get noteEditorNewTitle => 'New note';

  @override
  String get noteEditorEditTitle => 'Edit note';

  @override
  String get noteEditorNameHint => 'Note name';

  @override
  String get noteEditorNameRequired => 'Give the note a name';

  @override
  String get noteEditorCategoryHint =>
      'Category (a new one is created when it does not exist)';

  @override
  String get noteEditorContentsHint => 'Write your note…';

  @override
  String get noteEditorChecklist => 'Checklist';

  @override
  String get noteEditorChecklistDescription =>
      'A list of items to tick off instead of a text note';

  @override
  String get noteEditorItemHint => 'List item';

  @override
  String get noteEditorAddItem => 'Add item';

  @override
  String get noteEditorRemoveItem => 'Remove item';

  @override
  String get noteEditorDate => 'Date in the calendar';

  @override
  String get noteEditorDateNone => 'Not set';

  @override
  String get noteEditorDateClear => 'Clear the date';

  @override
  String get noteDeleteTitle => 'Delete note?';

  @override
  String noteDeleteMessage(String title) {
    return '\"$title\" will be removed for good.';
  }

  @override
  String get noteEditorSaveError => 'The note could not be saved';

  @override
  String get noteEditorDictate => 'Dictate';

  @override
  String get noteEditorDictateStop => 'Stop dictating';

  @override
  String get noteEditorDictateListening => 'Listening…';

  @override
  String get noteEditorDictateUnavailable =>
      'This phone cannot write down what you say';

  @override
  String get noteEditorLock => 'Protection';

  @override
  String get noteEditorLockOn =>
      'Encrypted. Your fingerprint or screen lock opens it.';

  @override
  String get noteEditorLockOff => 'Anyone with the phone can read it';

  @override
  String get noteEditorLockRemove => 'Turn protection off';

  @override
  String get noteLocked => 'Protected';

  @override
  String get noteEditorScanTitle => 'Text from a photo';

  @override
  String get noteEditorScanCamera => 'Take a photo';

  @override
  String get noteEditorScanGallery => 'Pick from gallery';

  @override
  String get noteEditorScanEmpty => 'No text was found in that photo';

  @override
  String get noteEditorScanError => 'The photo could not be read';

  @override
  String get noteFormatBold => 'Bold';

  @override
  String get noteFormatItalic => 'Italic';

  @override
  String get noteFormatStrikethrough => 'Strikethrough';

  @override
  String get noteFormatCode => 'Code';

  @override
  String get noteFormatHeading => 'Heading';

  @override
  String get noteFormatBulletList => 'Bullet list';

  @override
  String get noteFormatChecklist => 'Checklist';

  @override
  String get noteDetailsEdit => 'Edit note';

  @override
  String get noteDetailsFavoriteAdd => 'Add to favorites';

  @override
  String get noteDetailsFavoriteRemove => 'Remove from favorites';

  @override
  String get noteDetailsDatesFound => 'Dates in this note';

  @override
  String get noteDetailsDateAdded => 'Added to the calendar';

  @override
  String get noteDetailsDateAlreadyAdded => 'Already in the calendar';

  @override
  String get noteQrShare => 'Share with a QR code';

  @override
  String get noteQrImport => 'Add from a QR code';

  @override
  String get noteQrHint => 'Scan this code in the other phone\'s note editor.';

  @override
  String get noteQrTooLong => 'This note is too long to fit in a QR code.';

  @override
  String get noteQrUnreadable => 'That code does not hold a note';

  @override
  String get noteQrError => 'The photo could not be read';

  @override
  String get noteQrShareFailed => 'The code could not be shared';

  @override
  String get noteDetailsMissing => 'This note is no longer available.';

  @override
  String get noteDetailsEmptyChecklist => 'This checklist has no items yet.';

  @override
  String get favoritesTitle => 'Favorites';

  @override
  String get favoritesEmpty => 'Notes you mark as favorite will show up here.';

  @override
  String get calendarEmpty => 'No events on this day. Tap + to add one.';

  @override
  String get eventEditorNewTitle => 'New event';

  @override
  String get eventEditorEditTitle => 'Edit event';

  @override
  String get eventEditorNameHint => 'Event name';

  @override
  String get eventEditorNameRequired => 'Give the event a name';

  @override
  String get eventEditorDescriptionHint => 'Description (optional)';

  @override
  String get eventEditorDate => 'Date';

  @override
  String get eventEditorTime => 'Time';

  @override
  String get eventEditorDelete => 'Delete event';

  @override
  String get eventEditorDeleteTitle => 'Delete event?';

  @override
  String get eventEditorDeleteMessage =>
      'The event and its reminder will be removed.';

  @override
  String get eventEditorSaveError => 'The event could not be saved';

  @override
  String get reminderNone => 'No reminder';

  @override
  String get reminderAtStart => 'At the time of the event';

  @override
  String get reminderFiveMinutes => '5 minutes before';

  @override
  String get reminderFifteenMinutes => '15 minutes before';

  @override
  String get reminderThirtyMinutes => '30 minutes before';

  @override
  String get reminderOneHour => '1 hour before';

  @override
  String get reminderOneDay => '1 day before';

  @override
  String get loginHeadline => 'Welcome';

  @override
  String get loginSubtitle => 'Sign in to keep your notes and events with you.';

  @override
  String get loginGoogleButton => 'Sign in with Google';

  @override
  String get loginError => 'Signing in failed. Please try again.';

  @override
  String get loginContinueAsGuest => 'Continue without an account';

  @override
  String get categoriesAdd => 'New category';

  @override
  String get categoriesRename => 'Rename category';

  @override
  String get categoriesNameHint => 'Category name';

  @override
  String get categoriesEmpty =>
      'No categories yet. Add one here, or type a new name while writing a note.';

  @override
  String get categoriesDuplicate => 'A category with that name already exists';

  @override
  String get categoriesDeleteTitle => 'Delete category?';

  @override
  String get categoriesDeleteMessage =>
      'The notes stay, they just lose this category.';

  @override
  String categoriesNoteCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes',
      one: '1 note',
      zero: 'No notes',
    );
    return '$_temp0';
  }

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get settingsNotes => 'Notes';

  @override
  String get settingsCategories => 'Categories';

  @override
  String get settingsCategoriesDescription => 'Manage your note categories';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsReminders => 'Reminders';

  @override
  String get settingsRemindersOn => 'Reminders for your events can arrive';

  @override
  String get settingsRemindersOff =>
      'Notifications are off, reminders will not arrive';

  @override
  String get settingsRemindersDenied =>
      'Turn notifications for Scanote back on in your phone\'s settings';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsManageAccount => 'Manage account';

  @override
  String get accountTitle => 'Account';

  @override
  String get accountSignOutDescription => 'Ends the session on this phone';

  @override
  String get accountDisconnect => 'Disconnect';

  @override
  String get accountDisconnectDescription =>
      'Takes back the access granted to Scanote';

  @override
  String get accountDisconnectTitle => 'Disconnect this account?';

  @override
  String get accountDisconnectMessage =>
      'Scanote loses access to your Google profile. Your notes stay on this phone.';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsGuest => 'No account';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAppVersion => 'App version';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get settingsBackupExport => 'Export to Google Drive';

  @override
  String get settingsBackupExportDescription =>
      'Saves all your notes as a file on your Drive';

  @override
  String get settingsBackupImport => 'Import from Google Drive';

  @override
  String get settingsBackupImportDescription =>
      'Adds the notes from the newest backup';

  @override
  String backupExportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes saved to Google Drive',
      one: '1 note saved to Google Drive',
      zero: 'There was nothing to save',
    );
    return '$_temp0';
  }

  @override
  String backupImportDone(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes added from the backup',
      one: '1 note added from the backup',
      zero: 'Everything from the backup is already here',
    );
    return '$_temp0';
  }

  @override
  String get backupNothingFound => 'No backup was found on your Drive';

  @override
  String get backupError => 'Google Drive could not be reached';

  @override
  String get noteEditorScanImageRemove => 'Remove this picture';

  @override
  String noteScanImageCounter(int position, int total) {
    return 'Scan $position of $total';
  }

  @override
  String get noteScanImageMissing => 'This picture is no longer on the phone';

  @override
  String get settingsSync => 'Sync';

  @override
  String get settingsSyncEnabled => 'Sync across devices';

  @override
  String get settingsSyncDescription =>
      'Keeps your notes the same on every phone signed in to this Google account. Protected notes and scanned pictures stay on this phone only.';

  @override
  String get settingsSyncNow => 'Sync now';

  @override
  String get settingsSyncNever => 'Not synced yet';

  @override
  String get settingsSyncJustNow => 'Synced a moment ago';

  @override
  String settingsSyncMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced $count minutes ago',
      one: 'Synced 1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String settingsSyncHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Synced $count hours ago',
      one: 'Synced 1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String get settingsSyncUpToDate => 'Everything is already up to date';

  @override
  String settingsSyncReceived(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count notes came from your other devices',
      one: '1 note came from your other device',
    );
    return '$_temp0';
  }

  @override
  String get settingsSyncError => 'Notes could not be synced';

  @override
  String get checklistCompleted => 'All done!';

  @override
  String get homeChecklistCompleted => 'Checklist finished';
}
