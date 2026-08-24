import 'package:home_widget/home_widget.dart';
import 'package:note/core/app_logger/app_logger.dart';
import 'package:note/data/model/note/note.dart';

class WidgetService {
  static const _androidProvider = 'NoteWidgetProvider';
  static const _qualifiedAndroidProvider = 'io.ringlex.scanote.NoteWidgetProvider';

  static const _titleKey = 'widget_title';
  static const _emptyKey = 'widget_empty';
  static const _notePrefix = 'widget_note_';
  static const _noteIdPrefix = 'widget_note_id_';

  static const rowCount = 3;

  Future<void> push({required List<Note> notes, required String title, required String emptyLabel}) async {
    try {
      await HomeWidget.saveWidgetData<String>(_titleKey, title);
      await HomeWidget.saveWidgetData<String>(_emptyKey, emptyLabel);

      final visible = notes.take(rowCount).toList();

      for (var index = 0; index < rowCount; index++) {
        final note = index < visible.length ? visible[index] : null;

        await HomeWidget.saveWidgetData<String>(
          '$_notePrefix$index',
          note == null ? null : (note.isLocked ? '🔒' : note.title),
        );
        await HomeWidget.saveWidgetData<String>('$_noteIdPrefix$index', note?.id?.toString());
      }

      await HomeWidget.updateWidget(androidName: _androidProvider, qualifiedAndroidName: _qualifiedAndroidProvider);
    } catch (error, stackTrace) {
      logSevere('Updating the home screen widget failed', error, stackTrace);
    }
  }
}
