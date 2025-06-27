import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/popular_info_screen.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class PopularCard extends StatelessWidget {
  final PopularModel popularModel;
  const PopularCard({super.key, required this.popularModel});

  @override
  Widget build(BuildContext context) {
    // Берем последние 5 паттернов
    final lastPatterns = popularModel.patterns.take(5).toList();
    
    return GestureDetector(
      onTap: () {
        Get.to(() => PopularInfoScreen(popularModel: popularModel));
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
                child: _buildPatternMosaic(lastPatterns),
              ),
            ),
            SizedBox(height: 12.sp),
            // Информация
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    popularModel.name,
                    style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.sp),
                  Text(
                    popularModel.description,
                    style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternMosaic(List patterns) {
    if (patterns.isEmpty) {
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
      children: patterns.take(5).map<Widget>((pattern) {
        return Expanded(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 1.sp),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.sp),
              border: Border.all(color: Palette.red100.withOpacity(0.3), width: 1),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.sp),
              child: AspectRatio(
                aspectRatio: 0.7, // Делаем изображения немного вытянутыми по высоте
                child: Image.network(
                  pattern.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Palette.grey200,
                    child: Icon(Icons.image, color: Palette.grey350, size: 16.sp),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}