import 'dart:ui';

class Palette {
  static const Color white50 = Color(0xFFFFFFFF);
  static const Color white100 = Color.fromARGB(255, 247, 247, 248);
  static const Color white200 = Color.fromARGB(255, 242, 242, 243);
  static const Color white300 = Color.fromARGB(255, 229,229,229);
  
  static const Color grey100 = Color.fromARGB(255, 215,215,215);
  static const Color grey200 = Color.fromARGB(255, 177,177,177);
  static const Color grey300 = Color.fromARGB(255, 128,128,128);
  static const Color grey350 = Color.fromARGB(255, 150,151,156);
  static const Color grey500 = Color.fromARGB(255, 73,73,73);

  static const Color black100 = Color.fromARGB(255, 37,37,37);
  static const Color black200 = Color.fromARGB(255, 18,18,18);
  static const Color black300 = Color.fromARGB(255, 0,0,0);

  static const Color red20 = Color(0xFFE0CECE);
  static const Color red50 = Color.fromARGB(255, 153,126,126);
  static const Color red100 = Color.fromARGB(255, 168,19,63);
  static const Color red200 = Color.fromARGB(255, 106,52,52);
  static const Color red300 = Color.fromARGB(255, 97,18,41);
  static const Color red400 = Color.fromARGB(255, 38,19,19);
  static const Color red500 = Color.fromARGB(255, 26,5,5);
  static const Color red600 = Color.fromARGB(255, 21,0,0);

  static const Color success = Color.fromARGB(255, 31,173,71);
  static const Color warning = Color.fromARGB(255, 255,212,38);
  static const Color error = Color.fromARGB(255, 255,74,60);
  static const Color info = Color.fromARGB(255, 59,157,255);

  static const List<Color> gradientDark=[Color.fromARGB(255, 87,0,26), Color.fromARGB(255, 189,0,56)];
  static const List<Color> gradientLight=[Color.fromARGB(255, 255,45,107), Color.fromARGB(255, 168,19,63)];

  // Утилитный метод для безопасного парсинга hex-цветов
  static Color parseHexColor(String hexColor) {
    try {
      // Убираем все символы # из строки
      String cleanColor = hexColor.replaceAll('#', '');
      
      // Если длина меньше 6 символов, дополняем нулями
      if (cleanColor.length == 3) {
        cleanColor = cleanColor.split('').map((char) => char + char).join();
      }
      
      // Добавляем альфа-канал если его нет
      if (cleanColor.length == 6) {
        cleanColor = 'FF' + cleanColor;
      }
      
      // Парсим цвет
      return Color(int.parse(cleanColor, radix: 16));
    } catch (e) {
      print('Ошибка парсинга цвета $hexColor: $e');
      // Возвращаем серый цвет по умолчанию в случае ошибки
      return Palette.grey350;
    }
  }
}