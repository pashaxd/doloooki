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
  final AuthController controller = Get.put(AuthController());
  @override
  Widget build(BuildContext context) {
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
                  controller.resetVerificationState();
                  controller.isSmsError.value=false;
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
                      'Введите код подтверждения из СМС, отправленного на ${controller.phoneController.text}',
                      style: TextStyles.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: Consts.screenHeight(context) * 0.04),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        6,
                        (index) => Center(
                          child: Container(
                            width: Consts.screenWidth(context) * 0.13,
                            height: Consts.screenHeight(context) * 0.06,
                            decoration: BoxDecoration(
                              color: Palette.red500,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: TextField(
                              cursorColor: Palette.white100,
                              controller: controller.codeControllers[index],
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
                                  controller.isSmsError.value = false;
                                  return newValue;
                                }),
                              ],
                              decoration: InputDecoration(
                                counterText: '',
                                filled: true,
                                fillColor: Palette.white100.withOpacity(0.1),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: const BorderSide(color: Palette.white100),
                                ),
                                contentPadding: EdgeInsets.zero,
                              ),
                              onChanged: (value) {
                                if (value.isNotEmpty) {
                                  if (index < 5) {
                                    FocusScope.of(context).nextFocus();
                                  } else {
                                    FocusScope.of(context).unfocus();
                                  }
                                }
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.sp),
                    Obx(() => controller.canResendSms.value
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          Text('Не получили СМС код? ',style: TextStyles.bodyLarge.copyWith(color: Palette.white200),),
                          ElevatedButton(
                            onPressed: controller.resendSms, 
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
                              '${controller.resendTimer.value}',
                              style: TextStyles.labelMedium.copyWith(
                                color: Palette.white100,
                              ),
                            ),
                          ),
                        ),

                      ],
                    ),
                    ),
                    SizedBox(height: 30.sp),
                    Obx(() => controller.isSmsError.value
                      ? Column(
                          children: [
                            Container(
                              width: double.infinity,
                              height: 45.sp,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Palette.error,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset('assets/icons/sms/i.svg'),
                                  SizedBox(width: 8.sp),
                                   Text(
                                      'Неверный код подтверждения',
                                      style: TextStyles.titleSmall,
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 8.sp),
                            Text(
                              'Код не подходит. Проверьте правильность введённых цифр и срок действия кода. Если код устарел, запросите новый',
                              style: TextStyles.bodySmall.copyWith(color: Palette.error),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                    ),
                    Expanded(
                      child: Column(

                        children: [

                          Spacer(),
                          SizedBox(
                            width: Consts.screenWidth(context) * 0.9,
                            
                            child: Obx(() => ElevatedButton(
                                  style: controller.isSmsButtonEnabled.value
                                      ? ButtonStyles.primary
                                      : ButtonStyles.secondary,
                                  onPressed: controller.isSmsButtonEnabled.value
                                      ? controller.onSmsContinuePressed
                                      : null,
                                  child: Text(
                                    'Войти',
                                    style: TextStyles.buttonMedium.copyWith(
                                      color: controller.isSmsButtonEnabled.value
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
              Obx(() => controller.isLoading.value
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