import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/injector_container.dart';
import 'package:note/presentation/screens/calendar/bloc/calendar_bloc.dart';
import 'package:note/presentation/screens/calendar/calendar_argument.dart';
import 'package:note/presentation/screens/dashboard/bloc/dashboard_bloc.dart';
import 'package:note/presentation/screens/dashboard/dashboard_argument.dart';
import 'package:note/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/home/home_argument.dart';

Widget dashboardRoute(GoRouterState state, Widget child) => MultiBlocProvider(
      providers: [
        BlocProvider<DashboardBloc>(
          create: (context) => injector<DashboardBloc>(
            param1: state.extra ?? const DashboardArgument(),
          ),
        ),
        BlocProvider<HomeBloc>(
          create: (context) => injector<HomeBloc>(
            param1: const HomeArgument(),
          )..add(const HomeEvent.onInitiated()),
        ),
        BlocProvider<CalendarBloc>(
          create: (context) => injector<CalendarBloc>(
            param1: const CalendarArgument(),
          )..add(const CalendarEvent.onInitiated()),
        ),
      ],
      child: DashboardScreen(child: child),
    );
