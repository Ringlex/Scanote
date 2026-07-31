import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'translations_en.dart';
import 'translations_pl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of Translations
/// returned by `Translations.of(context)`.
///
/// Applications need to include `Translations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/translations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: Translations.localizationsDelegates,
///   supportedLocales: Translations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the Translations.supportedLocales
/// property.
abstract class Translations {
  Translations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations)!;
  }

  static const LocalizationsDelegate<Translations> delegate = _TranslationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl')
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get appTitle;

  /// Splash screen name
  ///
  /// In en, this message translates to:
  /// **'Splash'**
  String get splash;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Tap + to write the first one.'**
  String get homeEmpty;

  /// No description provided for @homeLoadError.
  ///
  /// In en, this message translates to:
  /// **'Your notes could not be loaded.'**
  String get homeLoadError;

  /// How many checklist items of a note are ticked off
  ///
  /// In en, this message translates to:
  /// **'{done}/{total} done'**
  String homeChecklistProgress(int done, int total);

  /// No description provided for @noteEditorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New note'**
  String get noteEditorNewTitle;

  /// No description provided for @noteEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get noteEditorEditTitle;

  /// No description provided for @noteEditorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Note name'**
  String get noteEditorNameHint;

  /// No description provided for @noteEditorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the note a name'**
  String get noteEditorNameRequired;

  /// No description provided for @noteEditorCategoryHint.
  ///
  /// In en, this message translates to:
  /// **'Category (a new one is created when it does not exist)'**
  String get noteEditorCategoryHint;

  /// No description provided for @noteEditorContentsHint.
  ///
  /// In en, this message translates to:
  /// **'Write your note…'**
  String get noteEditorContentsHint;

  /// No description provided for @noteEditorChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get noteEditorChecklist;

  /// No description provided for @noteEditorChecklistDescription.
  ///
  /// In en, this message translates to:
  /// **'A list of items to tick off instead of a text note'**
  String get noteEditorChecklistDescription;

  /// No description provided for @noteEditorItemHint.
  ///
  /// In en, this message translates to:
  /// **'List item'**
  String get noteEditorItemHint;

  /// No description provided for @noteEditorAddItem.
  ///
  /// In en, this message translates to:
  /// **'Add item'**
  String get noteEditorAddItem;

  /// No description provided for @noteEditorRemoveItem.
  ///
  /// In en, this message translates to:
  /// **'Remove item'**
  String get noteEditorRemoveItem;

  /// No description provided for @noteEditorSaveError.
  ///
  /// In en, this message translates to:
  /// **'The note could not be saved'**
  String get noteEditorSaveError;

  /// No description provided for @noteFormatBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get noteFormatBold;

  /// No description provided for @noteFormatItalic.
  ///
  /// In en, this message translates to:
  /// **'Italic'**
  String get noteFormatItalic;

  /// No description provided for @noteFormatStrikethrough.
  ///
  /// In en, this message translates to:
  /// **'Strikethrough'**
  String get noteFormatStrikethrough;

  /// No description provided for @noteFormatCode.
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get noteFormatCode;

  /// No description provided for @noteFormatHeading.
  ///
  /// In en, this message translates to:
  /// **'Heading'**
  String get noteFormatHeading;

  /// No description provided for @noteFormatBulletList.
  ///
  /// In en, this message translates to:
  /// **'Bullet list'**
  String get noteFormatBulletList;

  /// No description provided for @noteFormatChecklist.
  ///
  /// In en, this message translates to:
  /// **'Checklist'**
  String get noteFormatChecklist;

  /// No description provided for @noteDetailsEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit note'**
  String get noteDetailsEdit;

  /// No description provided for @noteDetailsFavoriteAdd.
  ///
  /// In en, this message translates to:
  /// **'Add to favorites'**
  String get noteDetailsFavoriteAdd;

  /// No description provided for @noteDetailsFavoriteRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove from favorites'**
  String get noteDetailsFavoriteRemove;

  /// No description provided for @noteDetailsMissing.
  ///
  /// In en, this message translates to:
  /// **'This note is no longer available.'**
  String get noteDetailsMissing;

  /// No description provided for @noteDetailsEmptyChecklist.
  ///
  /// In en, this message translates to:
  /// **'This checklist has no items yet.'**
  String get noteDetailsEmptyChecklist;

  /// No description provided for @favoritesTitle.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get favoritesTitle;

  /// No description provided for @favoritesEmpty.
  ///
  /// In en, this message translates to:
  /// **'Notes you mark as favorite will show up here.'**
  String get favoritesEmpty;

  /// No description provided for @calendarEmpty.
  ///
  /// In en, this message translates to:
  /// **'No events on this day. Tap + to add one.'**
  String get calendarEmpty;

  /// No description provided for @eventEditorNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New event'**
  String get eventEditorNewTitle;

  /// No description provided for @eventEditorEditTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit event'**
  String get eventEditorEditTitle;

  /// No description provided for @eventEditorNameHint.
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get eventEditorNameHint;

  /// No description provided for @eventEditorNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Give the event a name'**
  String get eventEditorNameRequired;

  /// No description provided for @eventEditorDescriptionHint.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get eventEditorDescriptionHint;

  /// No description provided for @eventEditorDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get eventEditorDate;

  /// No description provided for @eventEditorTime.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get eventEditorTime;

  /// No description provided for @eventEditorDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete event'**
  String get eventEditorDelete;

  /// No description provided for @eventEditorDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete event?'**
  String get eventEditorDeleteTitle;

  /// No description provided for @eventEditorDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The event and its reminder will be removed.'**
  String get eventEditorDeleteMessage;

  /// No description provided for @eventEditorSaveError.
  ///
  /// In en, this message translates to:
  /// **'The event could not be saved'**
  String get eventEditorSaveError;

  /// No description provided for @reminderNone.
  ///
  /// In en, this message translates to:
  /// **'No reminder'**
  String get reminderNone;

  /// No description provided for @reminderAtStart.
  ///
  /// In en, this message translates to:
  /// **'At the time of the event'**
  String get reminderAtStart;

  /// No description provided for @reminderFiveMinutes.
  ///
  /// In en, this message translates to:
  /// **'5 minutes before'**
  String get reminderFiveMinutes;

  /// No description provided for @reminderFifteenMinutes.
  ///
  /// In en, this message translates to:
  /// **'15 minutes before'**
  String get reminderFifteenMinutes;

  /// No description provided for @reminderThirtyMinutes.
  ///
  /// In en, this message translates to:
  /// **'30 minutes before'**
  String get reminderThirtyMinutes;

  /// No description provided for @reminderOneHour.
  ///
  /// In en, this message translates to:
  /// **'1 hour before'**
  String get reminderOneHour;

  /// No description provided for @reminderOneDay.
  ///
  /// In en, this message translates to:
  /// **'1 day before'**
  String get reminderOneDay;

  /// No description provided for @loginHeadline.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get loginHeadline;

  /// No description provided for @loginSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sign in to keep your notes and events with you.'**
  String get loginSubtitle;

  /// No description provided for @loginGoogleButton.
  ///
  /// In en, this message translates to:
  /// **'Sign in with Google'**
  String get loginGoogleButton;

  /// No description provided for @loginError.
  ///
  /// In en, this message translates to:
  /// **'Signing in failed. Please try again.'**
  String get loginError;

  /// No description provided for @loginContinueAsGuest.
  ///
  /// In en, this message translates to:
  /// **'Continue without an account'**
  String get loginContinueAsGuest;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @settingsAppearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get settingsAppearance;

  /// No description provided for @settingsTheme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// No description provided for @settingsThemeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// No description provided for @settingsLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// No description provided for @settingsLanguageSystem.
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get settingsLanguageSystem;

  /// No description provided for @settingsNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get settingsNotes;

  /// No description provided for @settingsCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get settingsCategories;

  /// No description provided for @settingsCategoriesDescription.
  ///
  /// In en, this message translates to:
  /// **'Manage your note categories'**
  String get settingsCategoriesDescription;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// No description provided for @settingsRemindersDescription.
  ///
  /// In en, this message translates to:
  /// **'Notifications for your notes'**
  String get settingsRemindersDescription;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsSignOut.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get settingsSignOut;

  /// No description provided for @settingsGuest.
  ///
  /// In en, this message translates to:
  /// **'No account'**
  String get settingsGuest;

  /// No description provided for @settingsAbout.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settingsAbout;

  /// No description provided for @settingsAppVersion.
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get settingsAppVersion;
}

class _TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const _TranslationsDelegate();

  @override
  Future<Translations> load(Locale locale) {
    return SynchronousFuture<Translations>(lookupTranslations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_TranslationsDelegate old) => false;
}

Translations lookupTranslations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return TranslationsEn();
    case 'pl': return TranslationsPl();
  }

  throw FlutterError(
    'Translations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
