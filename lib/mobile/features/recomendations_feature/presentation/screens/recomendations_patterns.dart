import 'package:doloooki/mobile/features/recomendations_feature/presentation/controllers/recomendations_controller.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/widgets/popular_card.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RecomendationsPatterns extends StatelessWidget {
  const RecomendationsPatterns({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RecomendationsController());
    
    return Container(
      padding: EdgeInsets.all(16.sp),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(
              color: Palette.white100,
            ),
          );
        }

        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Palette.error,
                  size: 48.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  controller.error.value,
                  style: TextStyles.bodyMedium.copyWith(color: Palette.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                ElevatedButton(
                  onPressed: () => controller.refreshPopularModels(),
                  child: Text('Попробовать снова'),
                ),
              ],
            ),
          );
        }

        if (controller.popularModels.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.style_outlined,
                  color: Palette.grey350,
                  size: 48.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Популярные образы пока не загружены',
                  style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Проверьте подключение к интернету',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => controller.refreshPopularModels(),
          color: Palette.red100,
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: controller.popularModels.length,
            itemBuilder: (context, index) {
              final popularModel = controller.popularModels[index];
              return PopularCard(popularModel: popularModel);
            },
          ),
        );
      }),
    );
  }
}