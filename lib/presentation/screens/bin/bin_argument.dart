import 'package:flutter/foundation.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

@immutable
class BinArgument {
  const BinArgument({required this.homeBloc});

  final HomeBloc homeBloc;
}
