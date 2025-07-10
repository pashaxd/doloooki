import 'package:doloooki/mobile/features/auth_feature/presentation/screens/usloviya.dart';
import 'package:doloooki/mobile/features/profile_feature/presentations/controllers/profile_controller.dart';
import 'package:doloooki/mobile/features/profile_feature/presentations/screens/info_screen.dart';
import 'package:doloooki/mobile/features/profile_feature/presentations/screens/notifications_screen.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ProfileController());

    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          body: Obx(() => Column(
            spacing: 8.sp,
            children: [
              
              controller.photoUrl.value.isNotEmpty
                  ? CircleAvatar(
                      radius: 40.sp,
                      backgroundImage: NetworkImage(controller.photoUrl.value),
                      backgroundColor: Palette.red400,
                    )
                  : CircleAvatar(
                      radius: 40.sp,
                      backgroundColor: Palette.red400,
                      child: Icon(Icons.person, color: Palette.white100, size: 50.sp),
                    ),
            
              Text(controller.name.value, style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
              SizedBox(height: 4.sp),
              // Блок премиума
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.sp),
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    
                    Text(controller.isPremium.value ? 'Премиум активен' : 'Перейдите на Премиум', style: TextStyles.titleMedium.copyWith(color: Palette.white100)),
                    SizedBox(height: 8.sp),
                    controller.isPremium.value == false ? 
                    Text(
                      'Получите доступ ко всем функциям приложения и расширьте возможности вашего гардероба',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    ): SizedBox.shrink(),
                    SizedBox(height: 8.sp),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Palette.red100, size: 8.sp),
                        SizedBox(width: 6.sp),
                        Text('Неограниченное количество предметов', style: TextStyles.bodyMedium  .copyWith(color: Palette.white100)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Palette.red100, size: 8.sp),
                        SizedBox(width: 6.sp),
                        Text('Расширенная аналитика стиля', style: TextStyles.bodyMedium.copyWith(color: Palette.white100)),
                      ],
                    ),
                    Row(
                      children: [
                        Icon(Icons.circle, color: Palette.red100, size: 8.sp),
                        SizedBox(width: 6.sp),
                        Text('Персональные рекомендации от стилиста', style: TextStyles.bodyMedium.copyWith(color: Palette.white100)),
                      ],
                    ),
                    SizedBox(height: 12.sp),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (controller.isPremium.value) {
                            
                          } else {
                            controller.showSubscriptionSheet();
                          }
                          
                        }, 
                        style: ButtonStyles.primary,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset('assets/icons/supcription/star.png', width: 15.sp, height: 15.sp),
                            Text(controller.isPremium.value ? 'Активна' : 'Оформить', style: TextStyles.buttonMedium.copyWith(color: Palette.white100)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6.sp),
                    controller.isPremium.value ? 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Следующее списание', style: TextStyles.labelSmall.copyWith(color: Palette.grey350)),
                        Text('${controller.premiumEnd.value?.day}.${controller.premiumEnd.value?.month}.${controller.premiumEnd.value?.year}', style: TextStyles.labelSmall.copyWith(color: Palette.grey350)),
                      ],
                    ) : SizedBox.shrink(),
                  ],

                ),
              ),
              GestureDetector(
                      onTap: () {
                        Get.to(() => InfoScreen());
                      },
                      child:
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.sp),
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Row(
                  children: [
                     Container(
                        height: 36.sp,
                        width: 36.sp,
                        decoration: BoxDecoration(
                          color: Palette.red200,
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/profile/lichnoe.svg',
                            width: 20.sp,
                            height: 20.sp,
                          ),
                        ),
                      ),
                    
                    SizedBox(width: 12.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Личные данные', style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                        Text('Имя, номер телефона, город', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Palette.white100, size: 15.sp),
                  ],
                ),
              ),),
              GestureDetector(
                      onTap: () {
                        Get.to(() => NotificationsScreen());
                      },
                      child:
              Container(
                margin: EdgeInsets.symmetric(horizontal: 12.sp),
                padding: EdgeInsets.all(12.sp),
                decoration: BoxDecoration(
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Row(
                  children: [
                    GetX<NotificationsController>(
                      builder: (notifCtrl) {
                        final badge = notifCtrl.unreadCount.value > 0;
                        return Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              height: 36.sp,
                              width: 36.sp,
                              decoration: BoxDecoration(
                                color: Palette.red200,
                                borderRadius: BorderRadius.circular(12.sp),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  'assets/icons/profile/notifs.svg',
                                  width: 20.sp,
                                  height: 20.sp,
                                ),
                              ),
                            ),
                            if (badge)
                              Positioned(
                                right: -2,
                                top: -2,
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                    SizedBox(width: 12.sp),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Уведомления', style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                        Text('Список уведомлений', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
                      ],
                    ),
                    Spacer(),
                    Icon(Icons.arrow_forward_ios, color: Palette.white100, size: 15.sp),
                  ],
                ),
              ),),
               GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      constraints: BoxConstraints(
                        maxWidth: 350.sp,
                        minWidth: 350.sp,
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
                      decoration: BoxDecoration(
                        color: Palette.red600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Center(child: Container(
                            width: 40.sp,
                            height: 4.sp,
                            decoration: BoxDecoration(
                              color: Palette.grey350,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          )),
                          SizedBox(height: 16.sp),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('О приложении', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
                              SizedBox(height: 16.sp),
                              Container(
                                width: double.infinity,
                                height: 200,
                                padding: EdgeInsets.all(10.sp),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Palette.red400,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: 40.sp,
                                          height: 40.sp,
                                          decoration: BoxDecoration(
                                            color: Palette.red200,
                                            borderRadius: BorderRadius.circular(12.sp),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(8.sp),
                                            child: SvgPicture.asset('assets/icons/profile/version.svg', width: 20.sp, height: 20.sp)
                                          ),
                                        ),
                                        SizedBox(width: 12.sp),
                                        Text('Версия приложения ', style: TextStyles.titleSmall),
                                        Spacer(),
                                        Text('v1.0', style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                                      ],
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => Usloviya());
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40.sp,
                                            height: 40.sp,
                                            decoration: BoxDecoration(
                                              color: Palette.red200,
                                              borderRadius: BorderRadius.circular(12.sp),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(8.sp),
                                              child: SvgPicture.asset('assets/icons/profile/usloviya.svg', width: 20.sp, height: 20.sp)
                                            ),
                                          ),
                                          SizedBox(width: 12.sp),
                                          Text('Условия использования', style: TextStyles.titleSmall),
                                          Spacer(),
                                          Icon(Icons.arrow_forward_ios, color: Palette.white100, size: 15.sp),
                                        ],
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        Get.to(() => Usloviya());
                                      },
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 40.sp,
                                            height: 40.sp,
                                            decoration: BoxDecoration(
                                              color: Palette.red200,
                                              borderRadius: BorderRadius.circular(12.sp),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(8.sp),
                                              child: SvgPicture.asset('assets/icons/profile/usloviya.svg', width: 20.sp, height: 20.sp)
                                            ),
                                          ),
                                          SizedBox(width: 12.sp),
                                          Text('Политика конфиденциальности', style: TextStyles.titleSmall),
                                          Spacer(),
                                          Icon(Icons.arrow_forward_ios, color: Palette.white100, size: 15.sp),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16.sp),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                 child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.sp),
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 36.sp,
                        width: 36.sp,
                        decoration: BoxDecoration(
                          color: Palette.red200,
                          borderRadius: BorderRadius.circular(12.sp),
                        ),
                        child: Center(
                          child: SvgPicture.asset(
                            'assets/icons/profile/faq.svg',
                            width: 20.sp,
                            height: 20.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.sp),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('О приложении', style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                          Text('Версия приложения: v1.0', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.arrow_forward_ios, color: Palette.white100, size: 15.sp),
                    ],
                  ),
                               ),
               ),
              Spacer(),
Padding(
  padding: const EdgeInsets.all(8.0),
  child: ElevatedButton(
    style: ButtonStyles.outlined,
    onPressed: () {
      showDialog(
                                                                      context: context,
                                                                      builder: (context) => AlertDialog(
                                                                        backgroundColor: Palette.red400,
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20),
                                                                        ),
                                                                        title: Text(
                                                                          'Выйти из аккаунта?',
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
                                                                                  controller.logout();
                                                                                },
                                                                                child: Text('Выйти', style: TextStyles.buttonSmall.copyWith(color: Palette.error),textAlign: TextAlign.center,),
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
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset('assets/icons/profile/logout.svg', width: 15.sp, height: 15.sp),
        Text('Выйти из аккаунта', style: TextStyles.buttonMedium.copyWith(color: Palette.white100)),
      ],
    ),
  ),
),
            ],

          )
          
          ),
        ),
      ),
    );
  }
}