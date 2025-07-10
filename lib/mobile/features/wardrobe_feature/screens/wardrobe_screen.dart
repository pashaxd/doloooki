import 'package:doloooki/mobile/features/wardrobe_feature/screens/adding_thing.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/item_info.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/widgets/wardrobe_card.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/controllers/wardrobe_controller.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WardrobeScreen extends StatelessWidget {
  const WardrobeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Используем GetBuilder для ленивой инициализации
    return GetBuilder<WardrobeController>(
      init: WardrobeController(),
      builder: (wardrobeController) {
        final List<String> categoriesWithAll = ['Все', ...wardrobeController.categories];
        
        return Container(
          color: Palette.red600,
          child: SafeArea(
            child: Scaffold(
              backgroundColor: Palette.red600,
              body: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Гардероб', style: TextStyles.headlineMedium.copyWith(color: Palette.white100)),
                    const SizedBox(height: 16),
                    // Фильтр категорий
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: categoriesWithAll.length,
                              itemBuilder: (context, index) {
                                final category = categoriesWithAll[index];
                                return Obx(() => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: ChoiceChip(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    label: Text(category),
                                    selected: (category == 'Все' && wardrobeController.selectedCategory.value == '') ||
                                              (category != 'Все' && wardrobeController.selectedCategory.value == category),
                                    onSelected: (selected) {
                                      if (category == 'Все') {
                                        wardrobeController.setCategory('');
                                      } else {
                                        wardrobeController.setCategory(category);
                                      }
                                    },
                                    backgroundColor: Palette.red600,
                                    selectedColor: Palette.red100,
                                    side: BorderSide.none,
                                    showCheckmark: false,
                                    labelStyle: TextStyles.bodyMedium.copyWith(
                                      color: ((category == 'Все' && wardrobeController.selectedCategory.value == '') ||
                                             (category != 'Все' && wardrobeController.selectedCategory.value == category))
                                          ? Palette.white100
                                          : Palette.grey350,
                                    ),
                                  ),
                                ));
                              },
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.filter_alt, color: Palette.grey350),
                          onPressed: () {
                            final RxList<String> tempSelectedTags = RxList<String>.from(wardrobeController.selectedTags);
            
                            Get.bottomSheet(
                              StatefulBuilder(
                                builder: (context, setState) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Palette.red600,
                                      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                                    ),
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Теги:', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                                        const SizedBox(height: 16),
                                        Wrap(
                                          spacing: 8,
                                          runSpacing: 8,
                                          children: wardrobeController.tags.map((tag) {
                                            final selected = tempSelectedTags.contains(tag);
                                            return FilterChip(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              label: Text(tag),
                                              selected: selected,
                                              onSelected: (isSelected) {
                                                setState(() {
                                                  if (isSelected) {
                                                    tempSelectedTags.add(tag);
                                                  } else {
                                                    tempSelectedTags.remove(tag);
                                                  }
                                                });
                                              },
                                              showCheckmark: false,
                                              backgroundColor: Palette.red400,
                                              selectedColor: Palette.red100,
                                              side: BorderSide.none,
                                              labelStyle: TextStyles.titleSmall.copyWith(
                                                color: selected ? Palette.white100 : Palette.white100,
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                        const SizedBox(height: 24),
                                        Row(
                                          children: [
                                            SizedBox(
                                              width: Consts.screenWidth(context)*0.9,
                                              height: Consts.screenHeight(context)*0.06,
                                              child: ElevatedButton(
                                                style: tempSelectedTags.isEmpty ? ButtonStyles.secondary : ButtonStyles.primary,
                                                onPressed: () {
                                                  wardrobeController.selectedTags.value = tempSelectedTags;
                                                  Get.back();
                                                },
                                                child: Text('Применить', style: TextStyles.buttonMedium.copyWith(color: Palette.white100)),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              isScrollControlled: true,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Obx(() {
                        if (wardrobeController.isLoading.value) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: Palette.white100,
                            ),
                          );
                        }
                        
                        if (wardrobeController.clothes.isEmpty) {
                          return Center(
                            child: Column(
                              spacing: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Image.asset('assets/icons/bottom_navigation/garderob.png', color: Palette.grey350,),
                                Text('Ваша гардеробная пуста', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
                                Text(
                                  'Здесь будут храниться все ваши вещи — от любимых джинсов до вечерних нарядов. Начните с малого — добавьте первую вещь!',
                                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(
                                  width: 200.sp,
                                  child: ElevatedButton(
                                    style: ButtonStyles.primary,
                                    onPressed: () {
                                      Get.to(() => AddingThing());
                                    },
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Palette.white100,),
                                        Text('Добавить одежду', style: TextStyles.buttonSmall.copyWith(color: Palette.white100)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return GridView.builder(
                            padding: const EdgeInsets.only(top: 16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.5,
                            ),
                            itemCount: wardrobeController.clothes.length,
                            itemBuilder: (context, index) {
                              final item = wardrobeController.clothes[index];
                              return GestureDetector(
                                onTap: () => Get.to(() => ItemInfo(itemId: item.id)),
                                child: SizedBox(
                                  width: Consts.screenWidth(context)*0.3,
                                  height: Consts.screenHeight(context)*0.2,
                                  child: Column(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(
                                          item.imageUrl,
                                          width: Consts.screenWidth(context)*0.3,
                                          height: Consts.screenHeight(context)*0.2,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(Icons.image, size: 60),
                                        ),
                                      ),
                                      SizedBox(height: 10),
                                      Text(
                                        item.name,
                                        style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        }
                      }),
                    ),
                  ],
                ),
              ),
              floatingActionButton: Obx(() {
                if (wardrobeController.clothes.isEmpty) {
                  return const SizedBox.shrink();
                }
                return FloatingActionButton(
                  onPressed: () {
                    Get.to(() => AddingThing());
                  },
                  backgroundColor: Palette.red100,
                  child: Icon(Icons.add, color: Palette.white100,),
                );
              }),
            ),
          ),
        );
      },
    );
  }
}

