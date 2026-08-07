import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/widgets/note_grid.dart';
import 'package:note/presentation/screens/dashboard/widgets/dashboard_sliver_app_bar.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

class FavoritesScreen extends StatelessWidget {
  static const routeName = '/favorites';

  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.palette.primaryColor,

      body: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) => previous.notes != current.notes,
        builder: (context, state) {
          final favorites = state.favoriteNotes;

          return SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                const DashboardSliverAppBar(),
                if (favorites.isEmpty)
                  const _FavoritesEmpty()
                else
                  NoteGrid(notes: favorites, categoryNameOf: state.categoryNameOf),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FavoritesEmpty extends StatelessWidget {
  const _FavoritesEmpty();

  static const _iconSize = 64.0;

  @override
  Widget build(BuildContext context) {
    return SliverFillRemaining(
      hasScrollBody: false,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(Insets.xLarge),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.favorite_border, size: _iconSize, color: context.palette.accentColor),
              Gap.large,
              Text(
                context.translations.favoritesTitle,
                style: context.textTheme.displaySmall!.copyWith(color: context.palette.textOnPrimaryColor),
              ),
              Gap.small,
              Text(
                context.translations.favoritesEmpty,
                textAlign: TextAlign.center,
                style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
