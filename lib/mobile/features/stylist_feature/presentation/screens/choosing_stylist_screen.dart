import 'package:doloooki/mobile/features/stylist_feature/presentation/controllers/choosing_stylist_controller.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/widgets/syliist_info.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class ChoosingStylistScreen extends StatelessWidget {
   ChoosingStylistScreen({super.key});
    final controller = Get.put(ChoosingStylistController());

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Palette.red600,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Palette.red600,
        title: Text(
          'Выбор стилиста',
          style: TextStyles.titleLarge.copyWith(color: Palette.white100)
        ),
        leading: Container(
          decoration: BoxDecoration(
            color: Palette.red400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new, color: Palette.white100),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Выберите варианты:', 
              style: TextStyles.titleMedium.copyWith(color: Palette.white100)
            ),
            SizedBox(height: 16.sp),
            
            // Кнопка автоматического выбора стилиста
            Obx(() {
              final isAutoSelected = controller.isRandomSelection.value;
              
              return GestureDetector(
                onTap: () => controller.selectRandomStylist(),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isAutoSelected ? Palette.red100 : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 35.sp,
                        height: 35.sp,
                        decoration: BoxDecoration(
                          color: Palette.red200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/stylist/people.svg',
                            width: 20.sp,
                            height: 20.sp,
                            colorFilter: ColorFilter.mode(Palette.white100, BlendMode.srcIn),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Подобрать автоматически',
                              style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                            ),
                            Text(
                              'Система выберет свободного стилиста',
                              style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 24.sp,
                        height: 24.sp,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAutoSelected ? Palette.red100 : Palette.grey350,
                            width: 2,
                          ),
                          color: isAutoSelected ? Palette.red100 : Colors.transparent,
                        ),
                        child: isAutoSelected
                            ? Icon(
                                Icons.check,
                                size: 16.sp,
                                color: Palette.white100,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            SizedBox(height: 24.sp),
            
            // Список стилистов
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: Palette.red100,
                    ),
                  );
                }
                
                if (controller.stylists.isEmpty) {
                  return Center(
                    child: Text(
                      'Стилисты не найдены',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    ),
                  );
                }
                
                return ListView.separated(
                  itemCount: controller.stylists.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.sp),
                  itemBuilder: (context, index) {
                    final stylist = controller.stylists[index];
                    final averageRating = controller.getAverageRating(stylist);
                    
                    return Obx(() {
                      final isSelected = controller.selectedStylist.value?.id == stylist.id;
                      
                      return GestureDetector(
                        onTap: () => Get.bottomSheet(
                          SyliistInfo(stylist: stylist),
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                        ),
                        child: Container(
                          padding: EdgeInsets.all(12.sp),
                          decoration: BoxDecoration(
                            color: Palette.red400,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isSelected ? Palette.red100 : Colors.transparent,
                              width: 2,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                    width: 35.sp,
                                height: 35.sp,
                                decoration: BoxDecoration(
                                  color: Palette.red200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: SizedBox(
                                    width: 20.sp,
                                    height: 20.sp,
                                    child: SvgPicture.asset(
                                      'assets/icons/stylist/voka.svg',
                                      colorFilter: ColorFilter.mode(
                                        Palette.white100,
                                        BlendMode.srcIn,
                                      ),
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.sp),
                              Container(
                                width: 35.sp,
                                height: 35.sp,
                                decoration: BoxDecoration(
                                  color: Palette.red200,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: stylist.image.isNotEmpty
                                      ? Image.network(
                                          stylist.image,
                                          width: 40.sp,
                                          height: 40.sp,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Center(
                                              child: SizedBox(
                                                width: 20.sp,
                                                height: 20.sp,
                                                child: SvgPicture.asset(
                                                  'assets/icons/stylist/voka.svg',
                                                  colorFilter: ColorFilter.mode(
                                                    Palette.white100,
                                                    BlendMode.srcIn,
                                                  ),
                                                  fit: BoxFit.contain,
                                                ),
                                              ),
                                            );
                                          },
                                        )
                                      : Center(
                                          child: SizedBox(
                                            width: 20.sp,
                                            height: 20.sp,
                                            child: SvgPicture.asset(
                                              'assets/icons/stylist/voka.svg',
                                              colorFilter: ColorFilter.mode(
                                                Palette.white100,
                                                BlendMode.srcIn,
                                              ),
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 12.sp),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          '${stylist.name}',
                                          style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                        ),
                                        SizedBox(width: 4.sp),
                                        Text(
                                          '(${stylist.shortDescription})',
                                          style: TextStyles.titleSmall.copyWith(color: Palette.grey350),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          averageRating.toStringAsFixed(1),
                                          style: TextStyles.bodySmall.copyWith(color: Palette.white100),
                                        ),
                                        SizedBox(width: 4.sp),
                                        SvgPicture.asset(
                                          'assets/icons/stylist/star.svg',
                                          width: 16.sp,
                                          height: 16.sp,
                                          colorFilter: ColorFilter.mode(
                                            Palette.warning,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        SizedBox(width: 8.sp),
                                        Text(
                                          'Отзывов: ${stylist.reviews.length}',
                                          style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () => controller.selectStylist(stylist),
                                child: Container(
                                  width: 24.sp,
                                  height: 24.sp,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected ? Palette.red100 : Palette.grey350,
                                      width: 2,
                                    ),
                                    color: isSelected ? Palette.red100 : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? Icon(
                                          Icons.check,
                                          size: 16.sp,
                                          color: Palette.white100,
                                        )
                                      : null,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    });
                  },
                );
              }),
            ),
            
            SizedBox(height: 16.sp),
            
            // Кнопка выбрать
            Obx(() => SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: (controller.selectedStylist.value != null || controller.isRandomSelection.value)
                    ? ButtonStyles.primary 
                    : ButtonStyles.secondary,
                onPressed: (controller.selectedStylist.value != null || controller.isRandomSelection.value)
                    ? () => controller.confirmSelection()
                    : null,
                child: Text(
                  'Выбрать',
                  style: TextStyles.buttonMedium.copyWith(
                    color: (controller.selectedStylist.value != null || controller.isRandomSelection.value)
                        ? Palette.white100 
                        : Palette.grey350,
                  ),
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}