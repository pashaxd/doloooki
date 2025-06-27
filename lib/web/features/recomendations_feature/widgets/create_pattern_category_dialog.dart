import 'dart:typed_data';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class CreatePatternCategoryDialog extends StatefulWidget {
  const CreatePatternCategoryDialog({super.key});

  @override
  State<CreatePatternCategoryDialog> createState() => _CreatePatternCategoryDialogState();
}

class _CreatePatternCategoryDialogState extends State<CreatePatternCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  final List<PatternItemData> _patterns = [];
  bool _isLoading = false;
  
  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
  
  bool get _isValid => _nameController.text.trim().isNotEmpty && _patterns.isNotEmpty;
  
  void _addPattern() {
    setState(() {
      _patterns.add(PatternItemData());
    });
  }
  
  void _removePattern(int index) {
    setState(() {
      _patterns.removeAt(index);
    });
  }
  
  Future<void> _pickImage(int index) async {
    final result = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    
    if (result != null) {
      final bytes = await result.readAsBytes();
      setState(() {
        _patterns[index].imageBytes = bytes;
        _patterns[index].imageName = result.name;
      });
    }
  }
  
  Future<void> _saveCategory() async {
    if (!_isValid || _isLoading) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Создаем документ категории
      final categoryDoc = FirebaseFirestore.instance.collection('recPatterns').doc();
      
      // Загружаем изображения и создаем паттерны
      final List<Map<String, dynamic>> patterns = [];
      
      for (int i = 0; i < _patterns.length; i++) {
        final pattern = _patterns[i];
        
        String? imageUrl;
        if (pattern.imageBytes != null) {
          // Загружаем изображение в Storage
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('pattern_categories')
              .child(categoryDoc.id)
              .child('pattern_$i.jpg');
          
          await storageRef.putData(pattern.imageBytes!);
          imageUrl = await storageRef.getDownloadURL();
        }
        
        patterns.add({
          'name': pattern.nameController.text.trim(),
          'description': pattern.descriptionController.text.trim(),
          'imageUrl': imageUrl ?? '',
          'category': _nameController.text.trim(),
          'usedItems': <String>[], // Пустой массив используемых предметов
        });
      }
      
      // Сохраняем категорию
      await categoryDoc.set({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'patterns': patterns,
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      Get.back();
      Get.snackbar(
        'Успех',
        'Категория образов создана',
        backgroundColor: Palette.success,
        colorText: Palette.white100,
      );
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось создать категорию: $e',
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
                        'Создать категорию образов',
                        style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                      ),
                      Text(
                        'Создайте новую категорию с образами для рекомендаций',
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
                  // Левая панель - информация о категории
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
                            'Информация о категории',
                            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                          ),
                          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                          
                          // Название категории
                          TextField(
                            controller: _nameController,
                            style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                            decoration: InputDecoration(
                              labelText: 'Название категории',
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
                          
                          // Описание категории
                          TextField(
                            controller: _descriptionController,
                            maxLines: 3,
                            style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                            decoration: InputDecoration(
                              labelText: 'Описание категории',
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
                            child: Row(
                              children: [
                                Icon(Icons.style, color: Palette.white100),
                                SizedBox(width: ResponsiveUtils.containerSize(8.w)),
                                Text(
                                  'Образов в категории: ${_patterns.length}',
                                  style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  // Правая панель - список образов
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок с кнопкой добавления
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
                                'Образы',
                                style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                onPressed: _addPattern,
                                icon: Icon(Icons.add, color: Palette.white100),
                                label: Text(
                                  'Добавить образ',
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
                        
                        // Список образов
                        Expanded(
                          child: _patterns.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.style_outlined,
                                        size: ResponsiveUtils.containerSize(64.sp),
                                        color: Palette.grey350,
                                      ),
                                      SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                                      Text(
                                        'Нет образов',
                                        style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                      ),
                                      SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                                      Text(
                                        'Добавьте образы для создания категории',
                                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.containerSize(10.sp)),
                                  itemCount: _patterns.length,
                                  separatorBuilder: (context, index) => SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                                  itemBuilder: (context, index) {
                                    return _buildPatternCard(index);
                                  },
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
                      onPressed: _isValid && !_isLoading ? _saveCategory : null,
                      style: _isValid ? ButtonStyles.primary : ButtonStyles.secondary,
                      child: _isLoading
                          ? SizedBox(
                              width: ResponsiveUtils.containerSize(20.w),
                              height: ResponsiveUtils.containerSize(20.h),
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Создать категорию',
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
  
  Widget _buildPatternCard(int index) {
    final pattern = _patterns[index];
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(10.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(16.r)),
       
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок карточки с кнопкой удаления
          Row(
            children: [
              Text(
                'Образ ${index + 1}',
                style: TextStyles.titleSmall.copyWith(color: Palette.white100),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => _removePattern(index),
                icon: Icon(Icons.delete, color: Palette.error, size: ResponsiveUtils.containerSize(20.sp)),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(12.h)),
          
          Row(
            children: [
              // Изображение
              GestureDetector(
                onTap: () => _pickImage(index),
                child: Container(
                  width: ResponsiveUtils.containerSize(100.w),
                  height: ResponsiveUtils.containerSize(450.h),
                  decoration: BoxDecoration(
                    color: Palette.red500,
                    borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                    border: Border.all(color: Palette.red300, width: 1),
                  ),
                  child: pattern.imageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                          child: Image.memory(
                            pattern.imageBytes!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate,
                              color: Palette.grey350,
                              size: ResponsiveUtils.containerSize(24.sp),
                            ),
                            SizedBox(height: ResponsiveUtils.containerSize(4.h)),
                            Text(
                              'Добавить\nфото',
                              style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(width: ResponsiveUtils.containerSize(16.w)),
              
              // Поля названия и описания
              Expanded(
                child: Column(
                  children: [
                    // Название образа
                    SizedBox(
                      height: ResponsiveUtils.containerSize(200.h),
                      child: TextField(
                        controller: pattern.nameController,
                        style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                        decoration: InputDecoration(
                          labelText: 'Название образа',
                          labelStyle: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                          filled: true,
                          fillColor: Palette.red500,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(8.r)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.containerSize(12.w),
                            vertical: ResponsiveUtils.containerSize(8.h),
                          ),
                          counterText: '',
                        ),
                        maxLength: 30,
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                    
                    // Описание образа
                    SizedBox(
                      height: ResponsiveUtils.containerSize(200.h),
                      child: TextField(
                        controller: pattern.descriptionController,
                        maxLines: 2,
                        style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                        decoration: InputDecoration(
                          labelText: 'Описание образа',
                          labelStyle: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                          filled: true,
                          fillColor: Palette.red500,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(8.r)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtils.containerSize(12.w),
                            vertical: ResponsiveUtils.containerSize(8.h),
                          ),
                          counterText: '',
                          alignLabelWithHint: true,
                        ),
                        maxLength: 100,
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PatternItemData {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  Uint8List? imageBytes;
  String? imageName;
  
  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
  }
}

// Функция для показа диалога
void showCreatePatternCategoryDialog() {
  Get.dialog(
    const CreatePatternCategoryDialog(),
    barrierDismissible: false,
  );
} 