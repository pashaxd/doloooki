import 'package:doloooki/mobile/features/profile_feature/presentations/controllers/profile_controller.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  late final ProfileController controller;
  late final TextEditingController nameController;
  late final TextEditingController surnameController;
  late final TextEditingController secondNameController;
  late final TextEditingController phoneController;
  late final ValueNotifier<bool> isChanged;

  @override
  void initState() {
    super.initState();
    controller = Get.find<ProfileController>();
    nameController = TextEditingController(text: controller.name.value);
    surnameController = TextEditingController(text: controller.surname.value);
    secondNameController = TextEditingController(text: controller.secondName.value);
    phoneController = TextEditingController(text: controller.phone.value);
    isChanged = ValueNotifier(false);
    nameController.addListener(_onFieldChanged);
    surnameController.addListener(_onFieldChanged);
    secondNameController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    isChanged.value =
      nameController.text.trim() != controller.name.value.trim() ||
      surnameController.text.trim() != controller.surname.value.trim() ||
      secondNameController.text.trim() != controller.secondName.value.trim();
  }

  @override
  void dispose() {
    nameController.dispose();
    surnameController.dispose();
    secondNameController.dispose();
    phoneController.dispose();
    isChanged.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    await controller.updateProfile(
      name: nameController.text.trim(),
      surname: surnameController.text.trim(),
      secondName: secondNameController.text.trim(),
    );
    isChanged.value = false;
  }

  Future<bool> _showUnsavedChangesDialog() async {
    if (!isChanged.value) {
      return true;
    }
    
    final result = await Get.dialog<bool>(
      AlertDialog(
        contentPadding: EdgeInsets.all(4.sp),
        backgroundColor: Palette.red400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Несохраненные изменения',
          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Вы внесли изменения, но не сохранили их. Если выйти сейчас, изменения будут потеряны.',
          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            children: [
              SizedBox(height: 6.sp),
              Container(
                width: double.infinity,
                height: 1,
                color: Palette.black300,
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(
                  'Выйти',
                  style: TextStyles.buttonMedium.copyWith(color: Palette.error),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 2.sp),
              Container(
                width: double.infinity,
                height: 1,
                color: Palette.black300,
              ),
              SizedBox(height: 2.sp),
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Отмена',
                  style: TextStyles.buttonMedium.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (isChanged.value) {
              return await _showUnsavedChangesDialog();
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Palette.red600,
            appBar: AppBar(
              backgroundColor: Palette.red600,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios, color: Palette.white100),
                onPressed: () async {
                  if (isChanged.value) {
                    final shouldExit = await _showUnsavedChangesDialog();
                    if (shouldExit) {
                      Get.back();
                    }
                  } else {
                    Get.back();
                  }
                },
              ),
              centerTitle: true,
              title: Text('Личные данные', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
            ),
            body: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 12.sp),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(() => GestureDetector(
                        onTap: () {
                         Get.bottomSheet(
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
                                        onTap: () async {
                                          await controller.changeAvatar(fromCamera: true);
                                          Get.back();
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
                                        onTap: () async {
                                          await controller.changeAvatar(fromCamera: false);
                                          Get.back();
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
                            ),);
                          
                          },
                        child: CircleAvatar(
                          backgroundColor: Palette.red400,
                          radius: 48.sp,
                          backgroundImage: controller.photoUrl.value.isNotEmpty
                              ? NetworkImage(controller.photoUrl.value)
                              : null,
                          child: controller.photoUrl.value.isEmpty
                              ? Icon(Icons.person, color: Palette.white100, size: 48.sp)
                              : null,
                        ),
                      )),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: реализовать выбор новой фотографии
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Palette.red100,
                              shape: BoxShape.circle,
                            ),
                            padding: EdgeInsets.all(6.sp),
                            child: Icon(Icons.edit, color: Palette.white100, size: 18.sp),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.sp),
 Column(
                              spacing: 5.sp,

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Имя', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                                Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: controller.isNameFocused.value
                                        ? Border.all(color: Palette.white200)
                                        : Border.all(width: 0),
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    controller: nameController,
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
                            ),                SizedBox(height: 12.sp),
 Column(
                              spacing: 5.sp,

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Фамилия', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                                Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: controller.isSurnameFocused.value
                                        ? Border.all(color: Palette.white200)
                                        : Border.all(width: 0),
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    controller: surnameController,
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
                            ),                SizedBox(height: 12.sp),
                Column(
                              spacing: 5.sp,

                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Отчество', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                                Obx(() => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                                  decoration: BoxDecoration(
                                    border: controller.isSecondNameFocused.value
                                        ? Border.all(color: Palette.white200)
                                        : Border.all(width: 0),
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: TextField(
                                    controller: secondNameController,
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
                SizedBox(height: 12.sp),
                _ProfileField(
                  label: 'Телефон',
                  controller: phoneController,
                  enabled: false,
                  hint: 'Номер телефона изменить нельзя',
                  profileController: controller,
                ),
                SizedBox(height: 8.sp),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Номер телефона изменить нельзя',
                    style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                  ),
                ),
                Spacer(),
                SizedBox(
                  height: 40.sp,
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Palette.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.sp)),
                    ),
                    onPressed: () {
                      showDialog(
                                                                      context: context,
                                                                      builder: (context) => AlertDialog(
                                                                        backgroundColor: Palette.red400,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20),
                                                                        ),
                                                                        title: Text(
                                                                          'Удалить аккаунт?',
                                                                          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
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
                                                                                  controller.deleteAccount();
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
                    },
                    icon: Icon(Icons.delete, color: Palette.error),
                    label: Text('Удалить аккаунт', style: TextStyles.buttonMedium.copyWith(color: Palette.error)),
                  ),
                ),
                SizedBox(height: 12.sp),
                ValueListenableBuilder<bool>(
                  valueListenable: isChanged,
                  builder: (context, changed, child) {
                    return SizedBox(
                      height: 40.sp,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: changed ? _saveProfile : null,
                        style: changed ? ButtonStyles.primary : ButtonStyles.secondary,
                        child: Text('Сохранить', style: TextStyles.buttonMedium.copyWith(color: changed ? Palette.white100 : Palette.grey350)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        )));
  }
}

class _ProfileField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool enabled;
  final String? hint;
  final ProfileController profileController;

  const _ProfileField({
    required this.label,
    required this.controller,
    required this.profileController,
    this.enabled = true,
    this.hint,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
        SizedBox(height: 4.sp),
        Obx(() => Container(
          decoration: BoxDecoration(
            border: (profileController.isNameFocused.value && label == 'Имя') ||
                    (profileController.isSurnameFocused.value && label == 'Фамилия') ||
                    (profileController.isSecondNameFocused.value && label == 'Отчество')
                ? Border.all(color: Palette.white200, width: 1)
                : Border.all(color: Colors.transparent, width: 1),
            borderRadius: BorderRadius.circular(16.sp),
          ),
          child: TextField(
            onTap: () {
              profileController.setFocus(label.toLowerCase());
            },
            onTapOutside: (_) {
              profileController.setFocus('');
            },
            controller: controller,
            enabled: enabled,
            style: TextStyles.bodyLarge.copyWith(color: Palette.white200),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
              filled: true,
              fillColor: Palette.red400,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.sp),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
            ),
          ),
        )),
      ],
    );
  }
}