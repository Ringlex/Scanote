import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class Palette {
  Brightness get brightness;
  Color get darkGrayColor;
  Color get shadowColor;
  Color get inactiveColor;
  Color get snackBarColor;
  Color get cardColor;
  Color get primaryColor;
  Color get primaryDarkColor;
  Color get primaryLightColor;
  Color get accentColor;
  Color get accentVariantColor;
  Color get errorColor;
  Color get iconColor;
  Color get backgroundColor;
  Color get appBarBackgroundColor;
  Color get textOnPrimaryColor;
  Color get primaryTextDisplayColor;
  Color get primaryTextBodyColor;
  Color get badgeColor1;
  Color get badgeColor2;
  Color get badgeColor3;
  Color get badgeColor4;
}

class LightPalette extends Palette {
  @override
  final Brightness brightness = Brightness.light;
  @override
  final Color darkGrayColor = const Color(0xff63788E);
  @override
  final Color shadowColor = const Color(0x1A0F1D2B);
  @override
  final Color inactiveColor = const Color(0xff63788E);
  @override
  final Color snackBarColor = Colors.white;
  @override
  final Color cardColor = Colors.white;
  @override
  final Color primaryColor = const Color(0xffF5F8FB);
  @override
  final Color primaryDarkColor = const Color(0xffE3EAF2);
  @override
  final Color primaryLightColor = Colors.white;
  @override
  final Color accentColor = const Color(0xff1C8663);
  @override
  final Color accentVariantColor = const Color(0xff14624A);
  @override
  final Color errorColor = const Color(0xffC0343B);
  @override
  final Color iconColor = const Color(0xff1C8663);
  @override
  final Color backgroundColor = const Color(0xffF5F8FB);
  @override
  final Color textOnPrimaryColor = const Color(0xff10202F);
  @override
  final Color primaryTextBodyColor = const Color(0xff1B2F45);
  @override
  final Color primaryTextDisplayColor = const Color(0xff10202F);
  @override
  final Color appBarBackgroundColor = const Color(0xffF5F8FB);
  @override
  final Color badgeColor1 = const Color(0xff1C8663);
  @override
  final Color badgeColor2 = const Color(0xff2F6690);
  @override
  final Color badgeColor3 = const Color(0xff14624A);
  @override
  final Color badgeColor4 = const Color(0xff48796A);
}

class DarkPalette extends Palette {
  @override
  final Brightness brightness = Brightness.dark;
  @override
  final Color darkGrayColor = const Color(0xff3A4A5C);
  @override
  final Color shadowColor = const Color(0x33000000);
  @override
  final Color inactiveColor = const Color(0xff8397AE);
  @override
  final Color snackBarColor = const Color(0xff1B2F45);
  @override
  final Color cardColor = const Color(0xff1B2F45);
  @override
  final Color primaryColor = const Color(0xff0F1D2B);
  @override
  final Color primaryDarkColor = const Color(0xff081320);
  @override
  final Color primaryLightColor = const Color(0xff24405C);
  @override
  final Color accentColor = const Color(0xff2FA37A);
  @override
  final Color accentVariantColor = const Color(0xff1C6B50);
  @override
  final Color errorColor = const Color(0xffE2555C);
  @override
  final Color iconColor = const Color(0xff2FA37A);
  @override
  final Color backgroundColor = const Color(0xff0F1D2B);
  @override
  final Color textOnPrimaryColor = Colors.white;
  @override
  final Color primaryTextBodyColor = const Color(0xffE6EDF5);
  @override
  final Color primaryTextDisplayColor = const Color(0xffE6EDF5);
  @override
  final Color appBarBackgroundColor = const Color(0xff0F1D2B);
  @override
  final Color badgeColor1 = const Color(0xff2FA37A);
  @override
  final Color badgeColor2 = const Color(0xff3E7CB1);
  @override
  final Color badgeColor3 = const Color(0xff1C6B50);
  @override
  final Color badgeColor4 = const Color(0xff5A8F7B);
}

class AppTheme {
  static const _dialogCornerRadius = 16.0;

  static Palette paletteOf(BuildContext context) {
    return context.theme.brightness == Brightness.light ? LightPalette() : DarkPalette();
  }

