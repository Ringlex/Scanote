import 'package:note/core/constants/google_auth_const.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/drive/drive_service.dart';
import 'package:note/data/ocr/ocr_service.dart';
import 'package:note/data/qr/barcode_service.dart';
import 'package:note/data/local/adapter/shared_preferences_adapter.dart';
import 'package:note/data/notifications/notification_service.dart';
import 'package:note/data/repository/auth_repository.dart';
import 'package:note/data/repository/backup_repository.dart';
import 'package:note/data/repository/event_repository.dart';
import 'package:note/data/repository/note_repository.dart';
import 'package:note/data/protection/note_protection_service.dart';
import 'package:note/data/repository/settings_repository.dart';
import 'package:note/data/share/share_service.dart';
import 'package:note/data/widget/widget_service.dart';
import 'package:note/data/speech/speech_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension DataInjector on GetIt {
  Future<void> registerData({required String apiUrl}) async {
    final sharedPreferences = await SharedPreferences.getInstance();

    await GoogleSignIn.instance.initialize(serverClientId: GoogleAuthConst.serverClientId);

    this
      ..registerLazySingleton<SharedPreferencesAdapter>(
        () => SharedPreferencesAdapter(sharedPreferences: sharedPreferences),
      )
      ..registerLazySingleton<DBHelper>(() => DBHelper())
      ..registerLazySingleton<OcrService>(() => OcrService())
      ..registerLazySingleton<BarcodeService>(() => BarcodeService())
      ..registerLazySingleton<SpeechService>(() => SpeechService())
      ..registerLazySingleton<ShareService>(() => ShareService())
      ..registerLazySingleton<WidgetService>(() => WidgetService())
      ..registerLazySingleton<NoteProtectionService>(
        () => NoteProtectionService(storage: this<SharedPreferencesAdapter>()),
      )
      ..registerLazySingleton<NotificationService>(() => NotificationService())
      ..registerLazySingleton<NoteRepository>(() => NoteRepository(dbHelper: this<DBHelper>()))
      ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn.instance)
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepository(googleSignIn: this<GoogleSignIn>(), storageAdapter: this<SharedPreferencesAdapter>()),
      )
      ..registerLazySingleton<DriveService>(() => DriveService(googleSignIn: this<GoogleSignIn>()))
      ..registerLazySingleton<BackupRepository>(
        () => BackupRepository(noteRepository: this<NoteRepository>(), driveService: this<DriveService>()),
      )
      ..registerLazySingleton<SettingsRepository>(
        () => SettingsRepository(storageAdapter: this<SharedPreferencesAdapter>()),
      )
      ..registerLazySingleton<EventRepository>(
        () => EventRepository(dbHelper: this<DBHelper>(), notificationService: this<NotificationService>()),
      );
  }
}
