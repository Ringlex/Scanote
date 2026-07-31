import 'translations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class TranslationsEn extends Translations {
  TranslationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Note';

  @override
  String get splash => 'Splash';

  @override
  String get commonSave => 'Save';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonDelete => 'Delete';

  @override
  String get homeEmpty => 'No notes yet. Tap + to write the first one.';

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
  String get noteEditorCategoryHint => 'Category (a new one is created when it does not exist)';

  @override
  String get noteEditorContentsHint => 'Write your note…';

  @override
  String get noteEditorChecklist => 'Checklist';

  @override
  String get noteEditorChecklistDescription => 'A list of items to tick off instead of a text note';

  @override
  String get noteEditorItemHint => 'List item';

  @override
  String get noteEditorAddItem => 'Add item';

  @override
  String get noteEditorRemoveItem => 'Remove item';

  @override
  String get noteEditorSaveError => 'The note could not be saved';

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
  String get eventEditorDeleteMessage => 'The event and its reminder will be removed.';

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
  String get settingsReminders => 'Reminders';

  @override
  String get settingsRemindersDescription => 'Notifications for your notes';

  @override
  String get settingsAccount => 'Account';

  @override
  String get settingsSignOut => 'Sign out';

  @override
  String get settingsGuest => 'No account';

  @override
  String get settingsAbout => 'About';

  @override
  String get settingsAppVersion => 'App version';
}
