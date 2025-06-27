import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/web/features/recomendations_feature/controllers/rec_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateColorPaletteDialog extends StatefulWidget {
  const CreateColorPaletteDialog({super.key});

  @override
  State<CreateColorPaletteDialog> createState() => _CreateColorPaletteDialogState();
}

class _CreateColorPaletteDialogState extends State<CreateColorPaletteDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final List<String> _colors = [];
  final List<List<String>> _combinations = [];
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  bool get _isValid => _nameController.text.trim().isNotEmpty && _colors.isNotEmpty;
  
  void _addColor() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Palette.red400,
        title: Text(
          'Добавить цвет',
          style: TextStyles.titleMedium.copyWith(color: Palette.white100),
        ),
        content: TextField(
          controller: controller,
          style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
          decoration: InputDecoration(
            labelText: 'HEX код цвета (например: #FF5733)',
            labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            filled: true,
            fillColor: Palette.red500,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Отмена',
              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final colorText = controller.text.trim();
              if (colorText.isNotEmpty) {
                // Убираем # если есть и добавляем его обратно
                final cleanColor = colorText.replaceAll('#', '');
                if (cleanColor.length == 6 && RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleanColor)) {
                  setState(() {
                    _colors.add('#$cleanColor');
                  });
                  Get.back();
                } else {
                  Get.snackbar(
                    'Ошибка',
                    'Неверный формат цвета. Используйте HEX формат (например: #FF5733)',
                    backgroundColor: Palette.error,
                    colorText: Palette.white100,
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Palette.red100),
            child: Text(
              'Добавить',
              style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
            ),
          ),
        ],
      ),
    );
  }
  
  void _removeColor(int index) {
    setState(() {
      _colors.removeAt(index);
    });
  }
  
  void _addCombination() {
    setState(() {
      _combinations.add(['', '', '', '']);
    });
  }
  
  void _removeCombination(int index) {
    setState(() {
      _combinations.removeAt(index);
    });
  }
  
  void _updateCombinationColor(int combIndex, int colorIndex, String colorHex) {
    setState(() {
      _combinations[combIndex][colorIndex] = colorHex;
    });
  }
  
  Future<void> _savePalette() async {
    if (!_isValid || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Создаем документ палитры
      final paletteDoc = FirebaseFirestore.instance.collection('recColors').doc();
      
      // Подготавливаем комбинации - только те, что заполнены
      final List<String> validCombinations = [];
      for (final combination in _combinations) {
        final filledColors = combination.where((c) => c.isNotEmpty).toList();
        if (filledColors.length == 4) {
          validCombinations.add(filledColors.join(', '));
        }
      }
      
      // Сохраняем палитру
      await paletteDoc.set({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'colors': _colors,
        'combinations': validCombinations,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      Get.back();
      Get.snackbar(
        'Успех',
        'Цветовая палитра создана',
        backgroundColor: Palette.red100,
        colorText: Palette.white100,
      );
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось создать палитру: $e',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.red400,
      insetPadding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Palette.red600,
          borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(20.r)),
        ),
        child: Column(
          children: [
            // Заголовок
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
              decoration: BoxDecoration(
                color: Palette.red500,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(ResponsiveUtils.containerSize(20.r)),
                  topRight: Radius.circular(ResponsiveUtils.containerSize(20.r)),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Создать цветовую палитру',
                        style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                      ),
                      Text(
                        'Создайте новую цветовую палитру для рекомендаций',
                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: Icon(Icons.close, color: Palette.white100),
                  ),
                ],
              ),
            ),
            
            // Основной контент
            Expanded(
              child: Row(
                children: [
                  // Левая панель - информация о палитре
                  Expanded(
                    flex: 2,
                    child: Container(
                      margin: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
                      padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
                      decoration: BoxDecoration(
                        color: Palette.red400,
                        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(20.r)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Информация о палитре',
                            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                          ),
                          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                          
                          // Название палитры
                          TextField(
                            controller: _nameController,
                            style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                            decoration: InputDecoration(
                              labelText: 'Название палитры',
                              labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                              filled: true,
                              fillColor: Palette.red500,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                                borderSide: BorderSide.none,
                              ),
                              counterText: '',
                            ),
                            maxLength: 50,
                            onChanged: (value) => setState(() {}),
                          ),
                          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                          
                          // Описание палитры
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                            decoration: InputDecoration(
                              labelText: 'Описание палитры',
                              labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                              filled: true,
                              fillColor: Palette.red500,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                                borderSide: BorderSide.none,
                              ),
                              counterText: '',
                              alignLabelWithHint: true,
                            ),
                            maxLength: 200,
                            onChanged: (value) => setState(() {}),
                          ),
                          
                          const Spacer(),
                          
                          // Статистика
                          Container(
                            padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
                            decoration: BoxDecoration(
                              color: Palette.red500,
                              borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.palette, color: Palette.white100),
                                    SizedBox(width: ResponsiveUtils.containerSize(8.w)),
                                    Text(
                                      'Цветов: ${_colors.length}',
                                      style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                                    ),
                                  ],
                                ),
                                SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                                Row(
                                  children: [
                                    Icon(Icons.color_lens, color: Palette.white100),
                                    SizedBox(width: ResponsiveUtils.containerSize(8.w)),
                                    Text(
                                      'Комбинаций: ${_combinations.length}',
                                      style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Правая панель - цвета и комбинации
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        // Секция цветов
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Заголовок цветов
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  ResponsiveUtils.containerSize(20.w),
                                  ResponsiveUtils.containerSize(20.h),
                                  ResponsiveUtils.containerSize(20.w),
                                  ResponsiveUtils.containerSize(16.h),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Цвета',
                                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: _addColor,
                                      icon: Icon(Icons.add, color: Palette.white100),
                                      label: Text(
                                        'Добавить цвет',
                                        style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Palette.red100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Список цветов
                              Expanded(
                                child: _colors.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.palette_outlined,
                                              size: ResponsiveUtils.containerSize(48.sp),
                                              color: Palette.grey350,
                                            ),
                                            SizedBox(height: ResponsiveUtils.containerSize(12.h)),
                                            Text(
                                              'Нет цветов',
                                              style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                                            ),
                                            Text(
                                              'Добавьте цвета для палитры',
                                              style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                                            ),
                                          ],
                                        ),
                                      )
                                    : Padding(
                                        padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.containerSize(20.w)),
                                        child: GridView.builder(
                                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 4,
                                            crossAxisSpacing: ResponsiveUtils.containerSize(12.w),
                                            mainAxisSpacing: ResponsiveUtils.containerSize(12.h),
                                            childAspectRatio: 1,
                                          ),
                                          itemCount: _colors.length,
                                          itemBuilder: (context, index) {
                                            return _buildColorCard(index);
                                          },
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Секция комбинаций
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Заголовок комбинаций
                              Padding(
                                padding: EdgeInsets.fromLTRB(
                                  ResponsiveUtils.containerSize(20.w),
                                  ResponsiveUtils.containerSize(16.h),
                                  ResponsiveUtils.containerSize(20.w),
                                  ResponsiveUtils.containerSize(16.h),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      'Комбинации цветов',
                                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                    ),
                                    const Spacer(),
                                    ElevatedButton.icon(
                                      onPressed: _addCombination,
                                      icon: Icon(Icons.add, color: Palette.white100),
                                      label: Text(
                                        'Добавить комбинацию',
                                        style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Palette.red100,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Список комбинаций
                              Expanded(
                                child: _combinations.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.color_lens_outlined,
                                              size: ResponsiveUtils.containerSize(48.sp),
                                              color: Palette.grey350,
                                            ),
                                            SizedBox(height: ResponsiveUtils.containerSize(12.h)),
                                            Text(
                                              'Нет комбинаций',
                                              style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                                            ),
                                            Text(
                                              'Добавьте цветовые комбинации',
                                              style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                                            ),
                                          ],
                                        ),
                                      )
                                    : ListView.separated(
                                        padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.containerSize(20.w)),
                                        itemCount: _combinations.length,
                                        separatorBuilder: (context, index) => SizedBox(height: ResponsiveUtils.containerSize(12.h)),
                                        itemBuilder: (context, index) {
                                          return _buildCombinationCard(index);
                                        },
                                      ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Нижняя панель с кнопками
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
              decoration: BoxDecoration(
                color: Palette.red500,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(ResponsiveUtils.containerSize(20.r)),
                  bottomRight: Radius.circular(ResponsiveUtils.containerSize(20.r)),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Отмена',
                        style: TextStyles.buttonSmall.copyWith(color: Palette.grey350),
                      ),
                    ),
                  ),
                  SizedBox(width: ResponsiveUtils.containerSize(16.w)),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isValid && !_isLoading ? _savePalette : null,
                      style: _isValid ? ButtonStyles.primary : ButtonStyles.secondary,
                      child: _isLoading
                          ? SizedBox(
                              width: ResponsiveUtils.containerSize(20.w),
                              height: ResponsiveUtils.containerSize(20.h),
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Создать палитру',
                              style: TextStyles.buttonSmall.copyWith(
                                color: _isValid ? Palette.white100 : Palette.grey350,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildColorCard(int index) {
    final colorHex = _colors[index];
    final controller = Get.find<RecController>();
    
    return Container(
      decoration: BoxDecoration(
        color: Color(controller.getColorFromHex(colorHex)),
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
        border: Border.all(color: Palette.white100, width: 2),
      ),
      child: Stack(
        children: [
          // Удаление цвета
          Positioned(
            top: ResponsiveUtils.containerSize(4.h),
            right: ResponsiveUtils.containerSize(4.w),
            child: GestureDetector(
              onTap: () => _removeColor(index),
              child: Container(
                width: ResponsiveUtils.containerSize(20.w),
                height: ResponsiveUtils.containerSize(20.h),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: ResponsiveUtils.containerSize(14.sp),
                ),
              ),
            ),
          ),
          
          // Текст с HEX кодом
          Positioned(
            bottom: ResponsiveUtils.containerSize(4.h),
            left: ResponsiveUtils.containerSize(4.w),
            right: ResponsiveUtils.containerSize(4.w),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.containerSize(4.w),
                vertical: ResponsiveUtils.containerSize(2.h),
              ),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(4.r)),
              ),
              child: Text(
                colorHex,
                style: TextStyles.bodySmall.copyWith(
                  color: Colors.white,
                  fontSize: ResponsiveUtils.containerSize(10.sp),
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildCombinationCard(int index) {
    final combination = _combinations[index];
    final controller = Get.find<RecController>();
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(12.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
        border: Border.all(color: Palette.red300, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с кнопкой удаления
          Row(
            children: [
              Text(
                'Комбинация ${index + 1}',
                style: TextStyles.titleSmall.copyWith(color: Palette.white100),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removeCombination(index),
                icon: Icon(Icons.delete, color: Palette.error, size: ResponsiveUtils.containerSize(20.sp)),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          
          // 4 цветовых поля
          Row(
            children: List.generate(4, (colorIndex) {
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: colorIndex < 3 ? ResponsiveUtils.containerSize(8.w) : 0,
                  ),
                  child: Column(
                    children: [
                      // Превью цвета
                      Container(
                        height: ResponsiveUtils.containerSize(60.h),
                        decoration: BoxDecoration(
                          color: combination[colorIndex].isNotEmpty
                              ? Color(controller.getColorFromHex(combination[colorIndex]))
                              : Palette.grey350,
                          borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(8.r)),
                          border: Border.all(color: Palette.grey350, width: 1),
                        ),
                      ),
                      SizedBox(height: ResponsiveUtils.containerSize(4.h)),
                      
                      // Поле ввода HEX
                      TextField(
                        style: TextStyles.bodySmall.copyWith(color: Palette.white100),
                        decoration: InputDecoration(
                          hintText: '#HEX',
                          hintStyle: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                          filled: true,
                          fillColor: Palette.red500,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(6.r)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.containerSize(8.w),
                            vertical: ResponsiveUtils.containerSize(4.h),
                          ),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          final cleanColor = value.replaceAll('#', '');
                          if (cleanColor.length == 6 && RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleanColor)) {
                            _updateCombinationColor(index, colorIndex, '#$cleanColor');
                          } else if (value.isEmpty) {
                            _updateCombinationColor(index, colorIndex, '');
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// Функция для показа диалога
void showCreateColorPaletteDialog() {
  Get.dialog(
    const CreateColorPaletteDialog(),
    barrierDismissible: false,
  );
} 