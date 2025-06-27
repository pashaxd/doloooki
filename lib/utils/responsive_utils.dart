import 'package:flutter_screenutil/flutter_screenutil.dart';

class ResponsiveUtils {
  // Базовые коэффициенты масштабирования
  static const double _wideScreenCoeff = 0.33;    // > 1200px
  static const double _mediumScreenCoeff = 0.5;   // 800-1200px  
  static const double _narrowScreenCoeff = 0.9;   // < 800px

  // Универсальный метод адаптации размеров
  static double adaptSize(double baseSize, {
    double? wideCoeff,
    double? mediumCoeff, 
    double? narrowCoeff,
  }) {
    final screenWidth = ScreenUtil().screenWidth;
    
    if (screenWidth > 1200) {
      return baseSize * (wideCoeff ?? _wideScreenCoeff);
    } else if (screenWidth > 800) {
      return baseSize * (mediumCoeff ?? _mediumScreenCoeff);
    } else {
      return baseSize * (narrowCoeff ?? _narrowScreenCoeff);
    }
  }

  // Специализированные методы для разных типов размеров
  
  // Для шрифтов (можно настроить отдельные коэффициенты)
  static double fontSize(double size) => adaptSize(size, narrowCoeff: 0.8, mediumCoeff: 0.5, wideCoeff: 0.25);
  
  // Для иконок (обычно чуть меньше масштабируются)
  static double iconSize(double size) => adaptSize(
    size,
    wideCoeff: 0.4,
    mediumCoeff: 0.6,
    narrowCoeff: 0.9,
  );
  
  // Для отступов и padding
  static double spacing(double size) => adaptSize(
    size,
    wideCoeff: 0.3,
    mediumCoeff: 0.45,
    narrowCoeff: 0.8,
  );
  
  // Для размеров контейнеров (ширина/высота)
  static double containerSize(double size) => adaptSize(
    size,
    wideCoeff: 0.35,
    mediumCoeff: 0.55,
    narrowCoeff: 0.95,
  );
  
  // Для border radius
  static double borderRadius(double size) => adaptSize(
    size,
    wideCoeff: 0.4,
    mediumCoeff: 0.6,
    narrowCoeff: 0.8,
  );

  // Utility геттеры для быстрого доступа
  static bool get isWideScreen => ScreenUtil().screenWidth > 1200;
  static bool get isMediumScreen => ScreenUtil().screenWidth > 800 && ScreenUtil().screenWidth <= 1200;
  static bool get isNarrowScreen => ScreenUtil().screenWidth <= 800;
  
  static double get screenWidth => ScreenUtil().screenWidth;
  static double get screenHeight => ScreenUtil().screenHeight;
}

// Extension для удобного использования
extension ResponsiveDouble on double {
  // Универсальная адаптация
  double get adaptive => ResponsiveUtils.adaptSize(this);
  
  // Специализированные адаптации
  double get adaptiveFont => ResponsiveUtils.fontSize(this);
  double get adaptiveIcon => ResponsiveUtils.iconSize(this);
  double get adaptiveSpacing => ResponsiveUtils.spacing(this);
  double get adaptiveContainer => ResponsiveUtils.containerSize(this);
  double get adaptiveRadius => ResponsiveUtils.borderRadius(this);
}

extension ResponsiveInt on int {
  // Для int значений
  double get adaptive => ResponsiveUtils.adaptSize(toDouble());
  double get adaptiveFont => ResponsiveUtils.fontSize(toDouble());
  double get adaptiveIcon => ResponsiveUtils.iconSize(toDouble());
  double get adaptiveSpacing => ResponsiveUtils.spacing(toDouble());
  double get adaptiveContainer => ResponsiveUtils.containerSize(toDouble());
  double get adaptiveRadius => ResponsiveUtils.borderRadius(toDouble());
} 