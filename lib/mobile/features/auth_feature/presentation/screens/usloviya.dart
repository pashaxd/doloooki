import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart' show Get;

class Usloviya extends StatelessWidget {
  const Usloviya({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: Palette.red600,
            title: Text('Условия использования', style: TextStyles.titleLarge),
            centerTitle: true,
            leading: IconButton(
              padding: EdgeInsets.zero,
              iconSize: 24.adaptiveIcon,
              onPressed: Get.back,
              icon: Container(
                width: 45.sp,
                height: 45.sp,
                decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Palette.white100,
                  size: 60.adaptiveIcon,
                ),
              ),
            ),
          ),
          backgroundColor: Palette.red600,
          body: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                   TextSpan(children:[
                     TextSpan(text: 'Условия использования приложения', style: TextStyles.bodyLarge),
                      TextSpan(text: ' «Спаси Еду»! ', style: TextStyles.labelLarge),
                      TextSpan(text: 'Дата последнего обновления: 01.03.2025', style: TextStyles.bodyLarge),
                      ]
                   )
                  ),

                  SizedBox(height: 24.h),
                  Text('1. Введение', style: TextStyles.labelLarge),
                  SizedBox(height: 16.h),
                  Text(
                    '1.1. Настоящие условия использования (далее – «Условия») регулируют отношения между [Название вашей компании] (далее – «Компания») и пользователем (далее – «Пользователь») мобильного приложения Bayke (далее – «Приложение»).',
                    style: TextStyles.bodyLarge,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '1.2. Используя приложение, Пользователь соглашается с настоящими условиями.',
                    style: TextStyles.bodyLarge,
                  ),
                  SizedBox(height: 24.h),
                  Text('2. Предмет условий', style: TextStyles.labelLarge),
                  SizedBox(height: 16.h),
                  Text(
                    '2.1. Приложение предоставляет Пользователю [краткое описание функционала приложения, например, возможность отслеживать финансы, ставить финансовые цели и т.д].',
                    style: TextStyles.bodyLarge,
                  ),
                  SizedBox(height: 24.h),
                  Text('3. Регистрация и доступ к приложению', style: TextStyles.labelLarge),
                  SizedBox(height: 16.h),
                  Text(
                    '3.1. Для использования некоторых функций приложения может потребоваться регистрация.',
                    style: TextStyles.bodyLarge,
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '3.2. Пользователь несёт ответственность за конфиденциальность своих учётных данных.',
                    style: TextStyles.bodyLarge,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
