import 'package:flutter/foundation.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

@immutable
class CategoriesArgument {
  const CategoriesArgument({required this.homeBloc});

  final HomeBloc homeBloc;
}
