import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/app_bloc_observer.dart';
import 'package:note/presentation/common/application.dart';
import 'package:note/presentation/router/app_route_factory.dart';
import '/presentation/injector_container.dart' as di;

Future<void> runApplication() async {
  await di.init(apiUrl: '');

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  _runAppLogger();

  runApp(
    Application(
      appTheme: AppTheme(),
      appRouteFactory: AppRouteFactory(),

      initialThemeMode: await AdaptiveTheme.getThemeMode(),
    ),
  );
}

void _runAppLogger() {
  Bloc.observer = AppBlocObserver();

  AppLogger.instance().configure(level: kDebugMode ? AppLogger.levelAll : AppLogger.levelSevere);

  if (kDebugMode) {
    AppLogger.instance().enableConsoleOutput();
  }

  FlutterError.onError = (details) => logSevere('FlutterError caught in app', details.exception, details.stack);

  AppLogger.instance().output((entry) {
    if (entry.error != null) {
      // for example log to firebase
    }
  });
}
