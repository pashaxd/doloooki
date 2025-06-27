import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../controllers/notifications_controller.dart';
import '../../data/models/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'Только что';
    if (diff.inMinutes < 60) return '${diff.inMinutes} минут назад';
    if (diff.inHours < 24 && now.day == date.day) return 'Сегодня';
    if (now.year == date.year) {
      return '${date.day} ${_monthName(date.month)}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}.${date.month}.${date.year}';
  }

  String _monthName(int month) {
    const months = [
      '', 'янв', 'фев', 'мар', 'апр', 'май', 'июн',
      'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NotificationsController());
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          appBar: AppBar(
            backgroundColor: Palette.red600,
            elevation: 0,
            leading: Padding(
              padding: EdgeInsets.all(8.0),
              child: GestureDetector(
                onTap: () => Get.back(),
                child: 
                  Icon(Icons.arrow_back_ios, color: Palette.white100, size: 20.sp),
                
              ),
            ),
            centerTitle: true,
            title: Text('Уведомления', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
            actions: [
              GestureDetector(
                onTap: () {
                  Get.bottomSheet(
                    Container(
                      height: 400.sp,
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
                              
                                  Text('Настройка уведомлений', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
                                  SizedBox(height: 16.sp),
                              _settingTile('Пуш-уведомления', controller.pushEnabled),
                                          _settingTile('Уведомления о подписке', controller.subscriptionEnabled),
                                          _settingTile('Рекомендации по стилю', controller.styleEnabled),
                                          _settingTile('Новости и обновления', controller.newsEnabled),                            ],),
                            ],
                          )));
                },
                child: Container(
                  padding: EdgeInsets.all(12.sp),
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(Icons.settings, color: Palette.white100),
                ),
              ),
            ],
          ),
          body: Obx(() {
            final notifs = controller.notifications;
            if (notifs.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 12.sp),
                child: Column(
                  spacing: 8.sp,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset('assets/icons/notifications/notifs.svg'),
                    Text('Уведомления пусты', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
                    Text('Здесь будут отображаться важные уведомления о ваших объявлениях, новых предложениях и активности в приложении', style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),textAlign: TextAlign.center,),
                  ],
                ),
              );
            }
            return ListView.separated(
              padding: EdgeInsets.only(top: 16.sp, bottom: 16.sp),
              itemCount: notifs.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.sp),
              itemBuilder: (context, i) {
                final n = notifs[i];
                final isNew = n.type == 'new'; // или любая ваша логика
                return Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 14.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              n.title,
                              style: TextStyles.titleMedium.copyWith(color: Palette.white100, fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (isNew)
                            Padding(
                              padding: EdgeInsets.only(left: 6.sp, top: 4.sp),
                              child: Container(
                                width: 8.sp,
                                height: 8.sp,
                                decoration: BoxDecoration(
                                  color: Palette.error,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4.sp),
                      Text(
                        n.description,
                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      ),
                      SizedBox(height: 8.sp),
                      Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          formatTime(n.createdAt),
                          style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}
Widget _settingTile(String title, RxBool value) {
    return Obx(() => Container(
      margin: EdgeInsets.only(bottom: 4.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyles.titleMedium.copyWith(color: Palette.white100)),
          Switch(
            thumbColor: MaterialStateProperty.all(Palette.white100),
            value: value.value,
            onChanged: (v) => value.value = v,
            activeTrackColor: Palette.success,
            inactiveThumbColor: Palette.grey350,
            inactiveTrackColor: Palette.black100,
          ),
        ],
      ),
    ));
  }
