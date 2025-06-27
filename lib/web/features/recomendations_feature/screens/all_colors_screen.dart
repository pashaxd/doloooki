import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/web/features/recomendations_feature/controllers/rec_controller.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AllColorsScreen extends StatelessWidget {
  const AllColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<RecController>();
    
    return Container(
      alignment: Alignment.topCenter,
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      child: Row(
        children: [
          // Левая панель - список цветовых палитр
          Expanded(
            flex: 1,
            child: Container(
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
                        IconButton(
                          onPressed: () => Get.back(),
                          icon: Icon(Icons.arrow_back, color: Palette.white100),
                        ),
                        SizedBox(width: ResponsiveUtils.containerSize(12.w)),
                        Text(
                          'Все рекомендуемые палитры',
                          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                        ),
                      ],
                    ),
                  ),
                  
                  // Список палитр
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoadingColors.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
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
                      
                      return ListView.separated(
                        padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
                        itemCount: controller.colorsModels.length,
                        separatorBuilder: (context, index) => SizedBox(height: ResponsiveUtils.containerSize(12.h)),
                        itemBuilder: (context, index) {
                          final colorsModel = controller.colorsModels[index];
                          return _buildColorPaletteCard(colorsModel, controller);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: ResponsiveUtils.containerSize(20.w)),
          
          // Правая панель - детальный просмотр палитры
          Expanded(
            flex: 2,
            child: Obx(() {
              final selectedModel = controller.selectedColorsModel.value;
              if (selectedModel == null) {
                return _buildEmptyDetailPanel();
              }
              return _buildColorDetailPanel(selectedModel, controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPaletteCard(ColorsModel colorsModel, RecController controller) {
    return Obx(() {
      final isSelected = controller.selectedColorsModel.value?.name == colorsModel.name;
      
      return GestureDetector(
        onTap: () => controller.selectColorsModel(colorsModel),
        child: Container(
          padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
          decoration: BoxDecoration(
            color: isSelected ? Palette.red400 : Palette.red500,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Palette.grey350, 
              width: 2,
            ),
          ),
          child: Row(
            children: [
              // Превью палитры
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: ResponsiveUtils.containerSize(60.w),
                  height: ResponsiveUtils.containerSize(60.h),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Palette.red200, width: 1),
                  ),
                  child: colorsModel.colors.isEmpty
                      ? Container(
                          color: Palette.red400,
                          child: Icon(
                            Icons.palette,
                            color: Palette.grey350,
                            size: ResponsiveUtils.containerSize(24.sp),
                          ),
                        )
                      : Row(
                          children: colorsModel.colors.take(4).map((colorHex) {
                            return Expanded(
                              child: Container(
                                color: Color(controller.getColorFromHex(colorHex)),
                              ),
                            );
                          }).toList(),
                        ),
                ),
              ),
              
              SizedBox(width: ResponsiveUtils.containerSize(12.w)),
              
              // Информация
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      colorsModel.name,
                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(4.h)),
                    Text(
                      colorsModel.description,
                      style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${colorsModel.colors.length} цветов',
                      style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildEmptyDetailPanel() {
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

  Widget _buildColorItem(String colorHex, RecController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Color(controller.getColorFromHex(colorHex)),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Palette.grey350, width: 1),
      ),
      child: Tooltip(
        message: colorHex.toUpperCase(),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
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