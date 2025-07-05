import 'package:doloooki/mobile/features/auth_feature/presentation/controllers/auth_controller.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/sms.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/usloviya.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_fields.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class AuthScreen extends StatelessWidget {
  final RxBool isNumberField = false.obs;
  
  AuthScreen({super.key});

  AuthController get controller {
    // Безопасно получаем или создаем контроллер
    if (Get.isRegistered<AuthController>()) {
      try {
        return Get.find<AuthController>();
      } catch (e) {
        // Если контроллер поврежден, удаляем его и создаем новый
        print('🔄 AuthController поврежден, создаем новый: $e');
        Get.delete<AuthController>();
        return Get.put(AuthController());
      }
    } else {
      return Get.put(AuthController());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Инициализируем контроллер в build методе
    final authController = controller;
    
    // Reset verificationId when returning from SMS screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        authController.resetVerificationState();
        // Принудительно обновляем состояние кнопки
        authController.isButtonEnabled.value = authController.phoneController.text.length == 16;
      } catch (e) {
        print('⚠️ Ошибка при сбросе состояния: $e');
      }
    });

    // Создаем маску для телефонного номера
    final maskFormatter = MaskTextInputFormatter(
        mask: '+7 ### ###-##-##',
        filter: {"#": RegExp(r'[0-9]')},
        type: MaskAutoCompletionType.lazy
    );

    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold( 
          backgroundColor: Palette.red600,
          body: Stack(
            children: [
              Padding(
                padding:
                EdgeInsets.symmetric(horizontal: 10.sp,vertical: 5.sp),
                child: Column(
                  spacing: 10,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [   
                    Text(
                      'Добро пожаловать в DOLOOKI!', 
                      style: TextStyles.headlineLarge.copyWith(color: Palette.white100)
                    ),
                    Text(
                      'Создайте уникальный гардероб, который подчеркнёт вашу индивидуальность!', 
                      style: TextStyles.bodyLarge,
                    ),
                    SizedBox(height: Consts.screenHeight(context)*0.02),
                  
                    Obx(() => Column(
                      spacing: 5.sp,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Номер телефона',
                          style: TextStyles.labelMedium.copyWith(
                              color: isNumberField.value ? Palette.white200 : Palette.grey350
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                              border: isNumberField.value
                                  ? Border.all(color: Palette.white200)
                                  : Border.all(width: 0),
                              color: Palette.red400,
                              borderRadius: BorderRadius.circular(20)
                          ),
                          child: TextField(
                            inputFormatters: [maskFormatter], // Применяем маску
                            maxLength: 16, // Максимальная длина с учетом маски
                            keyboardType: TextInputType.phone,
                            onTap: () {
                              isNumberField.value = true;

                              authController.phoneController.text ==''? authController.phoneController.text = '+7 ': authController.phoneController.text;
                              FocusScope.of(context).requestFocus();
                            },
                            onTapOutside: (_) {
                              isNumberField.value = false;
                              FocusScope.of(context).unfocus();
                            },
                            showCursor: isNumberField.value,
                            style: TextStyles.bodyLarge.copyWith(
                                color: isNumberField.value ? Palette.white200 : Palette.grey350
                            ),
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              hintText: '+7 916 454-99-88',
                              hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                              counterText: '',
                            ),
                            controller: authController.phoneController,
                          ),
                        ),
                        Text(
                          'Мы отправим вам СМС с кодом для входа в приложение',

                          style: TextStyles.labelMedium.copyWith(color: Palette.grey350),
                        ),
                      ],
                    )),

                    Spacer(),
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
                                'Условиями ',
                                style: TextStyles.labelMedium.copyWith(
                                  color: Palette.white100,
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
                                    style: TextStyles.labelMedium,
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
                                style: TextStyles.labelMedium,
                              ),
                            ),
                          ],
                        )

                          ],
                        ),
                    ),

                    Center(
                      child: SizedBox(
                        width: 900.sp,
                        height: 50,
                        child: Obx(() => ElevatedButton(
                          style: authController.isButtonEnabled.value ? ButtonStyles.primary : ButtonStyles.secondary,
                          onPressed: authController.isButtonEnabled.value
                            ? () {
                                print('Кнопка нажата');
                                print('Номер телефона: ${authController.phoneController.text}');
                                print('Кнопка активна: ${authController.isButtonEnabled.value}');
                                authController.onContinuePressed();
                              }
                            : null,
                          child: Text(
                            'Получить код',
                            style: TextStyles.buttonMedium.copyWith(
                              color: authController.isButtonEnabled.value ? Palette.white100 : Palette.grey350,

                            ),
                          ),
                        )),
                      ),
                    ),

                  ],
                ),
              ),

              Obx(() => authController.isLoading.value
                ? Container(
                    color: Colors.black.withOpacity(0.5),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: Palette.white100,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}