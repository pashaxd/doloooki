import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/web/features/auth_feature/controllers/auth_controller.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/usloviya.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/web/features/auth_feature/screens/forget_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AuthFeature extends StatelessWidget {
  final bool isLogin;
  const AuthFeature({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AuthController());
    
    return Scaffold(
      backgroundColor: Palette.red20,
      body: Center(
        child: 
           Container(
            width: ResponsiveUtils.containerSize(500.w) ,
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              color: Palette.red600,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo/logo.png', width: 50.w.adaptiveIcon, height: 50.h.adaptiveIcon ),
                SizedBox(height: 15.h),
                Text(isLogin ? 'Вход' : 'Cоздать аккаунта', style: TextStyles.headlineLarge),
                
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
                
                // Password поле с валидацией
                Obx(() => TextFormField(
                  controller: controller.passwordController.value,
                  obscureText: !controller.isPasswordVisible.value,
                  style: TextStyles.bodyMedium,
                  decoration: InputDecoration(
                    labelText: 'Пароль',
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
                        color: controller.isPasswordValid.value ? Palette.white100 : Palette.red400,
                      ),
                    ),
                    errorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.red400),
                    ),
                    focusedErrorBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Palette.red400),
                    ),
                    suffixIcon: GestureDetector(
                      onTap: controller.togglePasswordVisibility,
                      child: Icon(
                        controller.isPasswordVisible.value 
                            ? Icons.visibility_outlined 
                            : Icons.visibility_off_outlined,
                        color: Palette.white200,
                      ),
                    ),
                    errorText: controller.passwordController.value.text.isNotEmpty && !controller.isPasswordValid.value
                        ? 'Минимум 8 символов'
                        : null,
                    errorStyle: TextStyles.labelSmall.copyWith(color: Palette.red400),
                  ),
                )),

                // Поле подтверждения пароля (только для регистрации)
                if (!isLogin) ...[
                  SizedBox(height: 10.h),
                  Obx(() => TextFormField(
                    controller: controller.confirmPasswordController.value,
                    obscureText: !controller.isConfirmPasswordVisible.value,
                    style: TextStyles.bodyMedium,
                    decoration: InputDecoration(
                      labelText: 'Подтвердите пароль',
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
                          color: controller.isConfirmPasswordValid.value ? Palette.white100 : Palette.red400,
                        ),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Palette.red400),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Palette.red400),
                      ),
                      suffixIcon: GestureDetector(
                        onTap: controller.toggleConfirmPasswordVisibility,
                        child: Icon(
                          controller.isConfirmPasswordVisible.value 
                              ? Icons.visibility_outlined 
                              : Icons.visibility_off_outlined,
                          color: Palette.white200,
                        ),
                      ),
                      errorText: controller.confirmPasswordController.value.text.isNotEmpty && !controller.isConfirmPasswordValid.value
                          ? 'Пароли не совпадают'
                          : null,
                      errorStyle: TextStyles.labelSmall.copyWith(color: Palette.red400),
                    ),
                  )),
                ],
                
                SizedBox(height: 15.h),
                
                // Кнопка "Забыли пароль?" только для входа
                if (isLogin) 
                  Row(
                    children: [
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          controller.clearAllFields();
                          Get.to(() => ForgetPasswordScreen());
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Забыли пароль?', 
                          style: TextStyles.bodyMedium.copyWith(
                            decoration: TextDecoration.underline,
                            decorationColor: Palette.white100,
                          ),
                        ),
                      ),
                    ],
                  ),
                
                SizedBox(height: 10.h),
                
                // Реактивная кнопка
                Obx(() {
                  // Обновляем состояние кнопки в зависимости от режима
                  controller.updateButtonState(isLogin);
                  
                  return SizedBox(
                    width: double.infinity,
                    height: 35.h,
                    child: ElevatedButton(
                      style: (controller.isButtonEnabled.value && !controller.isLoading.value)
                          ? ButtonStyles.primary 
                          : ButtonStyles.secondary,
                      onPressed: (controller.isButtonEnabled.value && !controller.isLoading.value)
                          ? (isLogin ? controller.onLoginPressed : controller.onRegisterPressed)
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
                          : Text(isLogin ? 'Войти' : 'Зарегистрироваться', style: TextStyles.bodyMedium),
                    ),
                  );
                }),
                
                SizedBox(height: 10.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(isLogin ? 'Нет аккаунта? ' : 'Уже есть аккаунт? ', 
                         style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)),
                    TextButton(
                      onPressed: () {
                        // Очищаем поля перед переключением между входом и регистрацией
                        controller.clearAllFields();
                        Get.offAll(() => AuthFeature(isLogin: !isLogin));
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(
                        isLogin ? 'Создать аккаунт' : 'Войти', 
                        style: TextStyles.bodyMedium.copyWith(
                          decoration: TextDecoration.underline,
                          decorationColor: Palette.white100,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Продолжая, Вы соглашаетесь с ',
                        style: TextStyles.labelMedium.copyWith(color: Palette.grey350),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(Usloviya());
                        },
                        child: Text(
                          'Условиями использования ',
                          style: TextStyles.labelMedium.copyWith(
                            color: Palette.white100,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        'и ',
                        style: TextStyles.labelMedium.copyWith(color: Palette.grey200),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.to(Usloviya());
                        },
                        child: Text(
                          'Политикой конфиденциальности',
                          style: TextStyles.labelMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      
    );
  }
}