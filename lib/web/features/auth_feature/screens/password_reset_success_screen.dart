import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/web/features/auth_feature/screens/auth_feature.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class PasswordResetSuccessScreen extends StatelessWidget {
  final String email;
  
  const PasswordResetSuccessScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.red20,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.sp.adaptiveSpacing),
          width: 500.w.adaptiveContainer,
          
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
                          size: 15.sp.adaptiveIcon,
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
              
              SizedBox(height: 20.h.adaptiveSpacing),
              
              // Зеленая иконка успеха
             
            Center(
                  child: SvgPicture.asset(
                    'icons/auth_pc/success.svg',
                    width: 100.w.adaptiveIcon,
                    height: 100.h.adaptiveIcon,
                  ),
                ),
              
              
              SizedBox(height: 20.h.adaptiveSpacing),
              
              Text(
                'Отправленна ссылка',
                style: TextStyles.headlineLarge,
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 15.h.adaptiveSpacing),
              
              Text(
                'Проверьте свою электронную почту. Мы отправили ссылку для сброса пароля на указанный адрес. Если вы не получите письмо в течение нескольких минут, пожалуйста, проверьте папку со спамом.',
                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
} 