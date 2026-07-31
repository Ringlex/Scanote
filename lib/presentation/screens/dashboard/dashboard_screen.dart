import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/calendar/calendar_screen.dart';
import 'package:note/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:note/presentation/screens/dashboard/widgets/dashboard_app_bar.dart';
import 'package:note/presentation/screens/event_editor/event_editor_argument.dart';
import 'package:note/presentation/screens/event_editor/event_editor_screen.dart';
import 'package:note/presentation/screens/favorites/favorites_screen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/home/home_screen.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:note/presentation/screens/settings/settings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    required this.child,
    super.key,
  });

  final Widget child;

  static const iconSize = 32.0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashboardBloc, DashboardState>(
      builder: (context, state) {
        return Scaffold(
          body: child,
          appBar: const DashboardAppBar(),
          bottomNavigationBar: const _DashboardNavigationBar(),
          extendBody: true,
          floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            backgroundColor: Colors.transparent,
            onPressed: () => _onAddPressed(context),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: context.palette.accentColor,
              ),
              child: Center(
                child: Icon(
                  Icons.add,
                  size: iconSize,
                  color: context.palette.primaryColor,
                ),
              ),
            ),
          ),
        );
      },
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
      tabBuilder: (index, isActive) => NavBarIcon(
        index: index,
        isActive: isActive,
      ),
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
  const NavBarIcon({
    required this.index,
    required this.isActive,
    super.key,
  });

  final int index;
  final bool isActive;

  static const iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    var iconList = [Icons.home, Icons.calendar_month, Icons.favorite, Icons.settings];
    return Icon(
      iconList[index],
      size: iconSize,
      color: isActive ? Colors.white : Colors.grey,
    );
  }
}

void _onAddPressed(BuildContext context) {
  final isOnCalendar = GoRouterState.of(context).matchedLocation.startsWith(CalendarScreen.routeName);

  if (isOnCalendar) {
    context.push(
      EventEditorScreen.routeName,
      extra: EventEditorArgument(calendarBloc: context.read<CalendarBloc>()),
    );

    return;
  }

  context.push(
    NoteEditorScreen.routeName,
    extra: NoteEditorArgument(homeBloc: context.read<HomeBloc>()),
  );
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
