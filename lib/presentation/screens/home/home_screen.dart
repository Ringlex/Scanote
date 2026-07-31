import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/common/widgets/note_grid.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = '/home';

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) => state.type.map<Widget>(
          initial: () => const _HomeLoading(),
          loading: () => const _HomeLoading(),
          loaded: () => NoteGrid(
            notes: state.notes,
            categoryNameOf: state.categoryNameOf,
          ),
          empty: () => _HomeMessage(message: context.translations.homeEmpty),
          error: () => _HomeMessage(message: context.translations.homeLoadError),
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: context.palette.accentColor),
    );
  }
}

class _HomeMessage extends StatelessWidget {
  const _HomeMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xLarge),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        ),
      ),
    );
  }
}
