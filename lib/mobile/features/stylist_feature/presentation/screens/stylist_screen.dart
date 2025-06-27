import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/controllers/stylist_controller.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/screens/adding_request_screen.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/screens/chat_screen.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/adding_thing.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class StylistScreen extends StatelessWidget {
  const StylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    final controller = Get.put(StylistController());
    
    return Scaffold(
      backgroundColor: Palette.red600,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 4.sp),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Стилист', style: TextStyles.headlineMedium.copyWith(color: Palette.white100)),
            SizedBox(height: 16.sp),
            
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: CircularProgressIndicator(color: Palette.red100),
                  );
                }
                
                if (controller.userRequests.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/stylist/skirt.svg', 
                          color: Palette.grey350,
                          width: 80.sp,
                          height: 80.sp,
                        ),
                        SizedBox(height: 16.sp),
                        Text(
                          'Персональный стилист поможет создать идеальный образ',
                          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8.sp),
                        Text(
                          'Закажите консультацию, и стилист подберет для вас готовые сочетания одежды под любой случай.',
                          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 24.sp),
                        SizedBox(
                          width: 220.sp,
                          child: ElevatedButton(
                            style: ButtonStyles.primary,
                            onPressed: () {
                              Get.to(() => AddingRequestScreen());
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.person, color: Palette.white100, size: 16.sp),
                                SizedBox(width: 4.sp),
                                Text(
                                  'Консультация стилиста',
                                  style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                
                return ListView.separated(
                  itemCount: controller.userRequests.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12.sp),
                  itemBuilder: (context, index) {
                    final request = controller.userRequests[index];
                    return Container(
                      padding: EdgeInsets.all(12.sp),
                      decoration: BoxDecoration(
                        color: Palette.red400,
                        borderRadius: BorderRadius.circular(20.sp),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Статус и дата
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp),
                                decoration: BoxDecoration(
                                  color: request.status == 'В процессе' 
                                      ? Palette.warning.withOpacity(0.2)
                                      : request.status == 'Завершена'
                                          ? Colors.green.withOpacity(0.2)
                                          : Palette.error.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12.sp),
                                ),
                                child: Text(
                                  request.status,
                                  style: TextStyles.labelSmall.copyWith(
                                    color: request.status == 'В процессе' 
                                        ? Palette.warning
                                        : request.status == 'Завершена'
                                            ? Colors.green
                                            : Palette.error,
                                  ),
                                ),
                              ),
                             SizedBox(width: 12.sp),
                              Text(
                                'Начата ${request.createdAt.toDate().day} ${_getMonthName(request.createdAt.toDate().month)}',
                                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                              ),
                            ],
                          ),
                          
                          SizedBox(height: 8.sp),
                          
                          // Заголовок запроса
                          Text(
                            request.title,
                            style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                          ),
                          
                          SizedBox(height: 4.sp),
                          
                          // Информация о стилисте
                          Text(
                            'Стилист: ${request.stylistName} - ${request.looksCount} образа',
                            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                          ),
                          
                          SizedBox(height: 16.sp),
                          
                          // Кнопки действий
                          if (request.status == 'В процессе') ...[
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ButtonStyles.primary,
                                onPressed: () {
                                  Get.to(() => ChatScreen(request: request));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.chat_bubble, color: Palette.white100, size: 16.sp),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      'Открыть чат',
                                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ] else if (request.status == 'Завершена') ...[
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                style: ButtonStyles.outlined.copyWith(
                                  backgroundColor: WidgetStateProperty.all(Palette.red400),
                                ),
                                onPressed: () {
                                  Get.to(() => ChatScreen(request: request));
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.visibility, color: Palette.white100, size: 16.sp),
                                    SizedBox(width: 8.sp),
                                    Text(
                                      'Посмотреть чат',
                                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      
      // Floating Action Button для добавления новой консультации
      floatingActionButton: Obx(() => controller.userRequests.isNotEmpty
          ? FloatingActionButton(
              onPressed: () {
                Get.to(() => AddingRequestScreen());
              },
              backgroundColor: Palette.red100,
              child: Icon(Icons.add, color: Palette.white100),
            )
          : SizedBox.shrink()),
    );
  }

  String _getMonthName(int month) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return months[month - 1];
  }
}