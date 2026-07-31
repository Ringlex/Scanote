import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/navigation_hub.dart';
import 'package:note/presentation/components/auth/bloc/auth_bloc.dart';
import 'package:note/presentation/components/locale/bloc/locale_bloc.dart';
import 'package:note/presentation/injector_container.dart';
import 'package:note/presentation/router/app_route_factory.dart';

class Application extends StatelessWidget {
  Application({
    required this.appTheme,
    required this.appRouteFactory,
    super.key,
  });

  final AppTheme appTheme;
  final AppRouteFactory appRouteFactory;

  final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
  final _shellNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'shell');
  late final _routerConfig = appRouteFactory.router(
    rootNavigatorKey: _rootNavigatorKey,
    shellNavigatorKey: _shellNavigatorKey,
  );

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => injector<AuthBloc>()..add(const AuthEvent.onInitiated()),
        ),
        BlocProvider(
          create: (context) => injector<LocaleBloc>()..add(const LocaleEvent.onInitiated()),
        ),
      ],
      child: AdaptiveTheme(
        light: appTheme.theme(LightPalette()),
        dark: appTheme.theme(DarkPalette()),
        initial: AdaptiveThemeMode.system,
        builder: (theme, darkTheme) => BlocBuilder<LocaleBloc, LocaleState>(
          builder: (context, localeState) => MaterialApp.router(
            debugShowCheckedModeBanner: false,
            onGenerateTitle: (context) => Translations.of(context).appTitle,
            localizationsDelegates: Translations.localizationsDelegates,
            supportedLocales: Translations.supportedLocales,
            locale: localeState.locale,
            theme: theme,
            darkTheme: darkTheme,
            routerConfig: _routerConfig,
            builder: (context, child) => NavigationHub(
              rootNavigatorKey: _rootNavigatorKey,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
