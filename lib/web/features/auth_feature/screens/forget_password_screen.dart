import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/web/features/auth_feature/controllers/auth_controller.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/usloviya.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    
    return Scaffold(
      backgroundColor: Palette.red20,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(20.sp.adaptiveSpacing),
          width: ResponsiveUtils.containerSize(500.w),
         
          decoration: BoxDecoration(
            color: Palette.red600,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset('assets/logo/logo.png', width: 50.w.adaptiveIcon, height: 50.h.adaptiveIcon),
              SizedBox(height: 15.h),
              Text('Забыли пароль', style: TextStyles.headlineLarge),
              
              // Email поле с валидацией
              Obx(() => TextFormField(
                style: TextStyles.bodyMedium,
                controller: controller.emailController.value,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-mail',
                  labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  floatingLabelStyle: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                  floatingLabelBehavior: FloatingLabelBehavior.auto,
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: Palette.white100,
                      width: 2.0,
                    ),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                      color: controller.isEmailValid.value ? Palette.white100 : Palette.red400,
                    ),
                  ),
                  errorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                  focusedErrorBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Palette.red400),
                  ),
                  errorText: controller.emailController.value.text.isNotEmpty && !controller.isEmailValid.value
                      ? 'Введите корректный email'
                      : null,
                  errorStyle: TextStyles.labelSmall.copyWith(color: Palette.red400),
                ),
              )),
              
              SizedBox(height: 10.h),
              
              // Реактивная кнопка отправки
              Obx(() => SizedBox(
                width: double.infinity,
                height: 35.h,
                child: ElevatedButton(
                  style: (controller.isEmailValid.value && !controller.isLoading.value)
                      ? ButtonStyles.primary
                      : ButtonStyles.secondary,
                  onPressed: (controller.isEmailValid.value && !controller.isLoading.value)
                      ? controller.onForgotPasswordPressed
                      : null,
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 20.w,
                          height: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Palette.white100),
                          ),
                        )
                      : Text(
                          'Отправить',
                          style: TextStyles.bodyMedium,
                        ),
                ),
              )),
              
              SizedBox(height: 10.h),
              
              Text(
                'Введите свой адрес электронной почты, чтобы восстановить пароль. Мы вышлем ссылку для сброса пароля на это электронное письмо.',
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