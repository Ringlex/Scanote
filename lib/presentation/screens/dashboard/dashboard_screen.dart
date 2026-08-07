import 'dart:async';

import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:home_widget/home_widget.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/note.dart';
import 'package:note/data/repository/note_repository.dart';
import 'package:note/data/share/share_service.dart';
import 'package:note/data/widget/widget_service.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/scan_to_note.dart';
import 'package:note/presentation/injector_container.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/note_details/note_details_argument.dart';
import 'package:note/presentation/screens/note_details/note_details_screen.dart';
import 'package:note/presentation/screens/calendar/calendar_screen.dart';
import 'package:note/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:note/presentation/screens/event_editor/event_editor_argument.dart';
import 'package:note/presentation/screens/event_editor/event_editor_screen.dart';
import 'package:note/presentation/screens/favorites/favorites_screen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/home/home_screen.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:note/presentation/screens/settings/settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({required this.child, super.key});

  final Widget child;

  static const iconSize = 32.0;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with WidgetsBindingObserver {
  var _isOpeningShare = false;

  StreamSubscription<Uri?>? _widgetTaps;

  static const _widgetNewNotePath = 'new';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tellAboutDroppedPins();
      _openSharedText();
      _openInitialWidgetTap();
    });

    _widgetTaps = HomeWidget.widgetClicked.listen(_onWidgetUri);
  }

  @override
  void dispose() {
    unawaited(_widgetTaps?.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _tellAboutDroppedPins() async {
    final repository = injector<NoteRepository>();
    final count = (await repository.countDroppedPins().run()).getOrElse((_) => 0);

    if (count == 0 || !mounted) {
      return;
    }

    showAppMessage(context, message: context.translations.noteProtectPinDropped(count));

    await repository.clearDroppedPins().run();
  }

  Future<void> _openInitialWidgetTap() async {
    _onWidgetUri(await HomeWidget.initiallyLaunchedFromHomeWidget());
  }

  void _onWidgetUri(Uri? uri) {
    if (uri == null || !mounted) {
      return;
    }

    final segments = uri.pathSegments;

    if (segments.firstOrNull == _widgetNewNotePath) {
      context.push(NoteEditorScreen.routeName, extra: NoteEditorArgument(homeBloc: context.read<HomeBloc>()));

      return;
    }

    final noteId = int.tryParse(segments.length > 1 ? segments[1] : '');
    final note = context.read<HomeBloc>().state.notes.firstWhereOrNull((it) => it.id == noteId);

    if (note == null) {
      return;
    }

    context.push(
      NoteDetailsScreen.routeName,
      extra: NoteDetailsArgument(
        homeBloc: context.read<HomeBloc>(),
        calendarBloc: context.read<CalendarBloc>(),
        noteId: note.id!,
      ),
    );
  }

  Future<void> _pushWidget(HomeState state) => injector<WidgetService>().push(
    notes: state.notes,
    title: context.translations.widgetRecentTitle,
    emptyLabel: context.translations.widgetEmpty,
  );

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _openSharedText();
    }
  }

  Future<void> _openSharedText() async {
    if (_isOpeningShare) {
      return;
    }

    _isOpeningShare = true;

    try {
      final shared = await injector<ShareService>().consume();

      if (shared == null || !mounted) {
        return;
      }

      await context.push(
        NoteEditorScreen.routeName,
        extra: NoteEditorArgument(
          homeBloc: context.read<HomeBloc>(),
          note: Note(title: shared.suggestedTitle, noteContents: shared.text),
        ),
      );
    } finally {
      _isOpeningShare = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => previous.notes != current.notes,
      listener: (_, state) => unawaited(_pushWidget(state)),
      child: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (context, state) {
          return Scaffold(
            body: widget.child,
            bottomNavigationBar: const _DashboardNavigationBar(),
            extendBody: true,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.transparent,
              onPressed: () => _onAddPressed(context),
              child: Container(
                decoration: BoxDecoration(shape: BoxShape.circle, color: context.palette.accentColor),
                child: Center(
                  child: Icon(
                    _isOnCalendar(context) ? Icons.add : Icons.photo_camera,
                    size: DashboardScreen.iconSize,
                    color: context.palette.primaryColor,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _DashboardNavigationBar extends StatelessWidget {
  const _DashboardNavigationBar({super.key});

  static const cornerRadius = 32.0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBottomNavigationBar.builder(
      itemCount: _navigationRoutes.length,
      tabBuilder: (index, isActive) => NavBarIcon(index: index, isActive: isActive),
      activeIndex: _calculateSelectedIndex(context),
      onTap: (index) => _onItemTapped(index, context),
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      backgroundColor: context.palette.cardColor,
      leftCornerRadius: cornerRadius,
      rightCornerRadius: cornerRadius,
    );
  }
}

class NavBarIcon extends StatelessWidget {
  const NavBarIcon({required this.index, required this.isActive, super.key});

  final int index;
  final bool isActive;

  static const iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    const iconList = [Icons.home, Icons.calendar_month, Icons.favorite, Icons.settings];

    return Icon(
      iconList[index],
      size: iconSize,

      color: isActive ? context.palette.accentColor : context.palette.inactiveColor,
    );
  }
}

bool _isOnCalendar(BuildContext context) =>
    GoRouterState.of(context).matchedLocation.startsWith(CalendarScreen.routeName);

void _onAddPressed(BuildContext context) {
  if (_isOnCalendar(context)) {
    context.push(EventEditorScreen.routeName, extra: EventEditorArgument(calendarBloc: context.read<CalendarBloc>()));

    return;
  }

  unawaited(scanIntoNewNote(context));
}

const _navigationRoutes = [
  HomeScreen.routeName,
  CalendarScreen.routeName,
  FavoritesScreen.routeName,
  SettingsScreen.routeName,
];

int _calculateSelectedIndex(BuildContext context) {
  final location = GoRouterState.of(context).matchedLocation;
  final index = _navigationRoutes.indexWhere(location.startsWith);

  return index < 0 ? 0 : index;
}

void _onItemTapped(int index, BuildContext context) {
  context.go(_navigationRoutes[index]);
}
