import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/presentation/screens/categories/categories_argument.dart';
import 'package:note/presentation/screens/categories/categories_screen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

Widget categoriesRoute(GoRouterState state) {
  final argument = state.extra! as CategoriesArgument;

  return BlocProvider<HomeBloc>.value(
    value: argument.homeBloc,
    child: const CategoriesScreen(),
  );
}
