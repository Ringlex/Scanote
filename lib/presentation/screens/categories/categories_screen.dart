import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/categories/category.dart';
import 'package:note/presentation/common/app_back_button.dart';
import 'package:note/presentation/common/app_message.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/common/state_type.dart';
import 'package:note/presentation/screens/categories/widgets/category_name_dialog.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';

class CategoriesScreen extends StatelessWidget {
  static const routeName = '/categories';

  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) => previous.saveType != current.saveType,
      listener: _onSaveStateChanged,
      child: Scaffold(
        backgroundColor: context.palette.primaryColor,
        appBar: AppBar(
          backgroundColor: context.palette.primaryColor,
          foregroundColor: context.palette.textOnPrimaryColor,
          leading: const AppBackButton(),
          title: Text(
            context.translations.settingsCategories,
            style: context.textTheme.titleMedium!.copyWith(
              color: context.palette.textOnPrimaryColor,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () => _onAddPressed(context),
              tooltip: context.translations.categoriesAdd,
              icon: Icon(Icons.add, color: context.palette.accentColor),
            ),
          ],
        ),
        body: BlocBuilder<HomeBloc, HomeState>(
          buildWhen: (previous, current) =>
              previous.categories != current.categories || previous.notes != current.notes,
          builder: (context, state) => state.categories.isEmpty
              ? const _CategoriesEmpty()
              : _CategoryList(state: state),
        ),
      ),
    );
  }

  Future<void> _onAddPressed(BuildContext context) async {
    final homeBloc = context.read<HomeBloc>();
    final name = await showCategoryNameDialog(
      context,
      title: context.translations.categoriesAdd,
    );

    if (name != null) {
      homeBloc.add(HomeEvent.onCategoryCreated(name: name));
    }
  }

  /// The bloc reports an error when a rename would collide with another name.
  void _onSaveStateChanged(BuildContext context, HomeState state) {
    if (state.saveType == StateType.error) {
      showAppMessage(context, message: context.translations.categoriesDuplicate);
    }
  }
}

class _CategoriesEmpty extends StatelessWidget {
  const _CategoriesEmpty();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Insets.xLarge),
        child: Text(
          context.translations.categoriesEmpty,
          textAlign: TextAlign.center,
          style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
        ),
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(Insets.large),
      itemCount: state.categories.length,
      separatorBuilder: (_, _) => Gap.small,
      itemBuilder: (context, index) {
        final category = state.categories[index];

        return _CategoryTile(
          category: category,
          noteCount: state.noteCountOf(category),
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.noteCount,
  });

  final Category category;
  final int noteCount;

  static const _cornerRadius = 16.0;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(category.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context),
      onDismissed: (_) => context.read<HomeBloc>().add(
            HomeEvent.onCategoryDeleted(id: category.id!),
          ),
      background: const _DeleteBackground(),
      child: Material(
        color: context.palette.cardColor,
        borderRadius: BorderRadius.circular(_cornerRadius),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () => _onRenamePressed(context),
          leading: Icon(Icons.label_outline, color: context.palette.accentColor),
          title: Text(
            category.name,
            style: context.textTheme.bodyLarge!.copyWith(
              color: context.palette.textOnPrimaryColor,
            ),
          ),
          subtitle: Text(
            context.translations.categoriesNoteCount(noteCount),
            style: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
          ),
          trailing: Icon(Icons.edit, color: context.palette.inactiveColor),
        ),
      ),
    );
  }

  Future<void> _onRenamePressed(BuildContext context) async {
    final homeBloc = context.read<HomeBloc>();
    final name = await showCategoryNameDialog(
      context,
      title: context.translations.categoriesRename,
      initialName: category.name,
    );

    if (name != null) {
      homeBloc.add(HomeEvent.onCategoryRenamed(id: category.id!, name: name));
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    if (category.id == null) {
      return false;
    }

    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.translations.categoriesDeleteTitle),
        content: Text(context.translations.categoriesDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.translations.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.palette.errorColor),
            child: Text(context.translations.commonDelete),
          ),
        ],
      ),
    );

    return isConfirmed ?? false;
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  static const _cornerRadius = 16.0;
  static const _iconSize = 24.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.symmetric(horizontal: Insets.xLarge),
      decoration: BoxDecoration(
        color: context.palette.errorColor,
        borderRadius: BorderRadius.circular(_cornerRadius),
      ),
      child: Icon(
        Icons.delete_outline,
        size: _iconSize,
        color: context.palette.textOnPrimaryColor,
      ),
    );
  }
}
