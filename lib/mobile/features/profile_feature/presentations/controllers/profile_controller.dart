import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/core/presentation/ondoarding/screens/onboarding_screen.dart';
import 'package:doloooki/mobile/features/profile_feature/data/models/notification_model.dart';
import 'package:doloooki/mobile/features/profile_feature/presentations/controllers/notifications_controller.dart';
import 'package:doloooki/mobile/features/subscription_feature/services/payment_service.dart';
import 'package:doloooki/mobile/features/subscription_feature/wisgets/subscrip_card.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/snackbar_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/profile_feature/data/services/profile_service.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/subscription_feature/controllers/subscription_controller.dart';
import 'package:doloooki/mobile/features/subscription_feature/screens/add_card_screen.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doloooki/core/presentation/ondoarding/screens/onboarding_screen.dart';
  
class ProfileController extends GetxController {
  final ProfileService _service = ProfileService();
  final SubscriptionController subscriptionController = Get.put(SubscriptionController());
  final NotificationsController notificationController = Get.put(NotificationsController());
  RxString name = ''.obs;
  RxString surname = ''.obs;
  RxString secondName = ''.obs;
  RxString phone = ''.obs;
  RxString photoUrl = ''.obs;
  RxBool isPremium = false.obs;
  Rx<File?> profileImage = Rx<File?>(null);
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode surnameFocusNode = FocusNode();
  final FocusNode secondNameFocusNode = FocusNode();

  final RxBool isNameFocused = false.obs;
  final RxBool isSurnameFocused = false.obs;
  final RxBool isSecondNameFocused = false.obs;

  Rx<DateTime?> premiumStart = Rx<DateTime?>(null);
  Rx<DateTime?> premiumEnd = Rx<DateTime?>(null);

  void setFocus(String field) {
    isNameFocused.value = field == 'name';
    isSurnameFocused.value = field == 'surname';
    isSecondNameFocused.value = field == 'secondName';
  }

  @override
  void onInit() {
    super.onInit();
    nameFocusNode.addListener(() {
      isNameFocused.value = nameFocusNode.hasFocus;
    });
    surnameFocusNode.addListener(() {
      isSurnameFocused.value = surnameFocusNode.hasFocus;
    });
    secondNameFocusNode.addListener(() {
      isSecondNameFocused.value = secondNameFocusNode.hasFocus;
    });
    fetchProfile();
  }

  @override
  void onClose() {
    nameFocusNode.dispose();
    surnameFocusNode.dispose();
    secondNameFocusNode.dispose();
    super.onClose();
  }

  Future<void> fetchProfile() async {
    final data = await _service.fetchProfile();
    if (data != null) {
      name.value = data['name'] ?? '';
      surname.value = data['surname'] ?? '';
      secondName.value = data['secondName'] ?? '';
      phone.value = data['phone'] ?? '';
      photoUrl.value = data['profileImage'] ?? '';
      isPremium.value = data['isPremium'] ?? false;
      premiumStart.value = data['premiumStart'] != null
          ? (data['premiumStart'] as Timestamp).toDate()
          : null;
      premiumEnd.value = data['premiumEnd'] != null
          ? (data['premiumEnd'] as Timestamp).toDate()
          : null;
    }
  }

  Future<void> logout() async {
    await _service.logout();
  }

