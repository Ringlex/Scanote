import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AppAssets {
  static const String _assetsPath = 'assets';

  static const String _imagePath = '$_assetsPath/images';

  static const String _svgPath = '$_assetsPath/svg';

  static const String logoText = '$_svgPath/app_logo.svg';
}

extension Assets on BuildContext {
  AssetImage assetImage(String name) => AssetImage(name);

  SvgPicture svgImage(String name, {Color? color, Size? size}) =>
      SvgPicture.asset(name, width: size?.width, height: size?.height);
}
