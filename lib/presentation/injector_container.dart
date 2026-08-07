import 'package:get_it/get_it.dart';
import 'package:note/data/data_injector.dart';
import 'package:note/presentation/components/auth/bloc/auth_bloc.dart';
import 'package:note/presentation/components/locale/bloc/locale_bloc.dart';
import 'package:note/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:note/presentation/screens/dashboard/dashboard_argument.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/home/home_argument.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/calendar/calendar_argument.dart';
import 'package:note/presentation/screens/settings/bloc/settings_bloc.dart';
import 'package:note/presentation/screens/settings/settings_argument.dart';

final injector = GetIt.instance;

Future<void> init({
  required String apiUrl,
}) async {
  await injector.registerData(apiUrl: apiUrl);

  injector
    ..registerLazySingleton<AuthBloc>(
      () => AuthBloc(
        dbHelper: injector(),
        notificationService: injector(),
        authRepository: injector(),
      ),
    )
    ..registerLazySingleton<LocaleBloc>(
      () => LocaleBloc(
        settingsRepository: injector(),
      ),
    )
    ..registerFactoryParam<DashboardBloc, DashboardArgument, void>(
      (argument, _) => DashboardBloc(
        argument: argument,
      ),
    )
    ..registerFactoryParam<HomeBloc, HomeArgument, void>(
      (argument, _) => HomeBloc(
        argument: argument,
        noteRepository: injector(),
      ),
    )
    ..registerFactoryParam<CalendarBloc, CalendarArgument, void>(
      (argument, _) => CalendarBloc(
        argument: argument,
        eventRepository: injector(),
      ),
    )
    ..registerFactoryParam<SettingsBloc, SettingsArgument, void>(
      (argument, _) => SettingsBloc(
        argument: argument,
        backupRepository: injector(),
        notificationService: injector(),
      ),
    );
}
