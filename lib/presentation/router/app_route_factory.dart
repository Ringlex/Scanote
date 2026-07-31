import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/common/app_page_transitions.dart';
import 'package:note/presentation/screens/calendar/calendar_route.dart';
import 'package:note/presentation/screens/calendar/calendar_screen.dart';
import 'package:note/presentation/screens/dashboard/dashboard_route.dart';
import 'package:note/presentation/screens/favorites/favorites_route.dart';
import 'package:note/presentation/screens/favorites/favorites_screen.dart';
import 'package:note/presentation/screens/home/home_route.dart';
import 'package:note/presentation/screens/home/home_screen.dart';
import 'package:note/presentation/screens/login/login_route.dart';
import 'package:note/presentation/screens/login/login_screen.dart';
import 'package:note/presentation/screens/note_details/note_details_argument.dart';
import 'package:note/presentation/screens/note_details/note_details_route.dart';
import 'package:note/presentation/screens/note_details/note_details_screen.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_editor/note_editor_route.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:note/presentation/screens/event_editor/event_editor_argument.dart';
import 'package:note/presentation/screens/event_editor/event_editor_route.dart';
import 'package:note/presentation/screens/event_editor/event_editor_screen.dart';
import 'package:note/presentation/screens/settings/settings_route.dart';
import 'package:note/presentation/screens/settings/settings_screen.dart';
import 'package:note/presentation/screens/splash/splash_route.dart';
import 'package:note/presentation/screens/splash/splash_screen.dart';

class AppRouteFactory {
  GoRouter router({
    required GlobalKey<NavigatorState> rootNavigatorKey,
    required GlobalKey<NavigatorState> shellNavigatorKey,
  }) =>
      GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: SplashScreen.routeName,
        errorBuilder: (context, state) {
          return splashRoute(state);
        },
        routes: [
          GoRoute(
            path: SplashScreen.routeName,
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, state) => splashRoute(state),
          ),
          GoRoute(
            path: LoginScreen.routeName,
            parentNavigatorKey: rootNavigatorKey,
            pageBuilder: (_, state) => fadeSlidePage(
              key: state.pageKey,
              child: loginRoute(state),
            ),
          ),
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (_, state, child) => dashboardRoute(state, child),
            routes: [
              GoRoute(
                path: HomeScreen.routeName,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: homeRoute(state),
                ),
              ),
              GoRoute(
                path: CalendarScreen.routeName,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: calendarRoute(state),
                ),
              ),
              GoRoute(
                path: FavoritesScreen.routeName,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: favoritesRoute(state),
                ),
              ),
              GoRoute(
                path: SettingsScreen.routeName,
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: settingsRoute(state),
                ),
              ),
            ],
          ),
          GoRoute(
            path: NoteDetailsScreen.routeName,
            parentNavigatorKey: rootNavigatorKey,
            redirect: (_, state) => state.extra is NoteDetailsArgument ? null : HomeScreen.routeName,
            pageBuilder: (_, state) => fadeSlidePage(
              key: state.pageKey,
              child: noteDetailsRoute(state),
            ),
          ),
          GoRoute(
            path: NoteEditorScreen.routeName,
            parentNavigatorKey: rootNavigatorKey,
            redirect: (_, state) => state.extra is NoteEditorArgument ? null : HomeScreen.routeName,
            pageBuilder: (_, state) => fadeSlidePage(
              key: state.pageKey,
              child: noteEditorRoute(state),
            ),
          ),
          GoRoute(
            path: EventEditorScreen.routeName,
            parentNavigatorKey: rootNavigatorKey,
            redirect: (_, state) => state.extra is EventEditorArgument ? null : CalendarScreen.routeName,
            pageBuilder: (_, state) => fadeSlidePage(
              key: state.pageKey,
              child: eventEditorRoute(state),
            ),
          ),
        ],
      );
}
