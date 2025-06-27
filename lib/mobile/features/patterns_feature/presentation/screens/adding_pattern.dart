import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:doloooki/mobile/features/patterns_feature/presentation/controller/adding_pattern_controller.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter/rendering.dart';

class AddingPattern extends StatefulWidget {
  final Uint8List? imageBytes;
  final bool isEditing;
  final PatternItem? existingPattern;
  
  const AddingPattern({
    super.key, 
    this.imageBytes,
    this.isEditing = false,
    this.existingPattern,
  });

  @override
  State<AddingPattern> createState() => _AddingPatternState();
}

class _AddingPatternState extends State<AddingPattern> {
  final _formKey = GlobalKey<FormState>();
  final AddingPatternController controller = Get.find();

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.existingPattern != null) {
      controller.nameController.text = widget.existingPattern!.name;
      controller.descriptionController.text = widget.existingPattern!.description;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _savePattern() async {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      
      if (widget.isEditing && widget.existingPattern != null) {
        await controller.updatePattern(
          patternId: widget.existingPattern!.id,
          name: controller.nameController.text,
          description: controller.descriptionController.text,
          imageBytes: widget.imageBytes,
        );
      } else {
        await controller.savePattern(
          imageBytes: widget.imageBytes!,
          name: controller.nameController.text,
          description: controller.descriptionController.text,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return  Obx(() => Container(
      color: Palette.red600,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (widget.isEditing) {
              final shouldPop = await controller.showUnsavedChangesDialog();
              if (shouldPop) {
                controller.clearEditingState();
              }
              return shouldPop;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Palette.red600,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Palette.red600,
              title: Text(
                widget.isEditing ? 'Редактирование образа' : 'Сохранение образа',
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new, color: Palette.white100),
                onPressed: () async {
                  if (widget.isEditing) {
                    final shouldPop = await controller.showUnsavedChangesDialog();
                    if (shouldPop) {
                      controller.clearEditingState();
                      Get.back();
                    }
                  } else {
                    Get.back();
                  }
                },
              ),
            ),
            body: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(16.sp),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            height: 300.sp,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Palette.red400),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: widget.imageBytes != null 
                                ? Image.memory(
                                    widget.imageBytes!,
                                    fit: BoxFit.contain,
                                  )
                                : widget.existingPattern != null
                                  ? Image.network(
                                      widget.existingPattern!.imageUrl,
                                      fit: BoxFit.contain,
                                    )
                                  : Container(
                                      color: Palette.red400,
                                      child: Center(
                                        child: Text(
                                          'Нет изображения',
                                          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                          SizedBox(height: 24.sp),
                          Column(
                            spacing: 4.sp,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Название образа', style: TextStyles.labelMedium.copyWith(color: controller.isNameFocused.value ? Palette.white100 : Palette.grey350)),
                              Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  border: controller.isNameFocused.value
                                      ? Border.all(color: Palette.white200)
                                      : Border.all(width: 0),
                                  color: Palette.red400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: TextField(
                                  
                                  controller: controller.nameController,
                                  onTap: () => controller.setFocus('name'),
                                  onTapOutside: (_) {
                                    controller.setFocus('');
                                    FocusScope.of(context).unfocus();
                                  },
                                  style: TextStyles.bodyLarge.copyWith(
                                    color: Palette.white200,
                                  ),
                                  maxLength: 30,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Например: Повседневный образ',
                                    hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                    counterText: '',
                                  ),
                                ),
                              )),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Obx(() => Text(
                                  '${controller.nameLength.value}/30',
                                  style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
                                )),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.sp),
                          Column(
                            spacing: 4.sp,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Описание', style: TextStyles.labelMedium.copyWith(color: controller.isDescriptionFocused.value ? Palette.white100 : Palette.grey350)),
                              Obx(() => Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  border: controller.isDescriptionFocused.value
                                      ? Border.all(color: Palette.white200)
                                      : Border.all(width: 0),
                                  color: Palette.red400,
                                  borderRadius: BorderRadius.circular(20),
                                  
                                ),
                                child: TextField(
                                  maxLines: 2,
                                  controller: controller.descriptionController,
                                  onTap: () => controller.setFocus('description'),
                                  onTapOutside: (_) {
                                    controller.setFocus('');
                                    FocusScope.of(context).unfocus();
                                  },
                                  style: TextStyles.bodyLarge.copyWith(
                                    color: Palette.white200,
                                  ),
                                  maxLength: 200,
                                  minLines: 1,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Опишите ваш образ...',
                                    hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                    counterText: '',
                                  ),
                                ),
                              )),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                                                  Text('Необязательно', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),

                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: Obx(() => Text(
                                      '${controller.descriptionLength.value}/200',
                                      style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
                                    )),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(() => Container(
                  width: double.infinity,
                  height: 80.sp,
                  padding: EdgeInsets.all(16.sp),
                  child: ElevatedButton(
                        onPressed: controller.isSaving.value || !controller.isNameValid ? null : _savePattern,
                        style: controller.isSaving.value || !controller.isNameValid ? ButtonStyles.secondary : ButtonStyles.primary,
                        child: controller.isSaving.value
                            ? CircularProgressIndicator(color: Palette.white100)
                            : Text(
                                widget.isEditing ? 'Сохранить изменения' : 'Сохранить образ',
                                style: TextStyles.buttonSmall.copyWith(
                                    color:controller.isNameValid ? Palette.white100 : Palette.grey350),
                              ),
                      ),
                )),
              ],
            ),
            ),
          ),
        ),
      ));
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
      filled: true,
      fillColor: Palette.red400,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: Palette.white100, width: 1),
      ),
    );
  }
}