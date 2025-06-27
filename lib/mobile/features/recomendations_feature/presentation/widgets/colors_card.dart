import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/colors_info_screen.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/popular_info_screen.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class ColorsCard extends StatelessWidget {
  final ColorsModel colorsModel;
  final bool isMainColors;
  const ColorsCard({super.key, required this.colorsModel, this.isMainColors = false});

  @override
  Widget build(BuildContext context) {
    // Берем последние 5 паттернов
    final lastColors = colorsModel.colors.take(5).toList();
    
    return GestureDetector(
      onTap: () {
        Get.to(() => ColorsInfoScreen(colorsModel: colorsModel));
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 8.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Мозаика из паттернов
            Container(
              height: 120.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.sp),
                color: Palette.grey100,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.sp),
                child: _buildPatternMosaic(lastColors),
              ),
            ),
            isMainColors ?
            SizedBox():
            Column(
              children: [
                SizedBox(height: 12.sp),
              
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    colorsModel.name,
                    style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.sp),
                  Text(
                    colorsModel.description,
                    style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternMosaic(List colors) {
    if (colors.isEmpty) {
      return Container(
        color: Palette.grey200,
        child: Center(
          child: Text(
            'Нет образов',
            style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
          ),
        ),
      );
    }

    return Row(
      children: colors.take(5).map<Widget>((color) {
        // Безопасный парсинг цвета
        Color parsedColor = _parseColor(color.toString());
        
        return Expanded(
          child: AspectRatio(
            aspectRatio: 0.1,
            child: ColoredBox(
              color: parsedColor,
            ),
          ),
        );
      }).toList(),
    );
  }

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
}