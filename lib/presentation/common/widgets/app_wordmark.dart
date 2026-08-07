import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppWordmark extends StatelessWidget {
  const AppWordmark({this.fontSize = _defaultFontSize, super.key});

  final double fontSize;

  static const _defaultFontSize = 34.0;

  static const _letters = Color(0xFF2FA37A);
  static const _accent = Color(0xFF57C79B);

  static const _accented = 'Scan';
  static const _rest = 'ote';

  @override
  Widget build(BuildContext context) {
    final style = GoogleFonts.changa(
      fontSize: fontSize,
      fontWeight: FontWeight.w700,
      letterSpacing: fontSize * _letterSpacingRatio,
      height: 1,
    );

    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: _accented,
            style: style.copyWith(color: _accent),
          ),
          TextSpan(
            text: _rest,
            style: style.copyWith(color: _letters),
          ),
        ],
      ),
      textAlign: TextAlign.center,
      maxLines: 1,

      overflow: TextOverflow.visible,
      semanticsLabel: '$_accented$_rest',
    );
  }

  static const _letterSpacingRatio = 0.01;
}
