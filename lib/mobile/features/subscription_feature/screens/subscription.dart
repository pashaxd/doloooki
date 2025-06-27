import 'package:doloooki/core/presentation/ondoarding/screens/bottom_navigation.dart';
 
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/usloviya.dart';
import 'package:doloooki/mobile/features/profile_feature/data/models/notification_model.dart';
import 'package:doloooki/mobile/features/profile_feature/presentations/controllers/notifications_controller.dart';
import 'package:doloooki/mobile/features/subscription_feature/controllers/subscription_controller.dart';
import 'package:doloooki/mobile/features/subscription_feature/screens/add_card_screen.dart';
import 'package:doloooki/mobile/features/subscription_feature/wisgets/subscrip_card.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SubscriptionScreen extends StatelessWidget {
  SubscriptionScreen({super.key});

  final SubscriptionController controller = Get.put(SubscriptionController());
  final NotificationsController notificationController = Get.put(NotificationsController());
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          body: Padding(
            padding:  EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: Consts.screenWidth(context) * 0.75,
                      child: Text(
                        'Раскройте потенциал вашего гардероба',
                        style: TextStyles.headlineSmall,
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.close, color: Palette.white100, size: 20.sp),
                    )
                  ],
                ),
                 SizedBox(height: 8.sp),
                Text(
                  'Создавайте стильные образы, \nполучайте рекомендации и консультации профессиональных стилистов',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                ),
                 SizedBox(height: 16.sp),
                const SubscriptionCard(),
                SizedBox(height: 16.sp),
                    Text('У вас есть 7 дней бесплатного пробного периода', style: TextStyles.titleSmall),
                    Wrap(
                          
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            Text(
                              'Оформляя подписку, вы соглашаетесь с ',
                              style: TextStyles.labelMedium.copyWith(color: Palette.grey350),
                            ),

                            GestureDetector(
                              onTap: () {
                                Get.to(Usloviya());
                              },
                              child: Text(
                                'Условиями ',
                                style: TextStyles.labelMedium.copyWith(
                                  color: Palette.red100,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {  Get.to(Usloviya());},
                                  child: Text(
                                    'использования ',
                                    style: TextStyles.labelMedium.copyWith(color: Palette.red100),
                                  ),
                                ),
                            Text(
                              'и ',
                              style: TextStyles.labelMedium.copyWith(color: Palette.grey200),
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.to(Usloviya());                              },
                              child: Text(
                                'Политикой конфиденциальности',
                                style: TextStyles.labelMedium.copyWith(color: Palette.red100),
                              ),
                            ),
                          ],
                        ),
                                                    Text('Подписка автоматически продлевается, если её не отменить до окончания текущего периода.', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),


                          ],
                        ),
                const Spacer(),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: Consts.screenHeight(context) * 0.055,
                      child: ElevatedButton(
                        style: ButtonStyles.primary,
                        onPressed: () {
                          Get.bottomSheet(
                            Container(
                              width: double.infinity,
                             
                              color: Palette.red600,
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding:  EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
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
                                      Obx(() => controller.hasSavedCards.value
                                          ? Container(
                                              padding:  EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
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
                                                      return Obx(() =>  GestureDetector(
                                                        onTap: isExpired ? null : () => controller.selectCard(card),
                                                        child: Padding(
                                                          padding:  EdgeInsets.all(4.sp),
                                                          child: Container(
                                                            
                                                            decoration: BoxDecoration(
                                                              color: Palette.red400,
                                                              borderRadius: BorderRadius.circular(16),
                                                            ),
                                                            child: ListTile(
                                                              contentPadding:  EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
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
                                                                                color: Palette.black300,
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
                                              padding:  EdgeInsets.symmetric(horizontal: 8.sp, vertical: 16.sp),
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
                                  
                                      SizedBox(height: 4.sp),
                                      Obx(() => SizedBox(
                                        width: double.infinity,
                                        height: 45.sp,
                                        child: ElevatedButton(
                                          style: controller.selectedCard.value != null
                                              ? ButtonStyles.primary
                                              : ButtonStyles.secondary,
                                          onPressed: controller.selectedCard.value != null
                                              ? () async {
                                                  // 1. Сохраняем статус подписки в Firestore
                                                  final user = FirebaseAuth.instance.currentUser;
                                                  if (user != null) {
                                                    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
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
                                                  Get.offAll(() => BottomNavigation());
                                                  Get.dialog(
                                                    Center(
                                                      child: Material(
                                                        type: MaterialType.transparency,
                                                        child: Container(
                                                          constraints: BoxConstraints(
                                                            maxWidth: 350.sp,
                                                            minWidth: 350.sp,
                                                          ),
                                                          margin: EdgeInsets.symmetric(horizontal: 20.sp),
                                                          padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                                                          decoration: BoxDecoration(
                                                            color: Palette.red400,
                                                            borderRadius: BorderRadius.circular(20),
                                                          ),
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
                                                                'Поздравляем!',
                                                                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              SizedBox(height: 2.sp),
                                                              Text(
                                                                'Подписка оформлена',
                                                                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                                                                textAlign: TextAlign.center,
                                                              ),
                                                              SizedBox(height: 8.sp),
                                                              Text(
                                                                'Вы успешно оплатили подписку. Теперь вам доступны все функции приложения.',
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
                                                                    'Продолжить',
                                                                    style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    barrierDismissible: false,
                                                  );
                                                }
                                              : null,
                                          child: Text(
                                            'Оплатить',
                                            style: TextStyles.buttonSmall.copyWith(
                                              color: controller.selectedCard.value != null ? Palette.white100 : Palette.grey350,
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
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/supcription/star.png', width: 20, height: 20),
                            const SizedBox(width: 5),
                            Text('Продолжить', style: TextStyles.buttonSmall),
                          ],
                        ),
                      ),
                    ),
                      SizedBox(height: 8.sp),
                    SizedBox(
                      width: double.infinity,
                      height: 45.sp,
                      child: ElevatedButton(
                        style: ButtonStyles.outlined,
                        onPressed: () {

                          Get.offAll(() => BottomNavigation());
                        },
                        child: Text('Начать бесплатно', style: TextStyles.buttonSmall),
                      ),
                    ),
                
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}