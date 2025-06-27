import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/web/core/presentation/left_navigation/controllers/left_navigation_controller.dart';
import 'package:doloooki/web/core/presentation/left_navigation/widgets/navigation_item_widget.dart';
import 'package:doloooki/web/features/auth_feature/controllers/auth_controller.dart';
import 'package:doloooki/web/features/recomendations_feature/screens/recomendations_screen.dart';
import 'package:doloooki/web/features/requests_feature/screens/requests_screen.dart';
import 'package:doloooki/web/features/settings_feature/screens/settings_screen.dart';
import 'package:doloooki/web/features/users_feature/screens/users.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class LeftNavigationScreen extends StatelessWidget {
  const LeftNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LeftNavigationController());
    return Scaffold(
      backgroundColor: Palette.red600,
      body: Obx(() => Row(
        
        children: [
          controller.isOpen.value ? Container(
            padding: EdgeInsets.all(10.sp.adaptiveSpacing),
            decoration: BoxDecoration(
                border: Border(
                  right: BorderSide(color: Palette.red400, width: 1.w.adaptiveContainer),
                )

            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset('assets/logo/logo.png', width: 60.w.adaptiveIcon, height: 60.h.adaptiveIcon,),
                    SizedBox(width: 10.w.adaptiveSpacing),
                    Text('Fashion stylist', style: TextStyles.bodyMedium.copyWith(color: Palette.white100),),
                    SizedBox(width: 8.w.adaptiveSpacing),
                    
                    IconButton(onPressed: () {
                      controller.toggleMenu();
                    }, icon: Icon(Icons.menu, color: Palette.white100, size: 15.sp.adaptiveIcon,)),
                  ],
                ),
                SizedBox(height: 20.h.adaptiveSpacing),
                NavigationItemWidget(isSelected: controller.selectedIndex.value == 0, icon: 'assets/icons/left_navigation/users.svg', title: 'Пользователи', index: 0),
                NavigationItemWidget(isSelected: controller.selectedIndex.value == 1, icon: 'assets/icons/left_navigation/consultations.svg', title: 'Консультации', index: 1),
                NavigationItemWidget(isSelected: controller.selectedIndex.value == 2, icon: 'assets/icons/left_navigation/recomendations.svg', title: 'Рекомендации', index: 2),
                NavigationItemWidget(isSelected: controller.selectedIndex.value == 3, icon: 'assets/icons/left_navigation/settings.svg', title: 'Настройки', index: 3),
        
            Spacer(),
            Container(
              padding: EdgeInsets.all(10.sp.adaptiveSpacing),
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(10.sp.adaptiveRadius),
              ),
              child: Row(
                spacing: 6.w.adaptiveSpacing,
                children: [
                  Container(
                    padding: EdgeInsets.all(5.sp.adaptiveSpacing),
                    decoration: BoxDecoration(
                      color: Palette.red100,
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset('assets/icons/bottom_navigation/profile.png', width: 14.sp.adaptiveIcon, height: 14.sp.adaptiveIcon, color: Palette.white100,)),
                  Obx(() => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        controller.isLoadingStylistData.value 
                          ? 'Загрузка...' 
                          : controller.fullStylistName, 
                        style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                      ),
                      Text(
                        controller.isLoadingStylistData.value 
                          ? 'Загрузка...' 
                          : controller.stylistEmail.value, 
                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      ),
                    ],
                  )),
                  IconButton(onPressed: () {
                    try {
                      final authController = Get.find<AuthController>();
                      authController.signOut();
                    } catch (e) {
                      // Если AuthController не найден, создаем новый
                      final authController = Get.put(AuthController());
                      authController.signOut();
                    }
                  }, icon: Icon(Icons.logout, color: Palette.white100, size: 14.sp.adaptiveIcon,))
                ],
              ),
            ),
      ],
            
            ),
          ): Column(
            children: [
              IconButton(onPressed: () {
                        controller.toggleMenu();
                      }, icon: Icon(Icons.menu, color: Palette.white100, size: 15.sp.adaptiveIcon,)),
            ],
          ),

                   Expanded(
                     child: controller.selectedIndex.value==0?Users():
                     controller.selectedIndex.value==1?RequestsScreen():
                     controller.selectedIndex.value==2?RecomendationsScreen():
                     controller.selectedIndex.value==3?SettingsScreen():
                     Container(),
                   ),

        ],
      ),
      ),
    );
  }
}