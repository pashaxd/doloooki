import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/adding_thing.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/controllers/wardrobe_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ItemInfo extends StatelessWidget {
  final String itemId;
  final WardrobeController wardrobeController = Get.put(WardrobeController());
  
  ItemInfo({super.key, required this.itemId});

  // Метод для получения актуального объекта ClothesItem
  ClothesItem? get currentItem {
    return wardrobeController.clothes.firstWhereOrNull((item) => item.id == itemId);
  }

  void _showDeleteConfirmation(BuildContext context) {
    final itemToDelete = currentItem;
    if (itemToDelete == null) {
       Get.snackbar('Ошибка', 'Вещь не найдена.');
       Get.back();
       return;
    }

    showDialog(
                                                                      context: context,
                                                                      builder: (context) => AlertDialog(
                                                                        backgroundColor: Palette.red400,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20),
                                                                        ),
                                                                        title: Text(
                                                                          'Удалить одежду',
                                                                          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                                                                          textAlign: TextAlign.center,
                                                                        ),
                                                                        content: Text(
                                                                          'Вы действительно хотите удалить одежду?',
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
                                                                                  wardrobeController.deleteClothes(itemToDelete.id);
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
    // Инициализируем отслеживание изменений при входе в экран
    final item = currentItem;
    if (item != null) {
      wardrobeController.startEditingItem(itemId);
    }
    
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await wardrobeController.showUnsavedChangesDialog();
        if (shouldPop) {
          wardrobeController.clearEditingState();
        }
        return shouldPop;
      },
      child: Scaffold(
        backgroundColor: Palette.red500,
        body: Obx(() {
          // Показываем индикатор загрузки, пока данные загружаются
          if (wardrobeController.isLoading.value || !wardrobeController.isDataReady()) {
            return Center(
              child: CircularProgressIndicator(
                color: Palette.white100,
              ),
            );
          }

          // Если элемент не найден, показываем сообщение и возвращаемся назад
          if (item == null) {
            Future.delayed(Duration.zero, () {
              Get.back();
              Get.snackbar(
                'Ошибка',
                'Вещь не найдена',
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
            child: SafeArea(
              child: Column(
                children: [
                  AppBar(
                    backgroundColor: Palette.red600,
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
                      PopupMenuButton<String>(
                        color: Palette.red400,
                        icon: Icon(Icons.more_horiz, color: Palette.white100),
                        onSelected: (value) {
                          switch (value) {
                            case 'edit':
                              Get.to(() => AddingThing(
                                isEditing: true,
                                clothesItem: item,
                              ));
                              break;
                            case 'delete':
                              _showDeleteConfirmation(context);
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
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Palette.white100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Image.network(
                                item.imageUrl,
                                width: Consts.screenWidth(context)*0.9,
                                height: Consts.screenHeight(context)*0.5,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          SizedBox(height: 16.sp,),
                          Text(
                            item.name,
                            style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                          ),
                          SizedBox(height: 8.sp,),
                          Text(
                            'Категория: ${item.category}',
                            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                          ),
                          SizedBox(height: 16.sp,),
                          Text(
                            'Описание',
                            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                          ),
                          SizedBox(height: 8.sp,),
                          Text(
                            item.description,
                            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                          ),
                          SizedBox(height: 24.sp,),
                          Text(
                            'Теги',
                            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: item.tags.map((tag) {
                              return Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Palette.red400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  tag,
                                  style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}