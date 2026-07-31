import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/injector_container.dart';
import 'package:note/presentation/screens/settings/bloc/settings_bloc.dart';
import 'package:note/presentation/screens/settings/settings_argument.dart';
import 'package:note/presentation/screens/settings/settings_screen.dart';

Widget settingsRoute(GoRouterState state) => MultiBlocProvider(
      providers: [
        BlocProvider<SettingsBloc>(
          create: (context) => injector<SettingsBloc>(
            param1: state.extra ?? const SettingsArgument(),
          ),
        ),
      ],
      child: const SettingsScreen(),
    );
