import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';

class TextStyles {
  // Вспомогательный метод для адаптивного размера шрифта
  static double _adaptiveFontSize(double size) {
    return kIsWeb ? ResponsiveUtils.fontSize(size) : size;
  }

  // Headline стили
  static TextStyle get headlineExtraLarge => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(100.sp),
    fontWeight: FontWeight.w900,
    fontFamily: 'MontserratBold',
    height: 36 / 28,
  );

  static TextStyle get headlineLarge => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(25.sp),
    fontWeight: FontWeight.bold,
    fontFamily: 'MontserratBold',
 
  );

  static TextStyle get headlineMedium => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(25.sp),
    fontWeight: FontWeight.w700,
    fontFamily: 'MontserratRegular',
    height: 64 / 48,
  );

  static TextStyle get headlineSmall => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(20.sp),
    fontWeight: FontWeight.w600,
    fontFamily: 'MontserratBold',
    height: 28 / 20,
  );

  // Title стили
  static TextStyle get titleLarge => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(17.sp),
    fontWeight: FontWeight.w800,
    fontFamily: 'MontserratBold',
    height: 24 / 16,
  );

  static TextStyle get titleMedium => TextStyle(
    color: Palette.white100,
    fontSize: _adaptiveFontSize(13.5.sp),
    fontWeight: FontWeight.w800,
    fontFamily: 'MontserratBold',
    height: 20 / 14,
  );

  static TextStyle get titleSmall => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(12.sp),
    fontWeight: FontWeight.w600,
    fontFamily: 'MontserratBold',
    height: 16 / 12,
  );

  // Label стили
  static TextStyle get labelLarge => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(15.sp),
    fontWeight: FontWeight.w600,
    fontFamily: 'MontserratBold',
    height: 20 / 14,
  );

  static TextStyle get labelMedium => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(12.sp),
    fontWeight: FontWeight.w300,
    fontFamily: 'MontserratRegular',
    height: 16 / 12,
  );

  static TextStyle get labelSmall => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(10.sp),
    fontWeight: FontWeight.w400,
    fontFamily: 'MontserratBold',
    height: 16 / 10,
  );

  // Body стили
  static TextStyle get bodyExtraLarge => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(30.sp),
    fontWeight: FontWeight.w400,
    fontFamily: 'MontserratBold',
    height: 24 / 16,
  );

  static TextStyle get bodyLarge => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(15.sp),
    fontWeight: FontWeight.w400,
    fontFamily: 'MontserratRegular',
    height: 20 / 14,
  );

  static TextStyle get bodyMedium => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(12.5.sp),
    fontWeight: FontWeight.w300,
    fontFamily: 'MontserratRegular',
    height: 16 / 12,
  );

  static TextStyle get bodySmall => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(11.sp),
    fontWeight: FontWeight.w400,
    fontFamily: 'MontserratRegular',
    height: 16 / 10,
  );

  // Button стили
  static TextStyle get buttonLarge => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(30.sp),
    fontWeight: FontWeight.w600,
    fontFamily: 'MontserratBold',
    height: 24 / 16,
  );

  static TextStyle get buttonMedium => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(14.sp),
    fontWeight: FontWeight.w500,
    fontFamily: 'MontserratBold',
    height: 20 / 14,
  );

  static TextStyle get buttonSmall => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(12.sp),
    fontWeight: FontWeight.w600,
    fontFamily: 'MontserratBold',
    height: 16 / 12,
  );

  static TextStyle get buttonExtraSmall => TextStyle(
    color: Palette.white200,
    fontSize: _adaptiveFontSize(10.sp),
    fontWeight: FontWeight.w600,
    fontFamily: 'MontserratBold',
    height: 16 / 10,
  );
}

// В main.dart обязательно добавьте инициализацию:
// ScreenUtilInit(
//   designSize: Size(375, 812), // Базовый дизайн
//   minTextAdaptationFactor: 0.5,
//   splitScreenMode: true,
//   builder: (context, child) {
//     return MaterialApp(
//       home: MyApp(),
//     );
//   },
// )