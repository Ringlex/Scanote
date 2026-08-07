import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:note/core/l10n/translations_extension.dart';
import 'package:note/core/theme/theme.dart';
import 'package:note/presentation/components/locale/app_language.dart';
import 'package:note/presentation/components/locale/bloc/locale_bloc.dart';

String languageLabel(BuildContext context, AppLanguage language) => switch (language) {
  AppLanguage.system => context.translations.settingsLanguageSystem,
  AppLanguage.english => 'English',
  AppLanguage.polish => 'Polski',
};

Future<void> showLanguagePicker(BuildContext context) async {
  final localeBloc = context.read<LocaleBloc>();

  final picked = await showDialog<AppLanguage>(
    context: context,
    builder: (dialogContext) => SimpleDialog(
      backgroundColor: dialogContext.palette.cardColor,
      title: Text(
        dialogContext.translations.settingsLanguage,
        style: dialogContext.textTheme.titleMedium!.copyWith(color: dialogContext.palette.textOnPrimaryColor),
      ),
      children: [
        RadioGroup<AppLanguage>(
          groupValue: localeBloc.state.language,
          onChanged: (value) => Navigator.of(dialogContext).pop(value),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final language in AppLanguage.values)
                RadioListTile<AppLanguage>(
                  value: language,
                  activeColor: dialogContext.palette.accentColor,
                  title: Text(
                    languageLabel(dialogContext, language),
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
    localeBloc.add(LocaleEvent.onLanguageChanged(language: picked));
  }
}
