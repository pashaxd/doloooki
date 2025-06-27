import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/web_image_widget.dart';
import 'package:doloooki/web/features/recomendations_feature/controllers/rec_controller.dart';
import 'package:doloooki/web/features/recomendations_feature/widgets/create_pattern_category_dialog.dart';
import 'package:doloooki/web/features/recomendations_feature/widgets/create_color_palette_dialog.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RecomendationsScreen extends StatelessWidget {
  const RecomendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем Get.find если контроллер уже существует, иначе создаем новый
    final controller = Get.isRegistered<RecController>() 
        ? Get.find<RecController>()
        : Get.put(RecController());
    
    return Obx(() {
      switch (controller.currentView.value) {
        case RecViewMode.patterns:
          return _buildPatternsView(controller);
        case RecViewMode.colors:
          return _buildColorsView(controller);
        case RecViewMode.main:
        default:
          return _buildMainView(controller);
      }
    });
  }

  Widget _buildMainView(RecController controller) {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопкой обновления
            Row(
              children: [
                Text(
                  'Рекомендации',
                  style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => controller.refreshData(),
                  icon: Icon(
                    Icons.refresh,
                    color: Palette.white100,
                    size: ResponsiveUtils.containerSize(24.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.containerSize(24.h)),

            // Блок с рекомендованными образами
            _buildPatternsSection(controller),
            
            SizedBox(height: ResponsiveUtils.containerSize(32.h)),
            
            // Блок с рекомендованными палитрами
            _buildColorsSection(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternsView(RecController controller) {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с кнопкой назад
          Row(
            children: [
              IconButton(
                onPressed: () => controller.backToMain(),
                icon: Icon(Icons.arrow_back, color: Palette.white100),
              ),
              SizedBox(width: ResponsiveUtils.containerSize(12.w)),
              Text(
                'Рекомендуемые образы',
                style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  showCreatePatternCategoryDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.red100,
                  foregroundColor: Palette.white100,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(16.w),
                    vertical: ResponsiveUtils.containerSize(8.h),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Palette.white100, size: ResponsiveUtils.containerSize(16.sp)),
                    SizedBox(width: ResponsiveUtils.containerSize(8.w)),        
                    Text(
                      'Создать категорию образа',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(24.h)),

          // Список категорий
          Expanded(
            child: Obx(() {
              if (controller.isLoadingPatterns.value) {
                return Center(
                  child: CircularProgressIndicator(color: Palette.white100),
                );
              }
              
              if (controller.popularModels.isEmpty) {
                return Center(
                  child: Text(
                    'Нет рекомендуемых образов',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                );
              }
              
              return SizedBox(
                height: ResponsiveUtils.containerSize(450.h),
                child: ListView.separated(
                  itemCount: controller.popularModels.length,
                  separatorBuilder: (context, index) => SizedBox(height: ResponsiveUtils.containerSize(32.h)),
                  itemBuilder: (context, index) {
                    final popularModel = controller.popularModels[index];
                    return _buildCategoryBlock(popularModel, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBlock(PopularModel popularModel, RecController controller) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
        border: Border.all(
          color: Palette.red400,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок категории
          Row(
            children: [
              Text(
                popularModel.name,
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.containerSize(12.w),
                  vertical: ResponsiveUtils.containerSize(6.h),
                ),
                decoration: BoxDecoration(
                  color: Palette.red100,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(20.r)),
                ),
                child: Text(
                  '${popularModel.patterns.length} образов',
                  style: TextStyles.bodySmall.copyWith(color: Palette.white100),
                ),
              ),
              SizedBox(width: ResponsiveUtils.containerSize(12.w)),
              IconButton(
                onPressed: () => controller.deletePatternCategory(popularModel),
                icon: Icon(
                  Icons.delete,
                  color: Palette.error,
                  size: ResponsiveUtils.containerSize(20.sp),
                ),
                tooltip: 'Удалить категорию',
              ),
            ],
          ),
          
          if (popularModel.description.isNotEmpty) ...[
            SizedBox(height: ResponsiveUtils.containerSize(8.h)),
            Text(
              popularModel.description,
              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            ),
          ],
          
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),

          // Большая картинка первого паттерна
          if (popularModel.patterns.isNotEmpty) ...[
            Container(
              height: ResponsiveUtils.containerSize(600.h),
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(20.r)),
              ),
              child: Row(
                children: [
                  // Большая картинка слева
                  Expanded(
                    flex: 1,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(20.r)),
                      child: Container(
                        color: Palette.red400,
                        child: WebImageWidget(
                          imageUrl: popularModel.patterns.first.imageUrl,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          debugName: popularModel.patterns.first.name,
                          placeholder: Container(
                            color: Palette.red400,
                            child: Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Palette.grey350,
                              ),
                            ),
                          ),
                          errorWidget: Container(
                            color: Palette.red400,
                            child: Icon(
                              Icons.image,
                              color: Palette.grey350,
                              size: ResponsiveUtils.containerSize(48.sp),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  SizedBox(width: ResponsiveUtils.containerSize(20.w)),
                  
                  // Информация справа
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            popularModel.patterns.first.name,
                            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (popularModel.patterns.first.description.isNotEmpty) ...[
                            SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                            Text(
                              popularModel.patterns.first.description,
                              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                              maxLines: 4,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                          Text(
                            'Категория: ${popularModel.patterns.first.category}',
                            style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          ],

          // Горизонтальный список остальных паттернов
          if (popularModel.patterns.length > 1) ...[
            Text(
              'Другие образы в категории',
              style: TextStyles.titleMedium.copyWith(color: Palette.white100),
            ),
            SizedBox(height: ResponsiveUtils.containerSize(12.h)),
            
            SizedBox(
              height: ResponsiveUtils.containerSize(500.h),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: popularModel.patterns.length - 1, // Исключаем первый паттерн
                separatorBuilder: (context, index) => SizedBox(width: ResponsiveUtils.containerSize(12.w)),
                itemBuilder: (context, index) {
                  final pattern = popularModel.patterns[index + 1]; // Начинаем со второго элемента
                  return _buildHorizontalPatternCard(pattern);
                },
              ),
            ),
          ] else ...[
            Container(
              height: ResponsiveUtils.containerSize(60.h),
      child: Center(
        child: Text(
                  'В этой категории только один образ',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHorizontalPatternCard(PatternItem pattern) {
    return Container(
      width: ResponsiveUtils.containerSize(100.w),
      height: ResponsiveUtils.containerSize(300.h),
      decoration: BoxDecoration(
        color: Palette.white100,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(16.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(16.r)),
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Palette.white100,
          child: WebImageWidget(
            imageUrl: pattern.imageUrl,
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.contain,
            debugName: pattern.name,
            placeholder: Container(
              color: Palette.white100,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Palette.red100,
                ),
              ),
            ),
            errorWidget: Container(
              color: Palette.white100,
              child: Icon(
                Icons.image,
                color: Palette.grey350,
                size: ResponsiveUtils.containerSize(48.sp),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorsView(RecController controller) {
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с кнопкой назад
          Row(
            children: [
              IconButton(
                onPressed: () => controller.backToMain(),
                icon: Icon(Icons.arrow_back, color: Palette.white100),
              ),
              SizedBox(width: ResponsiveUtils.containerSize(12.w)),
              Text(
                'Рекомендуемые палитры',
                style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  showCreateColorPaletteDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.red100,
                  foregroundColor: Palette.white100,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(16.w),
                    vertical: ResponsiveUtils.containerSize(8.h),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Palette.white100, size: ResponsiveUtils.containerSize(16.sp)),
                    SizedBox(width: ResponsiveUtils.containerSize(8.w)),        
                    Text(
                      'Создать категорию палитры',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(24.h)),

          // Список палитр
          Expanded(
            child: Obx(() {
              if (controller.isLoadingColors.value) {
                return Center(
                  child: CircularProgressIndicator(color: Palette.white100),
                );
              }
              
              if (controller.colorsModels.isEmpty) {
                return Center(
                  child: Text(
                    'Нет рекомендуемых палитр',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                );
              }
              
              return SizedBox(
                height: ResponsiveUtils.containerSize(450.h),
                child: ListView.separated(
                  itemCount: controller.colorsModels.length,
                  separatorBuilder: (context, index) => SizedBox(height: ResponsiveUtils.containerSize(32.h)),
                  itemBuilder: (context, index) {
                    final colorsModel = controller.colorsModels[index];
                    return _buildColorPaletteBlock(colorsModel, controller);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteBlock(ColorsModel colorsModel, RecController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.containerSize(24.h)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с кнопкой удаления
          Row(
            children: [
              Text(
                colorsModel.name,
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => controller.deleteColorPalette(colorsModel),
                icon: Icon(
                  Icons.delete,
                  color: Palette.error,
                  size: ResponsiveUtils.containerSize(20.sp),
                ),
                tooltip: 'Удалить палитру',
              ),
            ],
          ),
          
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Большой контейнер с основным цветом слева
              Container(
                width: ResponsiveUtils.containerSize(100.w),
                height: ResponsiveUtils.containerSize(400.h),
                decoration: BoxDecoration(
                  color: colorsModel.colors.isNotEmpty 
                    ? Color(controller.getColorFromHex(colorsModel.colors.first))
                    : Palette.grey350,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                ),
              ),
              
              SizedBox(width: ResponsiveUtils.containerSize(24.w)),
              
              // Информация и маленькие цветные квадратики справа
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (colorsModel.description.isNotEmpty) ...[
                      Text(
                        colorsModel.description,
                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                    ],
                    
                    // Маленькие цветные квадратики
                    if (colorsModel.colors.length > 1) ...[
                      Wrap(
                        spacing: ResponsiveUtils.containerSize(8.w),
                        runSpacing: ResponsiveUtils.containerSize(8.h),
                        children: colorsModel.colors.skip(1).map((colorHex) => 
                          Container(
                            width: ResponsiveUtils.containerSize(50.w),
                            height: ResponsiveUtils.containerSize(150.h),
                            decoration: BoxDecoration(
                              color: Color(controller.getColorFromHex(colorHex)),
                              borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                            ),
                          ),
                        ).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsSection(RecController controller) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(12.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(40.r)),
        border: Border.all(
          color: Palette.red400,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Рекомендованные образы',
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  showCreatePatternCategoryDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.red100,
                  foregroundColor: Palette.white100,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(16.w),
                    vertical: ResponsiveUtils.containerSize(8.h),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Palette.white100, size: ResponsiveUtils.containerSize(16.sp)),
                    SizedBox(width: ResponsiveUtils.containerSize(8.w)),        
                    Text(
                      'Создать категорию образа',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),

          // Сетка образов
          Obx(() {
            // Проверяем, что контроллер инициализирован
            if (!controller.initialized) {
              return Container(
                height: ResponsiveUtils.containerSize(200.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Palette.white100,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (controller.isLoadingPatterns.value) {
              return Container(
                height: ResponsiveUtils.containerSize(200.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Palette.white100,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (controller.error.value.isNotEmpty) {
              return Container(
                height: ResponsiveUtils.containerSize(200.h),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, color: Palette.error, size: ResponsiveUtils.containerSize(48.sp)),
                      SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                      Text(
                        controller.error.value,
                        style: TextStyles.bodyMedium.copyWith(color: Palette.error),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            if (controller.popularModels.isEmpty) {
              return Container(
                height: ResponsiveUtils.containerSize(200.h),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.style_outlined, color: Palette.grey350, size: ResponsiveUtils.containerSize(48.sp)),
                      SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                      Text(
                        'Рекомендации отсутствуют',
                        style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: ResponsiveUtils.containerSize(12.w),
                mainAxisSpacing: ResponsiveUtils.containerSize(12.h),
                childAspectRatio: 0.75,
              ),
              itemCount: controller.popularModels.length,
              itemBuilder: (context, index) {
                final popularModel = controller.popularModels[index];
                return _buildPopularModelCard(popularModel, controller);
              },
            );
          }),

          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          Center(
            child: TextButton(
              onPressed: () => controller.navigateToPatterns(),
              child: Text(
                'Перейти в образы',
                style: TextStyles.titleMedium.copyWith(color: Palette.grey350),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorsSection(RecController controller) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(12.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
        border: Border.all(
          color: Palette.red400,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Рекомендованные палитры',
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              Spacer(),
              ElevatedButton(
                onPressed: () {
                  showCreateColorPaletteDialog();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.red100,
                  foregroundColor: Palette.white100,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(16.w),
                    vertical: ResponsiveUtils.containerSize(8.h),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.add, color: Palette.white100, size: ResponsiveUtils.containerSize(16.sp)),
                    SizedBox(width: ResponsiveUtils.containerSize(8.w)),        
                    Text(
                      'Создать категорию палитры',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),

          // Сетка палитр
          Obx(() {
            // Проверяем, что контроллер инициализирован
            if (!controller.initialized) {
              return Container(
                height: ResponsiveUtils.containerSize(200.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Palette.white100,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (controller.isLoadingColors.value) {
              return Container(
                height: ResponsiveUtils.containerSize(200.h),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Palette.white100,
                    strokeWidth: 2,
                  ),
                ),
              );
            }

            if (controller.colorsModels.isEmpty) {
              return Container(
                height: ResponsiveUtils.containerSize(200.h),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.palette_outlined, color: Palette.grey350, size: ResponsiveUtils.containerSize(48.sp)),
                      SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                      Text(
                        'Палитры отсутствуют',
                        style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                      ),
                    ],
                  ),
                ),
              );
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                crossAxisSpacing: ResponsiveUtils.containerSize(12.w),
                mainAxisSpacing: ResponsiveUtils.containerSize(12.h),
                childAspectRatio: 0.85,
              ),
              itemCount: controller.colorsModels.length,
              itemBuilder: (context, index) {
                final colorsModel = controller.colorsModels[index];
                return _buildColorPaletteCardPreview(colorsModel, controller);
              },
            );
          }),

          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          Center(
            child: TextButton(
              onPressed: () => controller.navigateToColors(),
              child: Text(
                'Перейти в палитры',
                style: TextStyles.titleMedium.copyWith(color: Palette.grey350),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularModelCard(PopularModel popularModel, RecController controller) {
    // Получаем изображение первого паттерна или пустую строку
    final imageUrl = controller.getPopularModelImage(popularModel);
    
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(8.r)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                child: imageUrl.isNotEmpty 
                  ? WebImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.fill,
                      debugName: popularModel.name,
                      placeholder: Container(
                        color: Palette.red400,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Palette.grey350,
                          ),
                        ),
                      ),
                      errorWidget: Container(
                        color: Palette.red400,
                        child: Icon(
                          Icons.image,
                          color: Palette.grey350,
                          size: ResponsiveUtils.containerSize(24.sp),
                        ),
                      ),
                    )
                  : Container(
                      color: Palette.red400,
                      child: Icon(
                        Icons.style,
                        color: Palette.grey350,
                        size: ResponsiveUtils.containerSize(24.sp),
                      ),
                    ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          // Название
          Center(
            child: Text(
              popularModel.name,
              style: TextStyles.titleSmall.copyWith(color: Palette.white100),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteCardPreview(ColorsModel colorsModel, RecController controller) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Палитра цветов
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                border: Border.all(color: Palette.red200, width: 1),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                child: colorsModel.colors.isEmpty
                    ? Container(
                        color: Palette.red400,
                        child: Icon(
                          Icons.palette,
                          color: Palette.grey350,
                          size: ResponsiveUtils.containerSize(24.sp),
                        ),
                      )
                    : Container(
                      padding: EdgeInsets.all(ResponsiveUtils.containerSize(4.sp)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                        child: Column(
                          spacing: ResponsiveUtils.containerSize(2.sp),
                            children: [
                              // Первые 2 цвета
                              if (colorsModel.colors.length >= 2) ...[
                                Expanded(
                                  child: Row(
                                    spacing: ResponsiveUtils.containerSize(2.sp),
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Color(controller.getColorFromHex(colorsModel.colors[0])),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Color(controller.getColorFromHex(colorsModel.colors[1])),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              // Следующие 2 цвета
                              if (colorsModel.colors.length >= 4) ...[
                                Expanded(
                                  child: Row(
                                    spacing: ResponsiveUtils.containerSize(2.sp),
                                    children: [
                                      Expanded(
                                        child: Container(
                                          color: Color(controller.getColorFromHex(colorsModel.colors[2])),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          color: Color(controller.getColorFromHex(colorsModel.colors[3])),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ] else if (colorsModel.colors.length == 3) ...[
                                Expanded(
                                  child: Container(
                                    color: Color(controller.getColorFromHex(colorsModel.colors[2])),
                                  ),
                                ),
                              ],
                            ],
                          ),
                      ),
                    ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          // Название
          Center(
            child: Text(
              colorsModel.name,
              style: TextStyles.titleSmall.copyWith(color: Palette.white100),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // Панели пустого состояния
  Widget _buildEmptyPatternDetailPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Palette.red600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.style_outlined, color: Palette.grey350, size: ResponsiveUtils.containerSize(64.sp)),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          Text(
            'Выберите категорию',
            style: TextStyles.titleLarge.copyWith(color: Palette.white100),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          Text(
            'Выберите категорию образов\nиз списка для просмотра',
            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyColorDetailPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Palette.red600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.palette_outlined, color: Palette.grey350, size: ResponsiveUtils.containerSize(64.sp)),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          Text(
            'Выберите палитру',
            style: TextStyles.titleLarge.copyWith(color: Palette.white100),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          Text(
            'Выберите цветовую палитру\nиз списка для просмотра',
            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Детальные панели
  Widget _buildCategoryDetailPanel(PopularModel popularModel, RecController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.red600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
            decoration: BoxDecoration(
              color: Palette.red500,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  popularModel.name,
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(12.w), 
                    vertical: ResponsiveUtils.containerSize(6.h)
                  ),
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${popularModel.patterns.length} образов',
                    style: TextStyles.labelMedium.copyWith(color: Palette.white100),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.containerSize(12.w)),
                IconButton(
                  onPressed: () => controller.deletePatternCategory(popularModel),
                  icon: Icon(
                    Icons.delete,
                    color: Palette.error,
                    size: ResponsiveUtils.containerSize(24.sp),
                  ),
                  tooltip: 'Удалить категорию',
                ),
              ],
            ),
          ),
          
          // Описание и образы
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание категории
                  if (popularModel.description.isNotEmpty) ...[
                    Text(
                      'Описание',
                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                    Text(
                      popularModel.description,
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(24.h)),
                  ],
                  
                  // Образы в категории
                  Text(
                    'Образы в категории',
                    style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                  
                  popularModel.patterns.isEmpty
                    ? Text(
                        'Нет образов в категории',
                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: ResponsiveUtils.containerSize(16.w),
                          mainAxisSpacing: ResponsiveUtils.containerSize(16.h),
                          childAspectRatio: 0.7,
                        ),
                        itemCount: popularModel.patterns.length,
                        itemBuilder: (context, index) {
                          final pattern = popularModel.patterns[index];
                          return _buildPatternCard(pattern);
                        },
                      ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorDetailPanel(ColorsModel colorsModel, RecController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.red600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
            decoration: BoxDecoration(
              color: Palette.red500,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Text(
                  colorsModel.name,
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(12.w), 
                    vertical: ResponsiveUtils.containerSize(6.h)
                  ),
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${colorsModel.colors.length} цветов',
                    style: TextStyles.labelMedium.copyWith(color: Palette.white100),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.containerSize(12.w)),
                IconButton(
                  onPressed: () => controller.deleteColorPalette(colorsModel),
                  icon: Icon(
                    Icons.delete,
                    color: Palette.error,
                    size: ResponsiveUtils.containerSize(24.sp),
                  ),
                  tooltip: 'Удалить палитру',
                ),
              ],
            ),
          ),
          
          // Содержимое
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Описание палитры
                  if (colorsModel.description.isNotEmpty) ...[
                    Text(
                      'Описание',
                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                    Text(
                      colorsModel.description,
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(24.h)),
                  ],
                  
                  // Основные цвета
                  if (colorsModel.colors.isNotEmpty) ...[
                    Text(
                      'Основные цвета',
                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                    
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 5,
                        crossAxisSpacing: ResponsiveUtils.containerSize(12.w),
                        mainAxisSpacing: ResponsiveUtils.containerSize(12.h),
                        childAspectRatio: 1,
                      ),
                      itemCount: colorsModel.colors.length,
                      itemBuilder: (context, index) {
                        final colorHex = colorsModel.colors[index];
                        return _buildColorItem(colorHex, controller);
                      },
                    ),
                    
                    SizedBox(height: ResponsiveUtils.containerSize(24.h)),
                  ],
                  
                  // Комбинации цветов
                  if (colorsModel.combinations.isNotEmpty) ...[
                    Text(
                      'Рекомендуемые комбинации',
                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                    
                    ...colorsModel.combinations.map<Widget>((combination) => 
                      _buildSingleCombination(combination, controller),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternCard(PatternItem pattern) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.red500,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.red400, width: 1),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                width: double.infinity,
                color: Palette.red400,
                child: WebImageWidget(
                  imageUrl: pattern.imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  debugName: pattern.name,
                  placeholder: Container(
                    color: Palette.red400,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Palette.grey350,
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    color: Palette.red400,
                    child: Icon(
                      Icons.image,
                      color: Palette.grey350,
                      size: ResponsiveUtils.containerSize(30.sp),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(ResponsiveUtils.containerSize(8.sp)),
            child: Text(
              pattern.name,
              style: TextStyles.bodySmall.copyWith(color: Palette.white100),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorItem(String colorHex, RecController controller) {
    return Container(
      width: ResponsiveUtils.containerSize(80.w),
      height: ResponsiveUtils.containerSize(80.h),
      decoration: BoxDecoration(
        color: Color(controller.getColorFromHex(colorHex)),
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
        border: Border.all(color: Palette.grey350, width: 1),
      ),
      child: Tooltip(
        message: colorHex.toUpperCase(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
          ),
        ),
      ),
    );
  }

  Widget _buildSingleCombination(String combination, RecController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: ResponsiveUtils.containerSize(12.h)),
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(12.sp)),
      decoration: BoxDecoration(
        color: Palette.red500,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.red400, width: 1),
      ),
      child: Text(
        combination,
        style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
      ),
    );
  }
} 