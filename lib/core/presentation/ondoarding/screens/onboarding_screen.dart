import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:doloooki/core/presentation/ondoarding/controllers/onboarding_controller.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/auth_screen.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class OnboardingScreen extends StatelessWidget {
   OnboardingScreen({super.key});
  CarouselSliderController carouselController = CarouselSliderController();
  final OnboardingController controller = Get.put(OnboardingController());
  List<String> images = [
    'assets/onboarding/1st.png',
    'assets/onboarding/2nd.png',
    'assets/onboarding/3rd.png',
    'assets/onboarding/4th.png',
  ];
  List<String> titles = [
    'Добро пожаловать в DOLOOKI!',
    'Добавляй одежду и создавай образы',
    'Подписка открывает всё',
    'Получай помощь стилиста',
  ];
  List<String> descriptions = [
    'Приложение поможет собрать и систематизировать личный гардероб — все под рукой, ничего не потеряется.',
    'Загружай вещи, сортируй по категориям и тегам, комбинируй их на холсте ',
    'Функциональность приложения доступна только с активной подпиской.\nПробные дни — чтобы познакомиться.',
    'Хочешь готовые образы?\nОтправь запрос и получи персональные рекомендации прямо в приложении.',
  ];
  @override
  Widget build(BuildContext context) {
    return Container(

      color: Palette.red500,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Column(
            spacing: 20,
            children: [
              CarouselSlider(
                carouselController: carouselController,
                items: images.map((image) => Image.asset(image)).toList(),
                options: CarouselOptions(
                  enableInfiniteScroll: false,
                  viewportFraction: 1,
                  height: Consts.screenHeight(context)*0.55,
                  onPageChanged: (index, reason) {
                    controller.currentPage.value = index;
                  },
                ),
              ),
            
              Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  images.length,
                  (index) => Container(
                    width: Consts.screenWidth(context)*0.2,
                    height: 5,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == index
                          ? Palette.white100
                          : Palette.black100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              )),
                Obx(() => Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.sp),
                  child: Column(

                    crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                      child: Text(
                        titles[controller.currentPage.value],
                        key: ValueKey(titles[controller.currentPage.value]),
                        style: TextStyles.headlineLarge,
                      ),
                    ),
                    SizedBox(height: 8),
                    AnimatedSize(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.ease,
                      child: SizedBox(
                        width: double.infinity,
                        child: Text(
                          descriptions[controller.currentPage.value],
                          style: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                        ),
                      ),
                    ),
                  ],
                                ),
                )),

              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                  TextButton(onPressed: () {
                    carouselController.jumpToPage(images.length-1);
                  }, child: Text('Пропустить', style: TextStyles.buttonSmall.copyWith(color: Palette.grey350),)),
                  SizedBox(
                    width: 200.sp,
                    height: 41.sp,
                    child: ElevatedButton(
                      style: ButtonStyles.primary,
                      onPressed: () {
                      controller.currentPage<=2?
                      carouselController.nextPage(): Get.off(AuthScreen());
                    }, child: Text('Далее', style: TextStyles.buttonSmall,)),
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