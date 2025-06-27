import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/controllers/popular_info_controller.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/pattern_detail_screen.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class PopularInfoScreen extends StatelessWidget {
  final PopularModel popularModel;
  
  const PopularInfoScreen({super.key, required this.popularModel});

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PopularInfoController());
    
    // Устанавливаем паттерны в контроллер сразу
    controller.setPatterns(popularModel.patterns);

    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          appBar: AppBar(
            backgroundColor: Palette.red600,
            leading: Container(
              margin: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios_new, color: Palette.white100),
              ),
            ),
            title: Text(
              popularModel.name,
              style: TextStyles.titleLarge.copyWith(color: Palette.white100),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                
                // Категории (горизонтальный скролл)
                Container(
                  height: 40.sp,
                  child: GetBuilder<PopularInfoController>(
                    builder: (controller) => ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: controller.categories.length,
                      itemBuilder: (context, index) {
                        final category = controller.categories[index];
                        final isSelected = controller.selectedCategory.value == category;
                        
                        return Container(
                          margin: EdgeInsets.only(right: 12.sp),
                          child: GestureDetector(
                            onTap: () => controller.selectCategory(category),
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                              decoration: BoxDecoration(
                                color: isSelected ? Palette.red100 : Palette.red600,
                                borderRadius: BorderRadius.circular(20.sp),
                                border: Border.all(
                                  color: isSelected ? Palette.red100 : Palette.red600,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  category,
                                  style: TextStyles.labelLarge.copyWith(
                                    color: isSelected ? Palette.white100 : Palette.grey350,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                    fontSize: isSelected ? 16.sp : 14.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                
                SizedBox(height: 16.sp),
                
                // Сетка паттернов
                Expanded(
                  child: GetBuilder<PopularInfoController>(
                    builder: (controller) {
                      if (controller.isLoading.value) {
                        return Center(child: CircularProgressIndicator(color: Palette.white100));
                      }
                      
                      if (controller.filteredPatterns.isEmpty) {
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
                                'Образы в этой категории пока не добавлены',
                                style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.sp),
                              Text(
                                'Выберите другую категорию',
                                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return GridView.builder(
                        padding: EdgeInsets.only(top: 8.sp),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16.sp,
                          mainAxisSpacing: 16.sp,
                          childAspectRatio: 0.7,
                        ),
                        itemCount: controller.filteredPatterns.length,
                        itemBuilder: (context, index) {
                          final pattern = controller.filteredPatterns[index];
                          return GestureDetector(
                            onTap: () {
                              Get.to(() => PatternDetailScreen(pattern: pattern));
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Palette.white50,
                                borderRadius: BorderRadius.circular(20.sp),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  SizedBox(height: 8.sp),
                                  ClipRRect(
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(20.sp)),
                                    child: AspectRatio(
                                      aspectRatio: 1,
                                      child: Image.network(
                                        pattern.imageUrl,
                                        fit: BoxFit.contain,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Palette.grey200,
                                          child: Icon(Icons.image, size: 60.sp, color: Palette.grey350),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8.sp),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          pattern.name,
                                          style: TextStyles.titleMedium.copyWith(color: Palette.black100),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: 4.sp),
                                        Text(
                                          _formatDate(pattern.createdAt.toDate()),
                                          style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                                        ),
                                        
                                        
                                        
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 