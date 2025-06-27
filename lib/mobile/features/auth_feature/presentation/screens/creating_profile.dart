import 'package:doloooki/mobile/features/auth_feature/presentation/controllers/profile_controller.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_fields.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CreatingProfileScreen extends StatelessWidget {
  CreatingProfileScreen({super.key});

  final CreatingProfileController controller = Get.put(CreatingProfileController());

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Palette.red600,
            title: Text('Создай свой профиль', style: TextStyles.titleLarge),
            centerTitle: true,
            leading: Container(
              width: 20.sp,
              height: 20.sp,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Palette.red400,
              ),
              child: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back_ios_new_rounded),color: Palette.white100,),
            ),
          ),
          backgroundColor: Palette.red600,
          body: Column(

            children: [
              SizedBox(height: 10.sp),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Padding(
                        padding:  EdgeInsets.all(10.sp),
                        child: Text(
                          'Создавайте гардероб — добавляйте вещи и комбинируйте их в идеальные образы.',
                          style: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10.sp),
                      GestureDetector(
                        onTap: () => Get.bottomSheet(
                          Container(
                            height: 200.sp,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Palette.red600,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                SizedBox(height: 10.sp),
                                Container(
                                  width: 50.sp,
                                  height: 5.sp,
                                  decoration: BoxDecoration(
                                    color: Palette.grey300,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                SizedBox(height: 20.sp),
                                Text('Загрузка фотографии', style: TextStyles.titleLarge),
      SizedBox(height: 20.sp),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [

                                    GestureDetector(
                                      onTap: () {
                                         controller.pickImageFromCamera();
                                       
                                      },
                                      child: Container(
                                        width: 150.sp,
                                        height: 100.sp,
                                        decoration: BoxDecoration(
                                          color: Palette.red400,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Palette.red100,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: 
                                                      SvgPicture.asset(
                                                        'assets/icons/profile/camera.svg',
                                                        width: 20.sp,
                                                        height: 20.sp,
                                                         colorFilter: ColorFilter.mode(Palette.white100, BlendMode.srcIn),
                                                      ),
                                                      
                                                   
                                                ),
                                              ),
                                              SizedBox(height: 5.sp),
                                              Text('Камера', style: TextStyles.labelMedium),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        controller.pickImage();
                                      },
                                      child: Container(
                                        width: 150.sp,
                                        height: 100.sp,
                                        decoration: BoxDecoration(
                                          color: Palette.red400,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Center(
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 60,
                                                height: 60,
                                                decoration: BoxDecoration(
                                                  color: Palette.red100,
                                                  borderRadius: BorderRadius.circular(20),
                                                ),
                                                child: Center(
                                                  child: 
                                                      SvgPicture.asset(
                                                        'assets/icons/profile/galery.svg',
                                                        width: 20.sp,
                                                        height: 20.sp,
                                                        colorFilter: ColorFilter.mode(Palette.white100, BlendMode.srcIn),
                                                      ),
                                                      
                                                    
                                                ),
                                              ),
                                              SizedBox(height: 5.sp),
                                              Text('Галерея', style: TextStyles.labelMedium),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                ],)
                              ],
                            ),
                          ),
                        ),
                        child: Stack(
                          alignment: Alignment.bottomRight,
                          children: [
                            Obx(() => CircleAvatar(
                              backgroundColor: Palette.red400,
                              radius: 40.sp,
                              child: controller.profileImage.value != null
                                  ? ClipOval(
                                      child: Image.file(
                                        controller.profileImage.value!,
                                        width: Consts.screenWidth(context) * 0.2,
                                        height: Consts.screenWidth(context) * 0.2,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Image.asset(
                                      'assets/icons/profile.png',
                                      width: Consts.screenWidth(context) * 0.12,
                                    ),
                            )),
                            Container(
                              padding: const EdgeInsets.all(4),
                              child: Image.asset(
                                'assets/icons/avatar_pick.png',
                                width: Consts.screenWidth(context) * 0.05,
                                height: Consts.screenWidth(context) * 0.05,
                              ),
                            ),
                          ],
                        ),
                      ),
                       SizedBox(height: 20.sp),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          children: [
                            Column(
                              spacing: 5.sp,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Имя', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                                Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: controller.isNameFocused.value || controller.nameController.text.isNotEmpty 
                                        ? Border.all(color: Palette.white200)
                                        : Border.all(width: 0),
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    controller: controller.nameController,
                                    onTap: () => controller.setFocus('name'),
                                    onTapOutside: (_) => controller.setFocus(''),
                                    style: TextStyles.bodyLarge.copyWith(
                                      color: Palette.white200,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Имя',
                                      hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                      counterText: '',
                                    ),
                                  ),
                                )),
                              ],
                            ),
                             SizedBox(height: 16.sp),
                            Column(
                              spacing: 5.sp,

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Фамилия', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                                Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: controller.isSurnameFocused.value || controller.surnameController.text.isNotEmpty 
                                        ? Border.all(color: Palette.white200)
                                        : Border.all(width: 0),
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    controller: controller.surnameController,
                                    onTap: () => controller.setFocus('surname'),
                                    onTapOutside: (_) => controller.setFocus(''),
                                    style: TextStyles.bodyLarge.copyWith(
                                      color: Palette.white200,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Фамилия',
                                      hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                      counterText: '',
                                    ),
                                  ),
                                )),
                              ],
                            ),
                             SizedBox(height: 16.sp),
                            Column(
                              spacing: 5.sp,

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Отчество', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                                Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  decoration: BoxDecoration(
                                    border: controller.isSecondNameFocused.value || controller.secondNameController.text.isNotEmpty 
                                        ? Border.all(color: Palette.white200)
                                        : Border.all(width: 0),
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    controller: controller.secondNameController,
                                    onTap: () => controller.setFocus('secondName'),
                                    onTapOutside: (_) => controller.setFocus(''),
                                    style: TextStyles.bodyLarge.copyWith(
                                      color: Palette.white200,
                                    ),
                                    decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: 'Отчество',
                                      hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                      counterText: '',
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Obx(() => ElevatedButton(
                    onPressed: controller.isButtonEnabled.value && !controller.isLoading.value
                        ? () => controller.saveProfile()
                        : null,
                    style: controller.isButtonEnabled.value ? ButtonStyles.primary : ButtonStyles.secondary,
                    child: controller.isLoading.value
                        ? const CircularProgressIndicator()
                        : Text(
                            'Создать',
                            style: TextStyles.buttonMedium.copyWith(
                              color: controller.isButtonEnabled.value ? Palette.white100 : Palette.grey350,
                            ),
                          ),
                  )),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}