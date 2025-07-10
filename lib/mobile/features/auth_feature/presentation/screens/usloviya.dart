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
            title: Text('Политика конфиденциальности', style: TextStyles.titleLarge),
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
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Center(
                    child: Text(
                      'Политика конфиденциальности Dolooki',
                      style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Center(
                    child: Text(
                      'Последнее обновление: 09 июля 2025',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  
                  // Введение
                  Text(
                    'Настоящая Политика конфиденциальности описывает наши принципы и процедуры сбора, использования и раскрытия вашей информации при использовании Сервиса и рассказывает о ваших правах в области конфиденциальности и о том, как закон защищает вас.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Мы используем ваши персональные данные для предоставления и улучшения Сервиса. Используя Сервис, вы соглашаетесь на сбор и использование информации в соответствии с настоящей Политикой конфиденциальности.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Интерпретация и определения
                  _buildSectionTitle('Интерпретация и определения'),
                  
                  _buildSubTitle('Интерпретация'),
                  Text(
                    'Слова, первая буква которых написана с заглавной буквы, имеют значения, определенные в следующих условиях. Следующие определения имеют одинаковое значение независимо от того, употребляются ли они в единственном или множественном числе.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 16.h),
                  _buildSubTitle('Определения'),
                  Text(
                    'Для целей настоящей Политики конфиденциальности:',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 12.h),
                  
                  _buildDefinition('Аккаунт', 'означает уникальную учетную запись, созданную для вас для доступа к нашему Сервису или его частям.'),
                  _buildDefinition('Аффилированное лицо', 'означает юридическое лицо, которое контролирует, контролируется или находится под общим контролем со стороной.'),
                  _buildDefinition('Приложение', 'относится к Dolooki, программному обеспечению, предоставляемому Компанией.'),
                  _buildDefinition('Компания', '(именуемая либо "Компания", "мы", "нас" или "наш") относится к Dolooki.'),
                  _buildDefinition('Страна', 'относится к: Россия'),
                  _buildDefinition('Устройство', 'означает любое устройство, которое может получить доступ к Сервису, например компьютер, мобильный телефон или цифровой планшет.'),
                  _buildDefinition('Персональные данные', 'это любая информация, которая относится к идентифицированному или идентифицируемому физическому лицу.'),
                  _buildDefinition('Сервис', 'относится к Приложению или Веб-сайту, или к обоим.'),
                  _buildDefinition('Данные об использовании', 'относятся к данным, собираемым автоматически, либо генерируемым при использовании Сервиса.'),
                  _buildDefinition('Веб-сайт', 'относится к Dolooki, доступному по адресу www.dooloki.ru'),
                  _buildDefinition('Вы', 'означает физическое лицо, получающее доступ к Сервису или использующее его.'),
                  
                  SizedBox(height: 32.h),
                  
                  // Сбор и использование персональных данных
                  _buildSectionTitle('Сбор и использование ваших персональных данных'),
                  
                  _buildSubTitle('Типы собираемых данных'),
                  
                  _buildSubSubTitle('Персональные данные'),
                  Text(
                    'При использовании нашего Сервиса мы можем попросить вас предоставить нам определенную личную информацию, которая может быть использована для связи с вами или вашей идентификации. Личная информация может включать, но не ограничивается:',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 8.h),
                  _buildBulletPoint('Адрес электронной почты'),
                  _buildBulletPoint('Имя и фамилия'),
                  _buildBulletPoint('Номер телефона'),
                  _buildBulletPoint('Данные об использовании'),
                  
                  SizedBox(height: 16.h),
                  _buildSubSubTitle('Данные об использовании'),
                  Text(
                    'Данные об использовании собираются автоматически при использовании Сервиса.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Данные об использовании могут включать такую информацию, как IP-адрес вашего устройства, тип браузера, версия браузера, страницы нашего Сервиса, которые вы посещаете, время и дата вашего визита, время, проведенное на этих страницах, уникальные идентификаторы устройства и другие диагностические данные.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 16.h),
                  _buildSubSubTitle('Информация, собираемая при использовании Приложения'),
                  Text(
                    'При использовании нашего Приложения, чтобы предоставить функции нашего Приложения, мы можем собирать с вашего предварительного разрешения:',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 8.h),
                  _buildBulletPoint('Фотографии и другую информацию с камеры и фотобиблиотеки вашего устройства'),
                  SizedBox(height: 8.h),
                  Text(
                    'Мы используем эту информацию для предоставления функций нашего Сервиса, улучшения и настройки нашего Сервиса. Вы можете включить или отключить доступ к этой информации в любое время через настройки вашего устройства.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Использование персональных данных
                  _buildSectionTitle('Использование ваших персональных данных'),
                  Text(
                    'Компания может использовать персональные данные для следующих целей:',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 12.h),
                  _buildBulletPoint('Для предоставления и поддержания нашего Сервиса, включая мониторинг использования нашего Сервиса'),
                  _buildBulletPoint('Для управления вашим аккаунтом: для управления вашей регистрацией как пользователя Сервиса'),
                  _buildBulletPoint('Для связи с вами: для связи с вами по электронной почте, телефонным звонкам, SMS или другими эквивалентными формами электронной связи'),
                  _buildBulletPoint('Для предоставления вам новостей, специальных предложений и общей информации о других товарах, услугах и событиях'),
                  _buildBulletPoint('Для управления вашими запросами: для обработки и управления вашими запросами к нам'),
                  
                  SizedBox(height: 32.h),
                  
                  // Хранение персональных данных
                  _buildSectionTitle('Хранение ваших персональных данных'),
                  Text(
                    'Компания будет хранить ваши персональные данные только до тех пор, пока это необходимо для целей, изложенных в настоящей Политике конфиденциальности. Мы будем хранить и использовать ваши персональные данные в той мере, в какой это необходимо для соблюдения наших правовых обязательств, разрешения споров и обеспечения соблюдения наших правовых соглашений и политик.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Удаление персональных данных
                  _buildSectionTitle('Удаление ваших персональных данных'),
                  Text(
                    'Вы имеете право удалить или запросить помощь в удалении персональных данных, которые мы собрали о вас.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Наш Сервис может предоставить вам возможность удалить определенную информацию о вас из Сервиса. Вы можете обновить, изменить или удалить вашу информацию в любое время, войдя в свой аккаунт и посетив раздел настроек аккаунта.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Безопасность персональных данных
                  _buildSectionTitle('Безопасность ваших персональных данных'),
                  Text(
                    'Безопасность ваших персональных данных важна для нас, но помните, что ни один метод передачи через Интернет или метод электронного хранения не является на 100% безопасным. Хотя мы стремимся использовать коммерчески приемлемые средства для защиты ваших персональных данных, мы не можем гарантировать их абсолютную безопасность.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Конфиденциальность детей
                  _buildSectionTitle('Конфиденциальность детей'),
                  Text(
                    'Наш Сервис не предназначен для лиц младше 13 лет. Мы сознательно не собираем личную информацию от лиц младше 13 лет. Если вы являетесь родителем или опекуном и знаете, что ваш ребенок предоставил нам персональные данные, пожалуйста, свяжитесь с нами.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Изменения в политике конфиденциальности
                  _buildSectionTitle('Изменения в настоящей Политике конфиденциальности'),
                  Text(
                    'Мы можем время от времени обновлять нашу Политику конфиденциальности. Мы уведомим вас о любых изменениях, разместив новую Политику конфиденциальности на этой странице.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Рекомендуется периодически просматривать настоящую Политику конфиденциальности на предмет изменений. Изменения в настоящей Политике конфиденциальности вступают в силу с момента их размещения на данной странице.',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  
                  SizedBox(height: 32.h),
                  
                  // Контактная информация
                  _buildSectionTitle('Свяжитесь с нами'),
                  Text(
                    'Если у вас есть какие-либо вопросы относительно настоящей Политики конфиденциальности, вы можете связаться с нами:',
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 12.h),
                  
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: Palette.red400,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.email, color: Palette.white100, size: 20.sp),
                        SizedBox(width: 12.w),
                        Text(
                          'e0390772@gmail.com',
                          style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                        ),
                      ],
                    ),
                  ),
                  
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: Text(
        title,
        style: TextStyles.titleLarge.copyWith(color: Palette.white100),
      ),
    );
  }

  Widget _buildSubTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h, top: 16.h),
      child: Text(
        title,
        style: TextStyles.titleMedium.copyWith(color: Palette.white100),
      ),
    );
  }

  Widget _buildSubSubTitle(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h, top: 12.h),
      child: Text(
        title,
        style: TextStyles.titleSmall.copyWith(color: Palette.white100),
      ),
    );
  }

  Widget _buildDefinition(String term, String definition) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: '$term ',
              style: TextStyles.bodyLarge.copyWith(
                color: Palette.white100,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextSpan(
              text: definition,
              style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 6.h, left: 16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 8.h, right: 8.w),
            width: 4.sp,
            height: 4.sp,
            decoration: BoxDecoration(
              color: Palette.white100,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
            ),
          ),
        ],
      ),
    );
  }
}
