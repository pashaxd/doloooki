import 'package:doloooki/core/presentation/ondoarding/screens/bottom_navigation.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/controllers/%D1%81ontroller.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/screens/choosing_stylist_screen.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/screens/stylist_screen.dart';
import 'package:doloooki/mobile/features/subscription_feature/screens/add_card_screen.dart';
import 'package:doloooki/mobile/features/subscription_feature/wisgets/subscrip_card.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter_svg/svg.dart';

class AddingRequestScreen extends StatefulWidget {
  AddingRequestScreen({super.key});

  @override
  State<AddingRequestScreen> createState() => _AddingRequestScreenState();
}

class _AddingRequestScreenState extends State<AddingRequestScreen> {
  final TextEditingController requestController = TextEditingController();
  final FocusNode requestFocusNode = FocusNode();
  bool isFocused = false;

  @override
  void initState() {
    super.initState();
    requestFocusNode.addListener(() {
      setState(() {
        isFocused = requestFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    requestController.dispose();
    requestFocusNode.dispose();
    super.dispose();
  }

  void _showLooksCountBottomSheet() {
    final controller = Get.find<AddingRequestController>();
    Get.bottomSheet(
      Container(
        height: 320.sp,
        decoration: BoxDecoration(
          color: Palette.red600,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.sp),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 50.sp,
                  height: 5.sp,
                  decoration: BoxDecoration(
                    color: Palette.grey300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20.sp),
              Text('Количество необходимых образов', style: TextStyles.titleLarge),
              SizedBox(height: 20.sp),
              ...List.generate(5, (i) {
                final count = i + 1;
                return GestureDetector(
                  onTap: () {
                    controller.setLooksCount(count);
                    Get.back();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.sp),
                    child: Row(
                      children: [
                        Container(
                          width: 24.sp,
                          height: 24.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: controller.selectedLooksCount.value == count ? Palette.red100 : Palette.grey350,
                              width: 2,
                            ),
                            color: controller.selectedLooksCount.value == count ? Palette.red100 : Colors.transparent,
                          ),
                          child: controller.selectedLooksCount.value == count
                              ? Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: Palette.white100,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.sp),
                        Text(
                          '$count ${looksWord(count)}',
                          style: TextStyles.bodyLarge.copyWith(
                            color: Palette.white200,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  String looksWord(int count) {
    if (count % 10 == 1 && count % 100 != 11) return 'образ';
    if ([2, 3, 4].contains(count % 10) && !(count % 100 >= 12 && count % 100 <= 14)) return 'образа';
    return 'образов';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AddingRequestController());
    return Scaffold(
      backgroundColor: Palette.red600,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Palette.red600,
        title: Text(
          'Новая консультация',
          style: TextStyles.titleLarge.copyWith(color: Palette.white100)
        ),
        leading: Container(
          decoration: BoxDecoration(
            color: Palette.red400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: () {
              Get.back();
            },
            icon: Icon(Icons.arrow_back_ios_new, color: Palette.white100),
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Get.to(() => ChoosingStylistScreen());
                  if (result != null) {
                    controller.setStylistSelection(
                      type: result['type'],
                      stylist: result['stylist'],
                    );
                  }
                },
                child: Obx(() => Container(
                  height: controller.selectedStylist.value != null ? 80.sp : 60.sp,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                    child: controller.selectedStylist.value != null
                        ? Row(
                            children: [
                              // Фото стилиста
                              Container(
                                width: 50.sp,
                                height: 50.sp,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12.sp),
                               
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(30.sp),
                                  child: controller.selectedStylist.value!.image.isNotEmpty
                                      ? Image.network(
                                          controller.selectedStylist.value!.image,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) {
                                            return Container(
                                              color: Palette.red200,
                                              child: Icon(
                                                Icons.person,
                                                color: Palette.white100,
                                                size: 25.sp,
                                              ),
                                            );
                                          },
                                        )
                                      : Container(
                                          color: Palette.red200,
                                          child: Icon(
                                            Icons.person,
                                            color: Palette.white100,
                                            size: 25.sp,
                                          ),
                                        ),
                                ),
                              ),
                              SizedBox(width: 12.sp),
                              
                              // Информация о стилисте
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          controller.selectedStylist.value!.name,
                                          style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                        ),
                                        SizedBox(width: 8.sp),
                                        Text(
                                          '(${controller.selectedStylist.value!.shortDescription})',
                                          style: TextStyles.titleSmall.copyWith(color: Palette.grey350),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.sp),
                                    Row(
                                      children: [
                                        Text(
                                          controller.getAverageRating(controller.selectedStylist.value!).toStringAsFixed(1),
                                          style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                                        ),
                                        SizedBox(width: 4.sp),
                                        SvgPicture.asset(
                                          'assets/icons/stylist/star.svg',
                                          width: 16.sp,
                                          height: 16.sp,
                                          colorFilter: ColorFilter.mode(
                                            Palette.warning,
                                            BlendMode.srcIn,
                                          ),
                                        ),
                                        SizedBox(width: 8.sp),
                                        Text(
                                          'Отзывов: ${controller.selectedStylist.value!.reviews.length}',
                                          style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              
                              // Кнопка закрытия
                              GestureDetector(
                                onTap: () => controller.clearStylistSelection(),
                                child: Icon(
                                  Icons.close,
                                  color: Palette.white100,
                                  size: 20.sp,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Container(
                                height: 30.sp,
                                width: 30.sp,
                                decoration: BoxDecoration(
                                  color: Palette.red200,
                                  borderRadius: BorderRadius.circular(30.sp),
                                ),
                                child: Center(
                                  child: Icon(Icons.person, color: Palette.white100, size: 20.sp),
                                ),
                              ),
                              SizedBox(width: 10.sp),
                              Text(
                                'Выберите стилиста',
                                style: TextStyles.titleMedium.copyWith(color: Palette.grey350),
                              ),
                              Spacer(),
                              Icon(Icons.arrow_forward_ios, color: Palette.white100, size: 15.sp),
                            ],
                          ),
                  ),
                )),
              ),
              SizedBox(height: 20.sp,),
              Text('Фото в полный рост(1-3)',style : TextStyles.titleSmall.copyWith(color: Palette.white100)),
              Text('Загрузите для более точных рекомендаций', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
              SizedBox(height: 10.sp,),
              Wrap(
                spacing: 10.sp,
                children: List.generate(3, (index) => GestureDetector(
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
                                  Get.back();
                                  controller.pickFullBodyImageFromCamera(index);
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
                                            child: SvgPicture.asset(
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
                                  Get.back();
                                  controller.pickFullBodyImageFromGallery(index);
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
                                            child: SvgPicture.asset(
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
                            ],
                          ),
                        ],
                      ),
                    ),
                    isScrollControlled: true,
                  ),
                  child: Obx(() {
                    final preview = controller.fullBodyPreviews[index];
                    if (preview != null) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              preview,
                              width: 90.sp,
                              height: 120.sp,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.removeFullBodyImage(index),
                              child: Icon(Icons.close, color: Palette.white100, size: 20),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        width: 90.sp,
                        height: 120.sp,
                        decoration: BoxDecoration(
                          color: Palette.red400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(Icons.add, size: 40, color: Palette.white100),
                        ),
                      );
                    }
                  }),
                )),
              ),
              SizedBox(height: 20.sp,),
              Text('Портретные фото(1-3)',style : TextStyles.titleSmall.copyWith(color: Palette.white100)),
              Text('Чтобы определить подходящие оттенки', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
              SizedBox(height: 10.sp,),
              Wrap(
                spacing: 10.sp,
                children: List.generate(3, (index) => GestureDetector(
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
                                  Get.back();
                                  controller.pickPortraitImageFromCamera(index);
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
                                            child: SvgPicture.asset(
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
                                  Get.back();
                                  controller.pickPortraitImageFromGallery(index);
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
                                            child: SvgPicture.asset(
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
                            ],
                          ),
                        ],
                      ),
                    ),
                    isScrollControlled: true,
                  ),
                  child: Obx(() {
                    final preview = controller.portraitPreviews[index];
                    if (preview != null) {
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.memory(
                              preview,
                              width: 90.sp,
                              height: 120.sp,
                              fit: BoxFit.cover,
                            ),
                          ),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: GestureDetector(
                              onTap: () => controller.removePortraitImage(index),
                              child: Icon(Icons.close, color: Palette.white100, size: 20),
                            ),
                          ),
                        ],
                      );
                    } else {
                      return Container(
                        width: 90.sp,
                        height: 120.sp,
                        decoration: BoxDecoration(
                          color: Palette.red400,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(Icons.add, size: 40, color: Palette.white100),
                        ),
                      );
                    }
                  }),
                )),
              ),
              SizedBox(height: 20.sp,),
              Text('Описание запроса',style : TextStyles.titleSmall.copyWith(color: Palette.white100)),
              Text('Расскажите о мероприятии, желаемом образе и других пожеланиях', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
              SizedBox(height: 10.sp,),
              Text('Ваш запрос',style: TextStyles.titleSmall.copyWith(color: Palette.grey100)),
              SizedBox(height: 10.sp,),
               Obx(() => Container(
                height: 50.sp,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.isTitleFocused.value ? Palette.red200 : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: TextField(
                    onTapOutside: (event) {
                      controller.titleFocusNode.unfocus();
                    },
                    focusNode: controller.titleFocusNode,
                    maxLength: 30,
                    controller: controller.titleController,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    maxLines: 1,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey200),
                      hintText: 'Краткое описание запроса',
                      counterText: '',
                    ),
                  ),
                ),
              )),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(() => Text(
                    '${controller.title.value.length}/30',
                  style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
                )),
              ),
              Obx(() => Container(
                height: 100.sp,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: controller.isRequestFocused.value ? Palette.red200 : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10.sp),
                  child: TextField(
                    onTapOutside: (event) {
                      controller.requestFocusNode.unfocus();
                    },
                    focusNode: controller.requestFocusNode,
                    maxLength: 500,
                    controller: controller.requestController,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    maxLines: 4,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey200),
                      hintText: 'Например: Нужны образы для деловых встреч и офиса. Предпочитаю классический стиль, нейтральные цвета. Хочу выглядеть профессионально и элегантно.',
                      counterText: '',
                    ),
                  ),
                ),
              )),
              Align(
                alignment: Alignment.centerRight,
                child: Obx(() => Text(
                  '${controller.requestText.value.length}/500',
                  style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
                )),
              ),
              Text('Количество желаемых образов',style: TextStyles.labelMedium.copyWith(color: Palette.grey200)),
              SizedBox(height: 5.sp,),
              Obx(() => GestureDetector(
                onTap: _showLooksCountBottomSheet,
                child: Container(
                  height: 50.sp,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10.sp),
                    child: Row(
                      children: [
                        Text(
                          'Количество образов: ${controller.selectedLooksCount.value}',
                          style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                        ),
                        Spacer(),
                        Icon(Icons.arrow_drop_down, color: Palette.white100),
                      ],
                    ),
                  ),
                ),
              )),
              SizedBox(height: 20.sp,),
              Obx(() => GestureDetector(
                
                onTap: controller.isRequestReady.value ? () async {
                  Get.bottomSheet(
                    Container(
                    
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Palette.red600,
                      ),
                      child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Оплата консультации', style: TextStyles.titleLarge),
                              Container(
                                width: double.infinity,
                                height: 1,
                                decoration: BoxDecoration(
                                  color: Palette.red400,
                                ),
                              ),
                              SizedBox(height: 16.sp),
                              Container(
                                width: double.infinity,
                                height: 40.sp,
                                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                                decoration: BoxDecoration(
                                  color: Palette.red400,
                                  borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Консультация стилиста',style: TextStyles.titleMedium.copyWith(color: Palette.grey200),),
                                    Text('${controller.stylistConsultationPrice.value} ₽',style: TextStyles.titleMedium.copyWith(color: Palette.grey200),),
                                    ]
                                ),
                              ),
                              SizedBox(height: 2.sp),
                              Container(
                                width: double.infinity,
                                height: 40.sp,
                                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                                decoration: BoxDecoration(
                                  color: Palette.red400,
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('${controller.selectedLooksCount.value} образов',style: TextStyles.titleMedium.copyWith(color: Palette.grey200),),
                                    Text('${controller.selectedLooksCount.value * controller.onePatternPrice.value} ₽',style: TextStyles.titleMedium.copyWith(color: Palette.grey200),),
                                    ]
                                ),
                              ),
                               SizedBox(height: 2.sp),
                              Container(
                                width: double.infinity,
                                height: 40.sp,
                                padding: EdgeInsets.symmetric(horizontal: 16.sp),
                                decoration: BoxDecoration(
                                  color: Palette.red400,
                                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),bottomRight: Radius.circular(20)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Итого',style: TextStyles.titleMedium.copyWith(color: Palette.white100),),
                                    Text('${controller.stylistConsultationPrice.value + controller.selectedLooksCount.value * controller.onePatternPrice.value} ₽',style: TextStyles.titleMedium.copyWith(color: Palette.white100),),
                                    ]
                                ),
                              ),
                              SizedBox(height: 16.sp),
                              Obx(() => controller.hasSavedCards.value
                                  ? Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Palette.red200, width: 1),
                                        color: Palette.red600,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 4.sp),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('Карты', style: TextStyles.titleMedium),
                                                ElevatedButton(
                                                  style: ButtonStyles.primary,
                                                  onPressed: () {
                                                    controller.paymentService.getCardsCount().then((cardsCount) {
                                                      if (cardsCount >= 2) {
                                                        Get.snackbar(
                                                          'Ошибка',
                                                          'Достигнуто максимальное количество карт (2)',
                                                          snackPosition: SnackPosition.BOTTOM,
                                                          backgroundColor: Palette.red400,
                                                          colorText: Palette.white100,
                                                        );
                                                      } else {
                                                        Get.to(() => AddCardScreen());
                                                      }
                                                    });
                                                  },
                                                  child: Text('Добавить карту', style: TextStyles.buttonSmall),
                                                ),
                                              ],
                                            ),
                                            SizedBox(height: 8.sp),
                                            ListView.builder(
                                              shrinkWrap: true,
                                              physics: const NeverScrollableScrollPhysics(),
                                              itemCount: controller.userCards.length,
                                              itemBuilder: (context, index) {
                                                final card = controller.userCards[index];
                                                final isExpired = controller.isCardExpired(card);
                                                return Obx(() => GestureDetector(
                                                  onTap: isExpired ? null : () => controller.selectCard(card),
                                                  child: Padding(
                                                    padding: EdgeInsets.all(4.sp),
                                                    child: Container(
                                                      decoration: BoxDecoration(
                                                        color: Palette.red400,
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: ListTile(
                                                        contentPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                                                        leading: Radio<String>(
                                                          value: card.id,
                                                          groupValue: controller.selectedCard.value?.id,
                                                          onChanged: isExpired
                                                              ? null
                                                              : (value) {
                                                                  if (value != null) {
                                                                    controller.selectCard(card);
                                                                  }
                                                                },
                                                          activeColor: Palette.white100,
                                                          fillColor: MaterialStateProperty.all(Palette.white100),
                                                        ),
                                                        title: Row(
                                                          children: [
                                                            Image.asset('assets/icons/supcription/card.png', width: 30, height: 30),
                                                            SizedBox(width: 8.sp),
                                                            Text(
                                                              '•••• ${card.lastFourDigits}',
                                                              style: TextStyles.titleMedium,
                                                            ),
                                                            Spacer(),
                                                            IconButton(
                                                              icon: Icon(Icons.close, color: Palette.grey350, size: 20),
                                                              onPressed: () => showDialog(
                                                                context: context,
                                                                builder: (context) => AlertDialog(
                                                                  backgroundColor: Palette.red400,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(20),
                                                                  ),
                                                                  title: Text(
                                                                    'Удаление карты',
                                                                    style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                                                                    textAlign: TextAlign.center,
                                                                  ),
                                                                  content: Text(
                                                                    'После удаления карты вам потребуется добавить её заново для совершения платежей. Вы уверены, что хотите продолжить?',
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
                                                                          decoration: BoxDecoration(
                                                                            color: Palette.black300,
                                                                          ),
                                                                        ),
                                                                        TextButton(
                                                                          onPressed: () {
                                                                            Navigator.of(context).pop();
                                                                            controller.deleteCard(card.id);
                                                                          },
                                                                          child: Text('Удалить', style: TextStyles.buttonSmall.copyWith(color: Palette.error),textAlign: TextAlign.center,),
                                                                        ),
                                                                        SizedBox(height: 2.sp),
                                                                        Container(
                                                                          width: double.infinity,
                                                                          height: 1,
                                                                          decoration: BoxDecoration(
                                                                            color: Palette.black300,
                                                                          ),
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
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ));
                                              },
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: Palette.red200, width: 1),
                                        color: Palette.red600,
                                      ),
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 16.sp),
                                        child: Column(
                                          children: [
                                            Text('Добавьте карту', style: TextStyles.titleMedium),
                                            Text(
                                              'Для оплаты подписки необходимо добавить хотя бы одну банковскую карту. Вы сможете выбрать нужную карту при оплате.',
                                              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                              textAlign: TextAlign.center,
                                            ),
                                            SizedBox(height: 8.sp),
                                            ElevatedButton(
                                              style: ButtonStyles.primary,
                                              onPressed: () {
                                                controller.paymentService.getCardsCount().then((cardsCount) {
                                                  if (cardsCount >= 2) {
                                                    Get.snackbar(
                                                      'Ошибка',
                                                      'Достигнуто максимальное количество карт (2)',
                                                      snackPosition: SnackPosition.BOTTOM,
                                                      backgroundColor: Palette.red400,
                                                      colorText: Palette.white100,
                                                    );
                                                  } else {
                                                    Get.to(() => AddCardScreen());
                                                  }
                                                });
                                              },
                                              child: Text('Добавить карту', style: TextStyles.buttonSmall),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                              ),
                              SizedBox(height: 16.sp),
                              Obx(() => GestureDetector(
                                onTap: controller.hasSavedCards.value && 
                                       controller.selectedCard.value != null && 
                                       !controller.isCardExpired(controller.selectedCard.value!) ? () async {
                                  Get.back();
                                  // Показываем загрузку
                                  Get.dialog(
                                    Center(child: CircularProgressIndicator()),
                                    barrierDismissible: false,
                                  );
                                  await controller.pay();
                                  // Скрываем загрузку
                                  Get.back();
                                    Get.to(()=>BottomNavigation());
                                } : null,
                                child: Container(
                                  height: 50.sp,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: (controller.hasSavedCards.value && 
                                           controller.selectedCard.value != null && 
                                           !controller.isCardExpired(controller.selectedCard.value!)) 
                                        ? Palette.red100 
                                        : Palette.red400,
                                    borderRadius: BorderRadius.circular(20.sp),
                                  ),
                                  child: Center(
                                    child: Text(
                                      'Оплатить',
                                      style: TextStyles.buttonMedium.copyWith(color: Palette.white100),
                                    ),
                                  ),
                                ),
                              )),
                            ],
                          ),
                        ),
                      
                    ),
                    isScrollControlled: true,
                  );
                } : null,
                child: Container(
                  height: 50.sp,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: controller.isRequestReady.value ? Palette.red100 : Palette.red400,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Center(
                    child: Text(
                      'Перейти к оплате',
                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}