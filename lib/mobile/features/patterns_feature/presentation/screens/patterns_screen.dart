import 'package:doloooki/mobile/features/patterns_feature/presentation/screens/adding_pattern_image.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/screens/pattern_info.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/pattern_item.dart';
import '../controller/patterns_controller.dart';

class PatternsScreen extends StatelessWidget {
  const PatternsScreen({super.key});

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(PatternsListController());

    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          
          body: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
            child: Column(
               crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                
                Text('Образы', style: TextStyles.headlineMedium.copyWith(color: Palette.white100),),
                Expanded(
                  child: Obx(() {
                    if (controller.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    }
                    if (controller.patterns.isEmpty) {
                      return Center(
                        child: Column(
                          spacing: 8.sp,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/bottom_navigation/garderob.png', color: Palette.grey350,),
                            Text('Ваша гардеробная пуста', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
                            Text(
                              'Здесь будут храниться все ваши созданные образы. Миксуй одежду между собой и сохраняй самые стильные варианты!',
                              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                              textAlign: TextAlign.center,
                            ),
                            
                            SizedBox(
                              width: 170.sp,
                              child: ElevatedButton(
                                style: ButtonStyles.primary,
                                onPressed: () {
                                  Get.to(() => AddingPatternImage());
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.add, color: Palette.white100,),
                                    Text('Создать образ', style: TextStyles.buttonSmall.copyWith(color: Palette.white100),),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      padding: EdgeInsets.only(top: 16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.7,
                      ),
                      itemCount: controller.patterns.length,
                      itemBuilder: (context, index) {
                        final pattern = controller.patterns[index];
                        return GestureDetector(
                          onTap: () {
                            Get.to(() => PatternInfo(patternId: pattern.id));
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Palette.white50,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.network(
                                      pattern.imageUrl,
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, __, ___) => Icon(Icons.image, size: 60),
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
                                        style: TextStyles.titleLarge.copyWith(color: Palette.black100),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        _formatDate(pattern.createdAt.toDate()),
                                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
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
                  }),
                ),
                ],
            ),
          ),
           floatingActionButton: Obx(() => controller.patterns.isNotEmpty 
            ? FloatingActionButton(
                backgroundColor: Palette.red100,
                onPressed: () {
                  Get.to(() => AddingPatternImage());
                },
                child: Icon(Icons.add, color: Palette.white100),
                tooltip: 'Создать образ',
              )
            : SizedBox()
          ),
        ),
      ),
    );
  }
}