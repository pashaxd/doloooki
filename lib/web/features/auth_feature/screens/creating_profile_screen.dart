import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/web/features/auth_feature/controllers/creating_profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'dart:typed_data';
import 'dart:io';

class CreatingProfileScreenWeb extends StatelessWidget {
  const CreatingProfileScreenWeb({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreatingProfileController());
    
    return Scaffold(
      backgroundColor: Palette.red20,
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w),
          padding: EdgeInsets.all(20.sp.adaptiveSpacing),
          width: 500.w.adaptiveContainer,
   
          decoration: BoxDecoration(
            color: Palette.red600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            spacing: 20.h.adaptiveSpacing,
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Кнопка назад
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back,
                          color: Palette.white100,
                          size: 14.sp.adaptiveIcon,
                        ),
                        SizedBox(width: 5.w.adaptiveSpacing),
                        Text(
                          'Назад',
                          style: TextStyles.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                ],
              ),
              
              Text(
                'Заполнение данных',
                style: TextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              
              Text(
                'После отправки ваша информация будет проверена администратором. Доступ к сервису будет предоставлен после успешной проверки.',
                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                textAlign: TextAlign.center,
              ),
              
              // Секция фотографии
              Column(
                children: [
                  Text(
                    'Фотография:',
                    style: TextStyles.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 10.h),
                  
                  // Область загрузки фото
                  Obx(() => GestureDetector(
                    onTap: controller.selectPhoto,
                    child: Container(
                      width: double.infinity,
                      height: 150.h,
                      
                      decoration: BoxDecoration(
                        color: Palette.red600,
                        borderRadius: BorderRadius.circular(8),
                        border: controller.isPhotoSelected.value ? null : Border.all(
                          color: Palette.white100.withOpacity(0.3),
                          style: BorderStyle.solid,
                          strokeAlign: BorderSide.strokeAlignInside,
                        ),
                      ),
                      child: controller.isPhotoSelected.value
                          ? _buildPhotoPreview(controller)
                          : _buildPhotoPlaceholder(),
                    ),
                  )),
                ],
              ),
              
              // Поле имени с анимированным лейблом как в auth_feature
              Obx(() => TextFormField(
                controller: controller.nameController,
                style: TextStyles.bodyMedium,
                maxLength: CreatingProfileController.maxNameLength,
                decoration: InputDecoration(
                  labelText: 'Имя',
                  labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  floatingLabelStyle: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Palette.white100,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.isNameValid.value ? Palette.white100 : Palette.red400,
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                ),
              )),
              
              // Поле специализации
              Obx(() => TextFormField(
                controller: controller.shortDescriptionController,
                style: TextStyles.bodyMedium,
                maxLines: 2,
                maxLength: CreatingProfileController.maxShortDescriptionLength,
                decoration: InputDecoration(
                  labelText: 'Специализация (краткое описание)',
                  labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  floatingLabelStyle: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Palette.white100,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.isShortDescriptionValid.value ? Palette.white100 : Palette.red400,
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                  hintText: 'Например: Стилист по женской одежде.',
                  hintStyle: TextStyles.bodySmall.copyWith(color: Palette.grey350.withOpacity(0.7)),
                ),
              )),
              
              // Поле полного описания
              Obx(() => TextFormField(
                controller: controller.descriptionController,
                style: TextStyles.bodyMedium,
                maxLines: 4,
                maxLength: CreatingProfileController.maxDescriptionLength,
                decoration: InputDecoration(
                  labelText: 'Описание (полное)',
                  labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  floatingLabelStyle: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Palette.white100,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.isDescriptionValid.value ? Palette.white100 : Palette.red400,
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                  hintText: 'Расскажите подробнее о своем опыте, услугах и подходе к стилистике',
                  hintStyle: TextStyles.bodySmall.copyWith(color: Palette.grey350.withOpacity(0.7)),
                ),
              )),
              
              // Кнопка продолжить
              Obx(() => SizedBox(
                width: double.infinity,
                height: 35.h,
                child: ElevatedButton(
                  style: (controller.isFormValid && !controller.isLoading.value)
                      ? ButtonStyles.primary 
                      : ButtonStyles.secondary,
                  onPressed: (controller.isFormValid && !controller.isLoading.value)
                      ? controller.onContinuePressed 
                      : null,
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Palette.white100),
                          ),
                        )
                      : Text(
                          'Продолжить',
                          style: TextStyles.bodyMedium,
                        ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add,
          color: Palette.white100,
          size: 20.sp.adaptiveIcon,
        ),
        SizedBox(height: 5.h),
        Text(
          'Перетащите фото сюда или нажмите для загрузки',
          style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
          textAlign: TextAlign.center,
        ),
        Text(
          'JPG, PNG или GIF, максимум 5 МБ',
          style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildPhotoPreview(CreatingProfileController controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Center(
          child: kIsWeb
              ? FutureBuilder<Uint8List>(
                  future: controller.selectedImagePath.value.isNotEmpty 
                      ? controller.selectedImage?.readAsBytes() 
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Stack(
                        children: [
                          Image.memory(
                            snapshot.data!,
                            fit: BoxFit.contain,
                          ),
                          Positioned(
                            bottom: 4,
                            right: 4,
                            child: Image.asset(
                              'assets/icons/avatar_pick.png',
                              width: 16.sp.adaptiveIcon,
                              height: 16.sp.adaptiveIcon,
                            ),
                          ),
                        ],
                      );
                    }
                    return Container(
                      color: Palette.grey300,
                      child: Center(
                        child: Icon(
                          Icons.image,
                          color: Palette.white100,
                          size: 30.sp,
                        ),
                      ),
                    );
                  },
                )
              : Stack(
                  children: [
                    Image.file(
                      File(controller.selectedImagePath.value),
                      fit: BoxFit.contain,
                    ),
                    Positioned(
                      bottom: 4,
                      right: 4,
                      child: Image.asset(
                        'assets/icons/avatar_pick.png',
                        width: 16.sp.adaptiveIcon,
                        height: 16.sp.adaptiveIcon,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
} 