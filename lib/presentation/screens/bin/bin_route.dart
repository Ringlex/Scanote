import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/screens/bin/bin_argument.dart';
import 'package:note/presentation/screens/bin/bin_screen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

Widget binRoute(GoRouterState state) {
  final argument = state.extra! as BinArgument;

  return BlocProvider<HomeBloc>.value(
    value: argument.homeBloc,
    child: const BinScreen(),
  );
}