  void showSubscriptionSheet() {
    Get.bottomSheet(
      Container(
        width: double.infinity,
        color: Palette.red600,
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Оплата', style: TextStyles.titleLarge),
                Container(
                  width: double.infinity,
                  height: 1,
                  color: Palette.red400,
                ),
                Text('Тариф', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
                SizedBox(height: 16.sp),
                const SubscriptionCard(),
                SizedBox(height: 16.sp),
                Obx(() => subscriptionController.hasSavedCards.value
                    ? Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Palette.red200, width: 1),
                          color: Palette.red600,
                        ),
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
                                    subscriptionController.paymentService.getCardsCount().then((cardsCount) {
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
                              itemCount: subscriptionController.userCards.length,
                              itemBuilder: (context, index) {
                                final card = subscriptionController.userCards[index];
                                final isExpired = subscriptionController.isCardExpired(card);
                                return Obx(() => GestureDetector(
                                      onTap: isExpired ? null : () => subscriptionController.selectCard(card),
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
                                              groupValue: subscriptionController.selectedCard.value?.id,
                                              onChanged: isExpired
                                                  ? null
                                                  : (value) {
                                                      if (value != null) {
                                                        subscriptionController.selectCard(card);
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
                                                              color: Palette.black300,
                                                            ),
                                                            TextButton(
                                                              onPressed: () {
                                                                Navigator.of(context).pop();
                                                                subscriptionController.deleteCard(card.id);
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
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 16.sp),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Palette.red200, width: 1),
                          color: Palette.red600,
                        ),
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
                                subscriptionController.paymentService.getCardsCount().then((cardsCount) {
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
                SizedBox(height: 4.sp),
                Obx(() => SizedBox(
                  width: double.infinity,
                  height: 45.sp,
                  child: ElevatedButton(
                    style: subscriptionController.selectedCard.value != null
                        ? ButtonStyles.primary
                        : ButtonStyles.secondary,
                    onPressed: subscriptionController.selectedCard.value != null
                        ? () {
                             final user = FirebaseAuth.instance.currentUser;
                                                  if (user != null) {
                                                     FirebaseFirestore.instance.collection('users').doc(user.uid).update({
                                                      'isPremium': true,
                                                      'premiumStart': FieldValue.serverTimestamp(),
                                                      'premiumEnd': Timestamp.fromDate(DateTime.now().add(Duration(days: 30))),
                                                    });
                                                  }
                                                  // 2. Добавляем уведомление
                                                  notificationController.addNotification(NotificationModel(
                                                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                                                    title: 'Подписка продлена', description: 'Ваша подписка продлена', createdAt: DateTime.now(), type: 'success'),
                                                  );
                            Get.snackbar(
                              'Успех',
                              'Оплата прошла успешно',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Palette.red400,
                              colorText: Palette.white100,
                            );
                            // Здесь можно обновить статус isPremium.value = true;
                          }
                        : null,
                    child: Text(
                      'Оплатить',
                      style: TextStyles.buttonSmall.copyWith(
                        color: subscriptionController.selectedCard.value != null ? Palette.white100 : Palette.grey350,
                      ),
                    ),
                  ),
                )),
                SizedBox(height: 8.sp),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Future<void> updateProfile({
    required String name,
    required String surname,
    required String secondName,
  }) async {
    await _service.updateProfile({
      'name': name,
      'surname': surname,
      'secondName': secondName,
    });
    this.name.value = name;
    this.surname.value = surname;
    this.secondName.value = secondName;
      SnackbarUtils.showSuccess('Изменения сохранены');  }

  Future<void> pickImage() async {
    final file = await _service.pickImageFromGallery();
    if (file != null) {
      profileImage.value = file;
      final fileSize = await file.length();
      print('Размер файла: \\${(fileSize / 1024).toStringAsFixed(2)} KB');
    }
  }

  Future<void> pickImageFromCamera() async {
    final file = await _service.pickImageFromCamera();
    if (file != null) {
      profileImage.value = file;
      final fileSize = await file.length();
      print('Размер файла: \\${(fileSize / 1024).toStringAsFixed(2)} KB');
    }
  }

  Future<String?> uploadImage() async {
    if (profileImage.value == null) return null;
    final hasInternet = await _service.checkInternetConnection();
    if (!hasInternet) {
      Get.snackbar('Ошибка', 'Нет подключения к интернету', snackPosition: SnackPosition.BOTTOM);
      return null;
    }
    return await _service.uploadImage(profileImage.value!);
  }

  Future<void> changeAvatar({bool fromCamera = false}) async {
    if (fromCamera) {
      await pickImageFromCamera();
    } else {
      await pickImage();
    }
    if (profileImage.value != null) {
      final url = await uploadImage();
      if (url != null) {
        await _service.updateProfile({'profileImage': url});
        photoUrl.value = url;
        SnackbarUtils.showSuccess('Аватар обновлён');
      }
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Показываем индикатор загрузки
      Get.dialog(
        Center(
          child: CircularProgressIndicator(color: Palette.white100),
        ),
        barrierDismissible: false,
      );
      
      await _service.deleteAccount();
      
      // Очищаем все данные контроллера
      name.value = '';
      surname.value = '';
      secondName.value = '';
      phone.value = '';
      photoUrl.value = '';
      isPremium.value = false;
      premiumStart.value = null;
      premiumEnd.value = null;
      profileImage.value = null;
      
      // Закрываем диалог загрузки
      Get.back();
      
      // Показываем сообщение об успешном удалении
      Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 350.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/green.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Аккаунт удалён',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Ваш аккаунт и все связанные с ним данные были удалены',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back(); // Закрываем диалог
                      // Добавляем небольшую задержку перед навигацией
                      Future.delayed(Duration(milliseconds: 500), () {
                        // Перенаправляем на экран авторизации
                        Get.offAll(() => OnboardingScreen());
                      });
                    },
                    style: ButtonStyles.primary,
                    child: Text(
                      'Понятно',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
    } catch (e) {
      // Закрываем диалог загрузки если он открыт
      try {
        Get.back();
      } catch (_) {}
      
      print('Ошибка при удалении аккаунта: $e');
      
      // Показываем ошибку
      Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 350.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/red.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Ошибка',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Не удалось удалить аккаунт. Проверьте подключение к интернету и попробуйте снова',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ButtonStyles.primary,
                    child: Text(
                      'Понятно',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
