import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/constants/app_const.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/common/dimen.dart';
import 'package:note/presentation/screens/home/bloc/home_bloc.dart';
import 'package:note/presentation/screens/note_editor/note_editor_argument.dart';
import 'package:note/presentation/screens/note_editor/note_editor_screen.dart';
import 'package:note/presentation/common/widgets/app_wordmark.dart';

class DashboardSliverAppBar extends StatefulWidget {
  const DashboardSliverAppBar({this.showSearch = false, super.key});

  final bool showSearch;

  @override
  State<DashboardSliverAppBar> createState() => _DashboardSliverAppBarState();
}

class _DashboardSliverAppBarState extends State<DashboardSliverAppBar> with SingleTickerProviderStateMixin {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  bool _isSearching = false;

  static const _toolbarHeight = 80.0;
  static const _horizontalPadding = 12.0;
  static const _wordmarkSize = 30.0;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPersistentHeader(
      floating: true,
      delegate: _DashboardHeaderDelegate(
        vsync: this,
        height: _toolbarHeight,
        background: context.palette.primaryColor,
        child: Row(
          children: [
            _buildLeading(context) ?? const SizedBox(width: _AppBarButton.buttonWidth),
            Expanded(
              child: _isSearching
                  ? _SearchField(controller: _controller, focusNode: _focusNode, onChanged: _onQueryChanged)
                  : const Center(child: AppWordmark(fontSize: _wordmarkSize)),
            ),
            if (_isSearching)
              _AppBarButton(icon: Icons.close, tooltip: context.translations.commonCancel, onTap: _onSearchCleared)
            else if (widget.showSearch)
              _AppBarButton(
                icon: Icons.edit_outlined,
                tooltip: context.translations.homeWriteNote,
                onTap: () => _onWritePressed(context),
              )
            else
              const SizedBox(width: _AppBarButton.buttonWidth),
          ],
        ),
      ),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (!widget.showSearch) {
      return null;
    }

    return _AppBarButton(
      icon: _isSearching ? Icons.arrow_back : Icons.search,
      tooltip: context.translations.homeSearchHint,
      onTap: _isSearching ? _onSearchClosed : _onSearchOpened,
    );
  }

  void _onWritePressed(BuildContext context) {
    context.push(NoteEditorScreen.routeName, extra: NoteEditorArgument(homeBloc: context.read<HomeBloc>()));
  }

  void _onSearchOpened() {
    setState(() => _isSearching = true);
    _focusNode.requestFocus();
  }

  void _onSearchClosed() {
    setState(() => _isSearching = false);
    _controller.clear();
    _onQueryChanged('');
  }

  void _onSearchCleared() {
    _controller.clear();
    _onQueryChanged('');
    _focusNode.requestFocus();
  }

  void _onQueryChanged(String query) {
    context.read<HomeBloc>().add(HomeEvent.onSearchChanged(query: query));
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.focusNode, required this.onChanged});

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Insets.small),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: context.textTheme.bodyLarge!.copyWith(color: context.palette.textOnPrimaryColor),
        cursorColor: context.palette.accentColor,
        decoration: InputDecoration(
          hintText: context.translations.homeSearchHint,
          hintStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
          border: InputBorder.none,
          isDense: true,
        ),
      ),
    );
  }
}

class _AppBarButton extends StatelessWidget {
  const _AppBarButton({required this.icon, required this.tooltip, required this.onTap});

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  static const _iconSize = 28.0;

  static const buttonWidth = 48.0;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onTap,
      tooltip: tooltip,
      icon: Icon(icon, color: context.palette.inactiveColor, size: _iconSize),
    );
  }
}

class _DashboardHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _DashboardHeaderDelegate({
    required this.vsync,
    required this.height,
    required this.background,
    required this.child,
  });

  @override
  final TickerProvider vsync;

  final double height;
  final Color background;
  final Widget child;

  @override
  double get maxExtent => height;

  @override
  double get minExtent => 0;

  @override
  FloatingHeaderSnapConfiguration get snapConfiguration =>
      FloatingHeaderSnapConfiguration(curve: AppMotion.curve, duration: AppMotion.duration);

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final visible = Curves.easeOut.transform(1 - (shrinkOffset / height).clamp(0.0, 1.0));

    return Container(
      height: height,

      color: background,
      padding: const EdgeInsets.symmetric(horizontal: _DashboardSliverAppBarState._horizontalPadding),

      child: visible == 1 ? child : Opacity(opacity: visible, child: child),
    );
  }

  @override
  bool shouldRebuild(_DashboardHeaderDelegate oldDelegate) =>
      oldDelegate.vsync != vsync ||
      oldDelegate.child != child ||
      oldDelegate.height != height ||
      oldDelegate.background != background;
}