  ThemeData theme(Palette palette) {
    // System icons are drawn on top of the app's own background, so they go
    // the opposite way to it: dark icons over a light theme and the reverse.
    final systemIconBrightness = palette.brightness == Brightness.light ? Brightness.dark : Brightness.light;

    final theme = ThemeData(
      primaryColorDark: palette.primaryDarkColor,
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: generateMaterialColor(palette.primaryColor),
        accentColor: palette.accentColor,
        cardColor: palette.cardColor,
        backgroundColor: palette.backgroundColor,
        brightness: palette.brightness,
      ).copyWith(secondaryContainer: palette.accentVariantColor),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      primaryTextTheme: _textThemeHandset.apply(
        bodyColor: palette.primaryTextBodyColor,
        displayColor: palette.primaryTextDisplayColor,
      ),
      textTheme: _textThemeHandset.apply(
        bodyColor: palette.primaryTextBodyColor,
        displayColor: palette.primaryTextDisplayColor,
      ),
      iconTheme: IconThemeData(color: palette.iconColor),
      canvasColor: palette.backgroundColor,
      scaffoldBackgroundColor: palette.backgroundColor,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          // iOS reads this one as the brightness behind the status bar.
          statusBarBrightness: palette.brightness,
          statusBarIconBrightness: systemIconBrightness,
          systemNavigationBarIconBrightness: systemIconBrightness,
        ),
        // The bar is painted in the primary colour, so its text has to be the
        // one that reads on top of it.
        toolbarTextStyle: TextStyle(color: palette.textOnPrimaryColor),
        titleTextStyle: TextStyle(color: palette.textOnPrimaryColor, fontWeight: FontWeight.bold, fontSize: 16),
        backgroundColor: palette.appBarBackgroundColor,
        iconTheme: IconThemeData(color: palette.iconColor),
        actionsIconTheme: IconThemeData(color: palette.iconColor),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedIconTheme: IconThemeData(color: palette.cardColor),
        unselectedIconTheme: IconThemeData(color: palette.darkGrayColor),
        selectedItemColor: palette.cardColor,
        unselectedItemColor: palette.darkGrayColor,
        selectedLabelStyle: TextStyle(color: palette.cardColor),
        unselectedLabelStyle: TextStyle(color: palette.darkGrayColor),
        showSelectedLabels: true,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
      // Dialogs otherwise fall back to the light Material palette, which puts
      // dark blue text on the dark card colour.
      dialogTheme: DialogThemeData(
        backgroundColor: palette.cardColor,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: _textThemeHandset.titleMedium?.copyWith(color: palette.textOnPrimaryColor),
        contentTextStyle: _textThemeHandset.bodyMedium?.copyWith(color: palette.textOnPrimaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_dialogCornerRadius)),
      ),
      textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: palette.accentColor)),
      useMaterial3: true,
    );
    return theme.copyWith(
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(backgroundColor: palette.accentVariantColor),
      ),
    );
  }

  TextTheme get _textThemeHandset => TextTheme(
    displayLarge: GoogleFonts.changa(fontSize: 36, fontWeight: FontWeight.w400, letterSpacing: 0.48),
    displayMedium: GoogleFonts.changa(fontSize: 28, fontWeight: FontWeight.w400, letterSpacing: 0.48),
    displaySmall: GoogleFonts.changa(fontSize: 22, fontWeight: FontWeight.w400, letterSpacing: 0.48),
    headlineSmall: GoogleFonts.changa(fontSize: 17, fontWeight: FontWeight.w600, letterSpacing: -0.408),
    titleLarge: GoogleFonts.changa(fontSize: 14, fontWeight: FontWeight.w400, letterSpacing: -0.078),
    titleMedium: GoogleFonts.changa(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.19),
    titleSmall: GoogleFonts.changa(fontSize: 12, fontWeight: FontWeight.w500, letterSpacing: 0.64),
    bodyLarge: GoogleFonts.changa(fontSize: 16, fontWeight: FontWeight.w500, letterSpacing: 0.32),
    bodyMedium: GoogleFonts.changa(fontSize: 14, fontWeight: FontWeight.w300, letterSpacing: 0.32),
    labelLarge: GoogleFonts.changa(fontSize: 18, fontWeight: FontWeight.w500, letterSpacing: 0.32),
    bodySmall: GoogleFonts.changa(fontSize: 18, fontWeight: FontWeight.w400, letterSpacing: 0.32),
    labelSmall: GoogleFonts.changa(fontSize: 12, fontWeight: FontWeight.w300, letterSpacing: 0.64),
  );

  MaterialColor generateMaterialColor(Color color) => MaterialColor(color.toARGB32(), {
    50: tintColor(color, 0.9),
    100: tintColor(color, 0.8),
    200: tintColor(color, 0.6),
    300: tintColor(color, 0.4),
    400: tintColor(color, 0.2),
    500: color,
    600: shadeColor(color, 0.1),
    700: shadeColor(color, 0.2),
    800: shadeColor(color, 0.3),
    900: shadeColor(color, 0.4),
  });

  /// Carries a channel towards white, the factor being how far it travels.
  double tintValue(double channel, double factor) => clampDouble(channel + ((1 - channel) * factor), 0, 1);

  Color tintColor(Color color, double factor) => Color.from(
    alpha: 1,
    red: tintValue(color.r, factor),
    green: tintValue(color.g, factor),
    blue: tintValue(color.b, factor),
  );

  /// The same the other way, towards black.
  double shadeValue(double channel, double factor) => clampDouble(channel - (channel * factor), 0, 1);

  Color shadeColor(Color color, double factor) => Color.from(
    alpha: 1,
    red: shadeValue(color.r, factor),
    green: shadeValue(color.g, factor),
    blue: shadeValue(color.b, factor),
  );
}

extension AppThemes on BuildContext {
  ThemeData get theme => Theme.of(this);

  AppBarThemeData get appBarThemes => theme.appBarTheme;

  TextTheme get textTheme => Theme.of(this).textTheme;

  Palette get palette => AppTheme.paletteOf(this);

  ColorScheme get colors => theme.colorScheme;
}
