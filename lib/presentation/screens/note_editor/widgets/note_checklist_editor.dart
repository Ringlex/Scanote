import 'package:flutter/material.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/data/model/note/checklist_item.dart';
import 'package:note/presentation/common/dimen.dart';

class NoteChecklistEditor extends StatefulWidget {
  const NoteChecklistEditor({
    required this.initialItems,
    required this.onChanged,
    super.key,
  });

  final List<ChecklistItem> initialItems;
  final ValueChanged<List<ChecklistItem>> onChanged;

  @override
  State<NoteChecklistEditor> createState() => _NoteChecklistEditorState();
}

class _NoteChecklistEditorState extends State<NoteChecklistEditor> {
  final List<_ChecklistEntry> _entries = [];

  @override
  void initState() {
    super.initState();

    for (final item in widget.initialItems) {
      _entries.add(_ChecklistEntry(label: item.label, isDone: item.isDone));
    }

    if (_entries.isEmpty) {
      _entries.add(_ChecklistEntry());
    }
  }

  @override
  void dispose() {
    for (final entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: _entries.length + 1,
      itemBuilder: (context, index) => index == _entries.length
          ? _AddItemButton(onPressed: _onItemAdded)
          : _ChecklistRow(
              entry: _entries[index],
              onDoneChanged: (isDone) => _onDoneChanged(index, isDone),
              onLabelChanged: _notifyChanged,
              onSubmitted: _onItemAdded,
              onRemoved: () => _onItemRemoved(index),
            ),
    );
  }

  void _onItemAdded() {
    final entry = _ChecklistEntry();

    setState(() => _entries.add(entry));
    entry.focusNode.requestFocus();
    _notifyChanged();
  }

  void _onItemRemoved(int index) {
    final entry = _entries[index];

    setState(() => _entries.removeAt(index));
    entry.dispose();
    _notifyChanged();
  }

  void _onDoneChanged(int index, bool isDone) {
    setState(() => _entries[index].isDone = isDone);
    _notifyChanged();
  }

  void _notifyChanged() {
    widget.onChanged([
      for (final entry in _entries)
        if (entry.controller.text.trim().isNotEmpty)
          ChecklistItem(label: entry.controller.text.trim(), isDone: entry.isDone),
    ]);
  }
}

class _ChecklistEntry {
  _ChecklistEntry({String label = '', this.isDone = false}) : controller = TextEditingController(text: label);

  final TextEditingController controller;
  final FocusNode focusNode = FocusNode();
  bool isDone;

  void dispose() {
    controller.dispose();
    focusNode.dispose();
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({
    required this.entry,
    required this.onDoneChanged,
    required this.onLabelChanged,
    required this.onSubmitted,
    required this.onRemoved,
  });

  final _ChecklistEntry entry;
  final ValueChanged<bool> onDoneChanged;
  final VoidCallback onLabelChanged;
  final VoidCallback onSubmitted;
  final VoidCallback onRemoved;

  static const _iconSize = 20.0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: entry.isDone,
          onChanged: (isDone) => onDoneChanged(isDone ?? false),
          activeColor: context.palette.accentColor,
          checkColor: context.palette.primaryColor,
          side: BorderSide(color: context.palette.inactiveColor),
        ),
        Expanded(
          child: TextField(
            controller: entry.controller,
            focusNode: entry.focusNode,
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (_) => onLabelChanged(),
            onSubmitted: (_) => onSubmitted(),
            style: context.textTheme.bodyLarge!.copyWith(
              color: context.palette.textOnPrimaryColor,
              decoration: entry.isDone ? TextDecoration.lineThrough : null,
            ),
            cursorColor: context.palette.accentColor,
            decoration: InputDecoration(
              hintText: context.translations.noteEditorItemHint,
              hintStyle: context.textTheme.bodyMedium!.copyWith(color: context.palette.inactiveColor),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        IconButton(
          onPressed: onRemoved,
          tooltip: context.translations.noteEditorRemoveItem,
          icon: Icon(
            Icons.close,
            size: _iconSize,
            color: context.palette.inactiveColor,
          ),
        ),
      ],
    );
  }
}

class _AddItemButton extends StatelessWidget {
  const _AddItemButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(top: Insets.small),
        child: TextButton.icon(
          onPressed: onPressed,
          icon: Icon(Icons.add, color: context.palette.accentColor),
          label: Text(
            context.translations.noteEditorAddItem,
            style: context.textTheme.bodyMedium!.copyWith(color: context.palette.accentColor),
          ),
        ),
      ),
    );
  }
}
