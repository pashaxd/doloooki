import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/web/features/auth_feature/controllers/auth_controller.dart';
import 'package:doloooki/web/features/auth_feature/screens/auth_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class CheckingInfoScreen extends StatelessWidget {
   CheckingInfoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Palette.red20,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(30.sp.adaptiveSpacing),
          width: 400.w.adaptiveContainer,

          decoration: BoxDecoration(
            color: Palette.red600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Кнопка назад
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.offAll(() => const AuthFeature(isLogin: true));
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
              
              SizedBox(height: 20.h),
              
              // Иконка часов (проверка)
              
                Center(
                  child: Icon(
                    Icons.access_time_rounded,
                    color: Palette.warning,
                    size: 20.sp.adaptiveIcon,
                  ),
                ),
              
              
              SizedBox(height: 20.h.adaptiveSpacing ),
              
              Text(
                'Данные отправлены на проверку',
                style: TextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 15.h.adaptiveSpacing),
              
              Text(
                'В настоящее время ваши данные проверяются. Как только процесс будет завершен, вы получите уведомление по электронной почте.',
                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 30.h.adaptiveSpacing),
              
              // Кнопка возврата
              SizedBox(
                width: double.infinity,
                height: 35.h,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Palette.red400,
                    foregroundColor: Palette.white100,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () {
                    Get.offAll(() => const AuthFeature(isLogin: true));
                  },
                  child: Text(
                    'Вернуться к входу в систему',
                    style: TextStyles.bodyMedium,
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