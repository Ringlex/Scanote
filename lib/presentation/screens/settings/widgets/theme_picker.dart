import 'package:adaptive_theme/adaptive_theme.dart';
import 'package:flutter/material.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';

String themeLabel(BuildContext context, AdaptiveThemeMode mode) => switch (mode) {
  AdaptiveThemeMode.system => context.translations.settingsThemeSystem,
  AdaptiveThemeMode.light => context.translations.settingsThemeLight,
  AdaptiveThemeMode.dark => context.translations.settingsThemeDark,
};

IconData themeIcon(AdaptiveThemeMode mode) => switch (mode) {
  AdaptiveThemeMode.system => Icons.brightness_auto_outlined,
  AdaptiveThemeMode.light => Icons.light_mode_outlined,
  AdaptiveThemeMode.dark => Icons.dark_mode_outlined,
};

Future<void> showThemePicker(BuildContext context) async {
  final manager = AdaptiveTheme.of(context);

  final picked = await showDialog<AdaptiveThemeMode>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      backgroundColor: dialogContext.palette.cardColor,
      title: Text(
        dialogContext.translations.settingsTheme,
        style: dialogContext.textTheme.titleMedium!.copyWith(color: dialogContext.palette.textOnPrimaryColor),
      ),
      children: [
        RadioGroup<AdaptiveThemeMode>(
          groupValue: manager.mode,
          onChanged: (value) => Navigator.of(dialogContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final mode in AdaptiveThemeMode.values)
                RadioListTile<AdaptiveThemeMode>(
                  value: mode,
                  activeColor: dialogContext.palette.accentColor,
                  title: Text(
                    themeLabel(dialogContext, mode),
                    style: dialogContext.textTheme.bodyLarge!.copyWith(color: dialogContext.palette.textOnPrimaryColor),
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );

  if (picked != null) {
    manager.setThemeMode(picked);
  }
}
