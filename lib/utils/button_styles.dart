import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class ButtonStyles {
  // PRIMARY (заливка)
  static final ButtonStyle primary = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Palette.red100),
    foregroundColor: WidgetStatePropertyAll(Palette.white100),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.adaptiveRadius)),
    ),
    textStyle: WidgetStatePropertyAll(TextStyles.buttonLarge),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
      vertical: 12.adaptiveSpacing, 
      horizontal: 24.adaptiveSpacing
    )),
  );

  // SECONDARY (тёмная заливка)
  static final ButtonStyle secondary = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Palette.red400),
    foregroundColor: WidgetStatePropertyAll(Palette.white100.withOpacity(0.5)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.adaptiveRadius)),
    ),
    textStyle: WidgetStatePropertyAll(TextStyles.buttonLarge),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
      vertical: 12.adaptiveSpacing, 
      horizontal: 24.adaptiveSpacing
    )),
  );

  // OUTLINED (прозрачная с белой обводкой)
  static final ButtonStyle outlined = ButtonStyle(
    backgroundColor: WidgetStatePropertyAll(Palette.red600),
    foregroundColor: WidgetStatePropertyAll(Palette.red200),
    side: WidgetStatePropertyAll(BorderSide(color: Palette.red200, width: 1.5)),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.adaptiveRadius)),
    ),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
      vertical: 12.adaptiveSpacing, 
      horizontal: 24.adaptiveSpacing
    )),
  );

  // Размеры (можно использовать через copyWith)
  static final ButtonStyle large = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(double.infinity, 40.adaptiveContainer)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
      vertical: 16.adaptiveSpacing, 
      horizontal: 32.adaptiveSpacing
    )),
    textStyle: WidgetStatePropertyAll(TextStyles.buttonLarge),
  );
  static final ButtonStyle medium = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(160.adaptiveContainer, 30.adaptiveContainer)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
      vertical: 12.adaptiveSpacing, 
      horizontal: 24.adaptiveSpacing
    )),
    textStyle: WidgetStatePropertyAll(TextStyles.buttonMedium),
  );
  static final ButtonStyle small = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(120.adaptiveContainer, 20.adaptiveContainer)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
      vertical: 8.adaptiveSpacing, 
      horizontal: 16.adaptiveSpacing
    )),
    textStyle: WidgetStatePropertyAll(TextStyles.buttonSmall),
  );
  static final ButtonStyle extraSmall = ButtonStyle(
    minimumSize: WidgetStatePropertyAll(Size(80.adaptiveContainer, 20.adaptiveContainer)),
    padding: WidgetStatePropertyAll(EdgeInsets.symmetric(
      vertical: 4.adaptiveSpacing, 
      horizontal: 12.adaptiveSpacing
    )),
    textStyle: WidgetStatePropertyAll(TextStyles.buttonExtraSmall),
  );
}