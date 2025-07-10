import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/adding_thing.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/widgets/wardrobe_card.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/screens/adding_pattern.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/screens/adding_pattern_image.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/controller/patterns_controller.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class PatternInfo extends StatelessWidget {
  final String patternId;
  final PatternsListController patternsListController = Get.find();
  
  PatternInfo({super.key, required this.patternId});

  // Метод для получения актуального объекта PatternItem
  PatternItem? get currentPattern {
    return patternsListController.patterns.firstWhereOrNull((item) => item.id == patternId);
  }

  // Метод для форматирования даты
  String _formatDate(dynamic timestamp) {
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Неизвестно';
      }
      
      final months = [
        'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
        'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Неизвестно';
    }
  }

  void _showDeleteConfirmation(BuildContext context, PatternItem pattern) {
     showDialog(
                                                                      context: context,
                                                                      builder: (context) => AlertDialog(
                                                                        backgroundColor: Palette.red400,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20),
                                                                        ),
                                                                        title: Text(
                                                                          'Удалить образ',
                                                                          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                        content: Text(
                                                                          'Вы действительно хотите удалить образ?',
                                                                          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                        actions: [
                                                                          Column(
                                                                            mainAxisAlignment: MainAxisAlignment.center,
                                                                            crossAxisAlignment: CrossAxisAlignment.center,
                                                                            children: [
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: 1,
                                                                                color: Palette.black300,
                                                                              ),
                                                                              TextButton(
                                                                                onPressed: () { 
                                                                                  Navigator.of(context).pop();
                                                                                  patternsListController.deletePattern(pattern.id);
                                                                                },
                                                                                child: Text('Удалить', style: TextStyles.buttonSmall.copyWith(color: Palette.error),textAlign: TextAlign.center,),
                                                                              ),
                                                                              SizedBox(height: 2.sp),
                                                                              Container(
                                                                                width: double.infinity,
                                                                                height: 1,
                                                                                color: Palette.black300,
                                                                              ),
                                                                              SizedBox(height: 2.sp),
                                                                              TextButton(
                                                                                onPressed: () => Navigator.of(context).pop(),
                                                                                child: Text('Отмена', style: TextStyles.buttonSmall.copyWith(color: Palette.white100),textAlign: TextAlign.center,),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ],
                                                                      ),
                                                                      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.red600,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Palette.red600,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Palette.white100,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: Container(
          decoration: BoxDecoration(
            color: Palette.red400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Palette.white100),
          ),
        ),
        actions: [
          Obx(() {
            // Показываем индикатор загрузки, пока данные загружаются
            if (patternsListController.isLoading.value || !patternsListController.isDataReady()) {
              return SizedBox.shrink();
            }
            
            final pattern = currentPattern;
            if (pattern == null) {
              return SizedBox.shrink();
            }
            
            return PopupMenuButton<String>(
              color: Palette.red400,
              icon: Icon(Icons.more_horiz, color: Palette.white100),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    // Открыть экран редактирования паттерна
                    Get.to(() => AddingPatternImage(
                      isEditing: true,
                      existingPattern: pattern,
                    ));
                    break;
                  case 'delete':
                    _showDeleteConfirmation(context, pattern);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => [
                PopupMenuItem<String>(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Palette.white100, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Редактировать',
                        style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Palette.error, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Удалить',
                        style: TextStyles.bodyMedium.copyWith(color: Palette.error),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ],
      ),
      body: Obx(() {
        // Показываем индикатор загрузки, пока данные загружаются
        if (patternsListController.isLoading.value || !patternsListController.isDataReady()) {
          return Center(
            child: CircularProgressIndicator(
              color: Palette.white100,
            ),
          );
        }

        final pattern = currentPattern;

        // Если элемент не найден, показываем сообщение и возвращаемся назад
        if (pattern == null) {
          Future.delayed(Duration.zero, () {
            Get.back();
            Get.snackbar(
              'Ошибка',
              'Образ не найден',
              backgroundColor: Palette.error,
              colorText: Palette.white100,
            );
          });
          return Center(
            child: CircularProgressIndicator(
              color: Palette.white100,
            ),
          );
        }

        // Если элемент найден, показываем детали
        return Container(
          color: Palette.red600,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.network(
                      pattern.imageUrl,
                      width: Consts.screenWidth(context)*0.9,
                      height: Consts.screenHeight(context)*0.5,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(Icons.image, size: 60),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  pattern.name,
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.calendar_today, color: Palette.grey350, size: 16.sp),
                    SizedBox(width: 4.sp),
                    Text(
                      'Создан ${_formatDate(pattern.createdAt)}',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    ),
                  ],
                ),
                if (pattern.description.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Описание',
                    style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    pattern.description,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Используемые предметы',
                  style: TextStyles.titleSmall.copyWith(color: Palette.grey350),
                ),
                const SizedBox(height: 8),
                pattern.usedItems.isEmpty
                  ? Text(
                      'Нет данных',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    )
                  : GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 0.5,
                      ),
                      itemCount: pattern.usedItems.length,
                      itemBuilder: (context, index) {
                        final item = pattern.usedItems[index];
                        return SizedBox(
                          width: 100.sp,
                          height: 300.sp,
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  item['imageUrl'],
                                  width: Consts.screenWidth(context)*0.3,
                                  height: Consts.screenHeight(context)*0.2,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Icon(Icons.image, size: 60),
                                ),
                              ),
                              SizedBox(height: 10,),
                              Text(item['name'], style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                            ],
                          ),
                        );
                      },
                    ),
              ],
            ),
          ),
        );
      }),
    );
  }
}