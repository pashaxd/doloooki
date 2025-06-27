import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CombinationsCard extends StatelessWidget {
  final List<String> combinations;
  const CombinationsCard({super.key, required this.combinations});

  // Метод для правильного форматирования hex-цвета
  Color _parseColor(String colorString) {
    try {
      // Убираем все символы # из строки
      String cleanColor = colorString.replaceAll('#', '');
      
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
      print('Ошибка парсинга цвета $colorString: $e');
      // Возвращаем серый цвет по умолчанию в случае ошибки
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 90.sp,
      width: 200.sp,
      decoration: BoxDecoration(
        color: Color(0xFF252838),
        borderRadius: BorderRadius.circular(16.sp),
      ),
      child: Padding(
        padding: EdgeInsets.all(14.sp),
        child: Column(
          spacing: 4.sp,
        
          children: [
            Row(
              spacing: 4.sp,
              children: [
                Container(
                  height: 40.sp,
                  width: 40.sp,
                  decoration: BoxDecoration(
                    color: _parseColor(combinations[0]),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16.sp),
                    ),
                  ),
                ),
                Container(
                  height: 40.sp,
                  width: 40.sp,
                  decoration: BoxDecoration(
                    color: _parseColor(combinations[1]),
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16.sp),
                    ),
                  ),
                ),
              ],  
            ),
            Row(
              spacing: 4.sp,
              children: [
              Container(
                height: 40.sp,
                width: 40.sp,
                decoration: BoxDecoration(
                  color: _parseColor(combinations[2]),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.sp),
                  ),
                ),
                ),
                Container(
                height: 40.sp,
                width: 40.sp,
                decoration: BoxDecoration(
                  color: _parseColor(combinations[3]),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(16.sp),
                  ),
                ),
                ),
                
                ]
            )
          ],
        ),
      ),
    );
  }
}