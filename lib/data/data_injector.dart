import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:note/data/database/db_helper.dart';
import 'package:note/data/local/adapter/shared_preferences_adapter.dart';
import 'package:note/data/notifications/notification_service.dart';
import 'package:note/data/repository/auth_repository.dart';
import 'package:note/data/repository/event_repository.dart';
import 'package:note/data/repository/note_repository.dart';
import 'package:note/data/repository/settings_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension DataInjector on GetIt {
  Future<void> registerData({required String apiUrl}) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    this
      ..registerLazySingleton<SharedPreferencesAdapter>(
        () => SharedPreferencesAdapter(sharedPreferences: sharedPreferences),
      )
      ..registerLazySingleton<DBHelper>(() => DBHelper())
      ..registerLazySingleton<NotificationService>(() => NotificationService())
      ..registerLazySingleton<NoteRepository>(
        () => NoteRepository(dbHelper: this<DBHelper>()),
      )
      ..registerLazySingleton<GoogleSignIn>(() => GoogleSignIn(scopes: const ['email']))
      ..registerLazySingleton<AuthRepository>(
        () => AuthRepository(
          googleSignIn: this<GoogleSignIn>(),
          storageAdapter: this<SharedPreferencesAdapter>(),
        ),
      )
      ..registerLazySingleton<SettingsRepository>(
        () => SettingsRepository(storageAdapter: this<SharedPreferencesAdapter>()),
      )
      ..registerLazySingleton<EventRepository>(
        () => EventRepository(
          dbHelper: this<DBHelper>(),
          notificationService: this<NotificationService>(),
        ),
      );
  }
}
