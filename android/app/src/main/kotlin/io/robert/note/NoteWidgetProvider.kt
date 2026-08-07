package io.robert.note

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Shows the few most recent notes on the home screen. The data is whatever
 * Dart last wrote through home_widget: the widget runs in another process and
 * cannot reach the app's database itself, so it draws a snapshot rather than
 * live state.
 */
class NoteWidgetProvider : HomeWidgetProvider() {
    private companion object {
        /** How many rows the layout has. */
        const val ROW_COUNT = 3

        const val KEY_TITLE = "widget_title"
        const val KEY_EMPTY = "widget_empty"
        const val KEY_NOTE_PREFIX = "widget_note_"
        const val KEY_NOTE_ID_PREFIX = "widget_note_id_"

        val ROW_VIEW_IDS = intArrayOf(R.id.widget_note_0, R.id.widget_note_1, R.id.widget_note_2)

        /** Read back by the app to decide what the tap should open. */
        const val HOST = "widget"
        const val PATH_NEW = "new"
        const val PATH_NOTE = "note"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.note_widget).apply {
                setTextViewText(R.id.widget_title, widgetData.getString(KEY_TITLE, "") ?: "")
                bindRows(context, widgetData)
                bindEmptyState(widgetData)

                // The whole widget opens the app; the + goes straight to a new
                // note, which is the one thing worth saving a tap on.
                setOnClickPendingIntent(
                    R.id.widget_root,
                    launchIntent(context, PATH_NOTE, null),
                )
                setOnClickPendingIntent(
                    R.id.widget_add,
                    launchIntent(context, PATH_NEW, null),
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    private fun RemoteViews.bindRows(context: Context, widgetData: SharedPreferences) {
        for (index in 0 until ROW_COUNT) {
            val viewId = ROW_VIEW_IDS[index]
            val title = widgetData.getString("$KEY_NOTE_PREFIX$index", null)

            if (title.isNullOrBlank()) {
                setViewVisibility(viewId, View.GONE)
                continue
            }

            setViewVisibility(viewId, View.VISIBLE)
            setTextViewText(viewId, title)

            val noteId = widgetData.getString("$KEY_NOTE_ID_PREFIX$index", null)
            setOnClickPendingIntent(viewId, launchIntent(context, PATH_NOTE, noteId))
        }
    }

    private fun RemoteViews.bindEmptyState(widgetData: SharedPreferences) {
        val hasAnyNote = (0 until ROW_COUNT).any {
            !widgetData.getString("$KEY_NOTE_PREFIX$it", null).isNullOrBlank()
        }

        setViewVisibility(R.id.widget_empty, if (hasAnyNote) View.GONE else View.VISIBLE)
        setTextViewText(R.id.widget_empty, widgetData.getString(KEY_EMPTY, "") ?: "")
    }

    /** The uri is what Dart reads to decide where to route. */
    private fun launchIntent(context: Context, path: String, noteId: String?) =
        HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            android.net.Uri.parse(
                if (noteId == null) "noteapp://$HOST/$path" else "noteapp://$HOST/$path/$noteId",
            ),
        )
}
