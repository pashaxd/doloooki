import 'package:doloooki/mobile/features/auth_feature/presentation/controllers/auth_controller.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;

class SmsScreen extends StatelessWidget {
  SmsScreen({super.key});

  AuthController get controller {
    // Безопасно получаем существующий контроллер
    if (Get.isRegistered<AuthController>()) {
      try {
        return Get.find<AuthController>();
      } catch (e) {
        // Если контроллер поврежден, создаем новый
        print('🔄 AuthController в SMS поврежден, создаем новый: $e');
        Get.delete<AuthController>();
        return Get.put(AuthController());
      }
    } else {
      // Создаем новый контроллер если не существует
      return Get.put(AuthController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = controller;

    return Container(
      color: Palette.red500,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            leading: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Palette.red400,
              ),
              child: IconButton(
                onPressed: () {
                  try {
                    authController.resetVerificationState();
                    authController.isSmsError.value = false;
                  } catch (e) {
                    print('⚠️ Ошибка при сбросе состояния в SMS: $e');
                  }
                  Get.back();
                },
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: Palette.white100,
              ),
            ),
            backgroundColor: Palette.red500,
            title: Text('СМС-Код', style: TextStyles.titleLarge),
            centerTitle: true,
          ),
          backgroundColor: Palette.red500,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
                child: Column(
                  children: [
                    Text(
                      'Введите код подтверждения из СМС, отправленного на ${authController.phoneController.text}',
                      style: TextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Consts.screenHeight(context) * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => Container(
                          width: Consts.screenWidth(context) * 0.13,
                          height: Consts.screenHeight(context) * 0.06,
                          decoration: BoxDecoration(
                            color: Palette.red500,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextField(
                            cursorColor: Palette.white100,
                            controller: authController.codeControllers[index],
                            style: TextStyles.titleLarge.copyWith(
                              color: Palette.white100,
                              height: 1.0,
                            ),
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              TextInputFormatter.withFunction((oldValue, newValue) {
                                if (oldValue.text.isNotEmpty && newValue.text.isEmpty && index > 0) {
                                  FocusScope.of(context).previousFocus();
                                }
                                try {
                                  authController.isSmsError.value = false;
                                } catch (e) {
                                  print('⚠️ Ошибка при сбросе ошибки SMS: $e');
                                }
                                return newValue;
                              }),
                            ],
                            onChanged: (value) {
                              try {
                                if (value.isNotEmpty && index < 5) {
                                  FocusScope.of(context).nextFocus();
                                }
                                authController.isSmsError.value = false;
                              } catch (e) {
                                print('⚠️ Ошибка при изменении кода: $e');
                              }
                            },
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Palette.red400,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Palette.red400,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20),
                                borderSide: BorderSide(
                                  color: Palette.white100,
                                  width: 2,
                                ),
                              ),
                              counterText: '',
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: Consts.screenHeight(context) * 0.02),
                    Obx(() => authController.isSmsError.value
                        ? Text(
                            'Неверный код. Попробуйте ещё раз.',
                            style: TextStyles.bodyMedium.copyWith(color: Palette.error),
                            textAlign: TextAlign.center,
                          )
                        : const SizedBox.shrink(),
                    ),
                    SizedBox(height: Consts.screenHeight(context) * 0.02),
                    Obx(() => authController.canResendSms.value
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text('Не получили СМС код? ',style: TextStyles.bodyLarge.copyWith(color: Palette.white200),),
                          ElevatedButton(
                            onPressed: () {
                              try {
                                authController.resendSms();
                              } catch (e) {
                                print('⚠️ Ошибка при повторной отправке SMS: $e');
                              }
                            }, 
                            child: Text('Отправить',style: TextStyles.buttonSmall.copyWith(color: Palette.white100),),
                          style: ButtonStyles.outlined,
                          )
                    ],)
                        : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Выслать код повторно через: ',
                          style: TextStyles.labelMedium.copyWith(
                            color: Palette.grey350,
                          ),
                        ),
                        Container(
                          width: 50.sp,
                          height: 25.sp,
                          decoration: BoxDecoration(
                            color: Palette.white100.withOpacity(0.0),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Palette.red400,width: 1),
                          ),
                          child: Center(
                            child: Text(
                              '${authController.resendTimer.value}',
                              style: TextStyles.labelMedium.copyWith(
                                color: Palette.white100,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Spacer(),
                          SizedBox(
                            width: Consts.screenWidth(context) * 0.9,
                            child: Obx(() => ElevatedButton(
                                  style: authController.isSmsButtonEnabled.value
                                      ? ButtonStyles.primary
                                      : ButtonStyles.secondary,
                                  onPressed: authController.isSmsButtonEnabled.value
                                      ? () {
                                          try {
                                            authController.onSmsContinuePressed();
                                          } catch (e) {
                                            print('⚠️ Ошибка при входе через SMS: $e');
                                          }
                                        }
                                      : null,
                                  child: Text(
                                    'Войти',
                                    style: TextStyles.buttonMedium.copyWith(
                                      color: authController.isSmsButtonEnabled.value
                                          ? Palette.white100
                                          : Palette.grey350,
                                    ),
                                  ),
                                )),
                          ),
                        ],
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