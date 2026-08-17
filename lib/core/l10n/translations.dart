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
  Translations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static Translations of(BuildContext context) {
    return Localizations.of<Translations>(context, Translations)!;
  }

  static const LocalizationsDelegate<Translations> delegate =
      _TranslationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pl'),
  ];

  /// App name
  ///
  /// In en, this message translates to:
  /// **'Scanote'**
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

  /// No description provided for @commonClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get commonClose;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @commonShare.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get commonShare;

  /// No description provided for @commonUndo.
  ///
  /// In en, this message translates to:
  /// **'Undo'**
  String get commonUndo;

  /// No description provided for @backupPassphraseTitle.
  ///
  /// In en, this message translates to:
  /// **'Backup passphrase'**
  String get backupPassphraseTitle;

  /// No description provided for @backupPassphraseExportHint.
  ///
  /// In en, this message translates to:
  /// **'Your protected notes are sealed with this before they go to Drive. Without it they cannot be read back on another phone — not even by you.'**
  String get backupPassphraseExportHint;

  /// No description provided for @backupPassphraseImportHint.
  ///
  /// In en, this message translates to:
  /// **'This backup holds protected notes. Give the passphrase they were sealed with.'**
  String get backupPassphraseImportHint;

  /// No description provided for @backupPassphraseHint.
  ///
  /// In en, this message translates to:
  /// **'Passphrase'**
  String get backupPassphraseHint;

  /// No description provided for @backupPassphraseRepeatHint.
  ///
  /// In en, this message translates to:
  /// **'Repeat the passphrase'**
  String get backupPassphraseRepeatHint;

  /// No description provided for @backupPassphraseTooShort.
  ///
  /// In en, this message translates to:
  /// **'At least {count} characters'**
  String backupPassphraseTooShort(int count);

  /// No description provided for @backupPassphraseMismatch.
  ///
  /// In en, this message translates to:
  /// **'The two passphrases are different'**
  String get backupPassphraseMismatch;

  /// No description provided for @backupWrongPassphrase.
  ///
  /// In en, this message translates to:
  /// **'That passphrase does not open this backup'**
  String get backupWrongPassphrase;

  /// No description provided for @homeWriteNote.
  ///
  /// In en, this message translates to:
  /// **'Write a note'**
  String get homeWriteNote;

  /// No description provided for @noteProtectTextOnly.
  ///
  /// In en, this message translates to:
  /// **'Only text notes can be protected, not checklists.'**
  String get noteProtectTextOnly;

  /// No description provided for @noteProtectPromptTitle.
  ///
  /// In en, this message translates to:
  /// **'Protected note'**
  String get noteProtectPromptTitle;

  /// No description provided for @noteProtectPromptSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prove it is you to seal this note'**
  String get noteProtectPromptSubtitle;

  /// No description provided for @noteProtectOpenSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Prove it is you to open this note'**
  String get noteProtectOpenSubtitle;

  /// No description provided for @noteProtectUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Set up a fingerprint or a screen lock first, so there is something to guard the note with.'**
  String get noteProtectUnavailable;

  /// No description provided for @noteProtectCancelled.
  ///
  /// In en, this message translates to:
  /// **'The note stays as it was'**
  String get noteProtectCancelled;

  /// No description provided for @noteProtectKeyLost.
  ///
  /// In en, this message translates to:
  /// **'The key to this note is gone from this phone and cannot be brought back. The note cannot be read again.'**
  String get noteProtectKeyLost;

  /// No description provided for @noteProtectUnreadable.
  ///
  /// In en, this message translates to:
  /// **'This note is marked as protected but its contents were never encrypted. Open it in the editor, turn protection off, and set it again.'**
  String get noteProtectUnreadable;

  /// No description provided for @noteProtectFailed.
  ///
  /// In en, this message translates to:
  /// **'The note could not be opened'**
  String get noteProtectFailed;

  /// No description provided for @noteProtectPinDropped.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 note lost its PIN in this update. Protect it again to have it encrypted properly.} other{{count} notes lost their PIN in this update. Protect them again to have them encrypted properly.}}'**
  String noteProtectPinDropped(int count);

  /// No description provided for @scanPagesTaken.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one{1 page scanned} other{{count} pages scanned}}'**
  String scanPagesTaken(int count);

  /// No description provided for @scanAddPage.
  ///
  /// In en, this message translates to:
  /// **'Scan another page'**
  String get scanAddPage;

  /// No description provided for @scanFinish.
  ///
  /// In en, this message translates to:
  /// **'That is the whole thing'**
  String get scanFinish;

  /// No description provided for @widgetRecentTitle.
  ///
  /// In en, this message translates to:
  /// **'Recent notes'**
  String get widgetRecentTitle;

  /// No description provided for @widgetEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet.'**
  String get widgetEmpty;

  /// No description provided for @noteMovedToBin.
  ///
  /// In en, this message translates to:
  /// **'Note moved to the bin'**
  String get noteMovedToBin;

  /// No description provided for @binTitle.
  ///
  /// In en, this message translates to:
  /// **'Bin'**
  String get binTitle;

  /// No description provided for @binEmpty.
  ///
  /// In en, this message translates to:
  /// **'The bin is empty.'**
  String get binEmpty;

  /// No description provided for @binRetentionHint.
  ///
  /// In en, this message translates to:
  /// **'Notes here are deleted for good 30 days after they were thrown away.'**
  String get binRetentionHint;

  /// No description provided for @binPurgesIn.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Goes today} one{Goes in 1 day} other{Goes in {count} days}}'**
  String binPurgesIn(int count);

  /// No description provided for @binRestore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get binRestore;

  /// No description provided for @binNoteRestored.
  ///
  /// In en, this message translates to:
  /// **'Note restored'**
  String get binNoteRestored;

  /// No description provided for @binDeleteForever.
  ///
  /// In en, this message translates to:
  /// **'Delete for good'**
  String get binDeleteForever;

  /// No description provided for @binEmptyAction.
  ///
  /// In en, this message translates to:
  /// **'Empty the bin'**
  String get binEmptyAction;

  /// No description provided for @binDeleteForeverTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete for good?'**
  String get binDeleteForeverTitle;

  /// No description provided for @binDeleteForeverMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" cannot be brought back.'**
  String binDeleteForeverMessage(String title);

  /// No description provided for @binEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Empty the bin?'**
  String get binEmptyTitle;

  /// No description provided for @binEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'All {count} notes in the bin will be deleted for good.'**
  String binEmptyMessage(int count);

  /// No description provided for @homeEmpty.
  ///
  /// In en, this message translates to:
  /// **'No notes yet. Tap + to write the first one.'**
  String get homeEmpty;

  /// No description provided for @homeSearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search notes'**
  String get homeSearchHint;

  /// No description provided for @homeSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'Nothing matches \"{query}\"'**
  String homeSearchEmpty(String query);

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

  /// No description provided for @noteEditorDate.
  ///
  /// In en, this message translates to:
  /// **'Date in the calendar'**
  String get noteEditorDate;

  /// No description provided for @noteEditorDateNone.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get noteEditorDateNone;

  /// No description provided for @noteEditorDateClear.
  ///
  /// In en, this message translates to:
  /// **'Clear the date'**
  String get noteEditorDateClear;

  /// No description provided for @noteDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete note?'**
  String get noteDeleteTitle;

  /// No description provided for @noteDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'\"{title}\" will be removed for good.'**
  String noteDeleteMessage(String title);

  /// No description provided for @noteEditorSaveError.
  ///
  /// In en, this message translates to:
  /// **'The note could not be saved'**
  String get noteEditorSaveError;

  /// No description provided for @noteEditorDictate.
  ///
  /// In en, this message translates to:
  /// **'Dictate'**
  String get noteEditorDictate;

  /// No description provided for @noteEditorDictateStop.
  ///
  /// In en, this message translates to:
  /// **'Stop dictating'**
  String get noteEditorDictateStop;

  /// No description provided for @noteEditorDictateListening.
  ///
  /// In en, this message translates to:
  /// **'Listening…'**
  String get noteEditorDictateListening;

  /// No description provided for @noteEditorDictateUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This phone cannot write down what you say'**
  String get noteEditorDictateUnavailable;

  /// No description provided for @noteEditorLock.
  ///
  /// In en, this message translates to:
  /// **'Protection'**
  String get noteEditorLock;

  /// No description provided for @noteEditorLockOn.
  ///
  /// In en, this message translates to:
  /// **'Encrypted. Your fingerprint or screen lock opens it.'**
  String get noteEditorLockOn;

  /// No description provided for @noteEditorLockOff.
  ///
  /// In en, this message translates to:
  /// **'Anyone with the phone can read it'**
  String get noteEditorLockOff;

  /// No description provided for @noteEditorLockRemove.
  ///
  /// In en, this message translates to:
  /// **'Turn protection off'**
  String get noteEditorLockRemove;

  /// No description provided for @noteLocked.
  ///
  /// In en, this message translates to:
  /// **'Protected'**
  String get noteLocked;

  /// No description provided for @noteEditorScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Text from a photo'**
  String get noteEditorScanTitle;

  /// No description provided for @noteEditorScanCamera.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get noteEditorScanCamera;

  /// No description provided for @noteEditorScanGallery.
  ///
  /// In en, this message translates to:
  /// **'Pick from gallery'**
  String get noteEditorScanGallery;

  /// No description provided for @noteEditorScanEmpty.
  ///
  /// In en, this message translates to:
  /// **'No text was found in that photo'**
  String get noteEditorScanEmpty;

  /// No description provided for @noteEditorScanError.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be read'**
  String get noteEditorScanError;

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

  /// No description provided for @noteDetailsDatesFound.
  ///
  /// In en, this message translates to:
  /// **'Dates in this note'**
  String get noteDetailsDatesFound;

  /// No description provided for @noteDetailsDateAdded.
  ///
  /// In en, this message translates to:
  /// **'Added to the calendar'**
  String get noteDetailsDateAdded;

  /// No description provided for @noteDetailsDateAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'Already in the calendar'**
  String get noteDetailsDateAlreadyAdded;

  /// No description provided for @noteQrShare.
  ///
  /// In en, this message translates to:
  /// **'Share with a QR code'**
  String get noteQrShare;

  /// No description provided for @noteQrImport.
  ///
  /// In en, this message translates to:
  /// **'Add from a QR code'**
  String get noteQrImport;

  /// No description provided for @noteQrHint.
  ///
  /// In en, this message translates to:
  /// **'Scan this code in the other phone\'s note editor.'**
  String get noteQrHint;

  /// No description provided for @noteQrTooLong.
  ///
  /// In en, this message translates to:
  /// **'This note is too long to fit in a QR code.'**
  String get noteQrTooLong;

  /// No description provided for @noteQrUnreadable.
  ///
  /// In en, this message translates to:
  /// **'That code does not hold a note'**
  String get noteQrUnreadable;

  /// No description provided for @noteQrError.
  ///
  /// In en, this message translates to:
  /// **'The photo could not be read'**
  String get noteQrError;

  /// No description provided for @noteQrShareFailed.
  ///
  /// In en, this message translates to:
  /// **'The code could not be shared'**
  String get noteQrShareFailed;

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

  /// No description provided for @categoriesAdd.
  ///
  /// In en, this message translates to:
  /// **'New category'**
  String get categoriesAdd;

  /// No description provided for @categoriesRename.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get categoriesRename;

  /// No description provided for @categoriesNameHint.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoriesNameHint;

  /// No description provided for @categoriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet. Add one here, or type a new name while writing a note.'**
  String get categoriesEmpty;

  /// No description provided for @categoriesDuplicate.
  ///
  /// In en, this message translates to:
  /// **'A category with that name already exists'**
  String get categoriesDuplicate;

  /// No description provided for @categoriesDeleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete category?'**
  String get categoriesDeleteTitle;

  /// No description provided for @categoriesDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'The notes stay, they just lose this category.'**
  String get categoriesDeleteMessage;

  /// No description provided for @categoriesNoteCount.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No notes} =1{1 note} other{{count} notes}}'**
  String categoriesNoteCount(int count);

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

  /// No description provided for @settingsThemeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// No description provided for @settingsThemeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// No description provided for @settingsReminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get settingsReminders;

  /// No description provided for @settingsRemindersOn.
  ///
  /// In en, this message translates to:
  /// **'Reminders for your events can arrive'**
  String get settingsRemindersOn;

  /// No description provided for @settingsRemindersOff.
  ///
  /// In en, this message translates to:
  /// **'Notifications are off, reminders will not arrive'**
  String get settingsRemindersOff;

  /// No description provided for @settingsRemindersDenied.
  ///
  /// In en, this message translates to:
  /// **'Turn notifications for Scanote back on in your phone\'s settings'**
  String get settingsRemindersDenied;

  /// No description provided for @settingsAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get settingsAccount;

  /// No description provided for @settingsManageAccount.
  ///
  /// In en, this message translates to:
  /// **'Manage account'**
  String get settingsManageAccount;

  /// No description provided for @accountTitle.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get accountTitle;

  /// No description provided for @accountSignOutDescription.
  ///
  /// In en, this message translates to:
  /// **'Ends the session on this phone'**
  String get accountSignOutDescription;

  /// No description provided for @accountDisconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get accountDisconnect;

  /// No description provided for @accountDisconnectDescription.
  ///
  /// In en, this message translates to:
  /// **'Takes back the access granted to Scanote'**
  String get accountDisconnectDescription;

  /// No description provided for @accountDisconnectTitle.
  ///
  /// In en, this message translates to:
  /// **'Disconnect this account?'**
  String get accountDisconnectTitle;

  /// No description provided for @accountDisconnectMessage.
  ///
  /// In en, this message translates to:
  /// **'Scanote loses access to your Google profile. Your notes stay on this phone.'**
  String get accountDisconnectMessage;

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

  /// No description provided for @settingsBackup.
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// No description provided for @settingsBackupExport.
  ///
  /// In en, this message translates to:
  /// **'Export to Google Drive'**
  String get settingsBackupExport;

  /// No description provided for @settingsBackupExportDescription.
  ///
  /// In en, this message translates to:
  /// **'Saves all your notes as a file on your Drive'**
  String get settingsBackupExportDescription;

  /// No description provided for @settingsBackupImport.
  ///
  /// In en, this message translates to:
  /// **'Import from Google Drive'**
  String get settingsBackupImport;

  /// No description provided for @settingsBackupImportDescription.
  ///
  /// In en, this message translates to:
  /// **'Adds the notes from the newest backup'**
  String get settingsBackupImportDescription;

  /// No description provided for @backupExportDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{There was nothing to save} =1{1 note saved to Google Drive} other{{count} notes saved to Google Drive}}'**
  String backupExportDone(int count);

  /// No description provided for @backupImportDone.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Everything from the backup is already here} =1{1 note added from the backup} other{{count} notes added from the backup}}'**
  String backupImportDone(int count);

  /// No description provided for @backupNothingFound.
  ///
  /// In en, this message translates to:
  /// **'No backup was found on your Drive'**
  String get backupNothingFound;

  /// No description provided for @backupError.
  ///
  /// In en, this message translates to:
  /// **'Google Drive could not be reached'**
  String get backupError;

  /// No description provided for @noteEditorScanImageRemove.
  ///
  /// In en, this message translates to:
  /// **'Remove this picture'**
  String get noteEditorScanImageRemove;

  /// No description provided for @noteScanImageCounter.
  ///
  /// In en, this message translates to:
  /// **'Scan {position} of {total}'**
  String noteScanImageCounter(int position, int total);

  /// No description provided for @noteScanImageMissing.
  ///
  /// In en, this message translates to:
  /// **'This picture is no longer on the phone'**
  String get noteScanImageMissing;

  /// No description provided for @settingsSync.
  ///
  /// In en, this message translates to:
  /// **'Sync'**
  String get settingsSync;

  /// No description provided for @settingsSyncEnabled.
  ///
  /// In en, this message translates to:
  /// **'Sync across devices'**
  String get settingsSyncEnabled;

  /// No description provided for @settingsSyncDescription.
  ///
  /// In en, this message translates to:
  /// **'Keeps your notes the same on every phone signed in to this Google account. Protected notes and scanned pictures stay on this phone only.'**
  String get settingsSyncDescription;

  /// No description provided for @settingsSyncNow.
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get settingsSyncNow;

  /// No description provided for @settingsSyncNever.
  ///
  /// In en, this message translates to:
  /// **'Not synced yet'**
  String get settingsSyncNever;

  /// No description provided for @settingsSyncJustNow.
  ///
  /// In en, this message translates to:
  /// **'Synced a moment ago'**
  String get settingsSyncJustNow;

  /// No description provided for @settingsSyncMinutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Synced 1 minute ago} other{Synced {count} minutes ago}}'**
  String settingsSyncMinutesAgo(int count);

  /// No description provided for @settingsSyncHoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{Synced 1 hour ago} other{Synced {count} hours ago}}'**
  String settingsSyncHoursAgo(int count);

  /// No description provided for @settingsSyncUpToDate.
  ///
  /// In en, this message translates to:
  /// **'Everything is already up to date'**
  String get settingsSyncUpToDate;

  /// No description provided for @settingsSyncReceived.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 note came from your other device} other{{count} notes came from your other devices}}'**
  String settingsSyncReceived(int count);

  /// No description provided for @settingsSyncError.
  ///
  /// In en, this message translates to:
  /// **'Notes could not be synced'**
  String get settingsSyncError;

  /// No description provided for @checklistCompleted.
  ///
  /// In en, this message translates to:
  /// **'All done!'**
  String get checklistCompleted;

  /// No description provided for @homeChecklistCompleted.
  ///
  /// In en, this message translates to:
  /// **'Checklist finished'**
  String get homeChecklistCompleted;
}

class _TranslationsDelegate extends LocalizationsDelegate<Translations> {
  const _TranslationsDelegate();

  @override
  Future<Translations> load(Locale locale) {
    return SynchronousFuture<Translations>(lookupTranslations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pl'].contains(locale.languageCode);

  @override
  bool shouldReload(_TranslationsDelegate old) => false;
}

Translations lookupTranslations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return TranslationsEn();
    case 'pl':
      return TranslationsPl();
  }

  throw FlutterError(
    'Translations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
