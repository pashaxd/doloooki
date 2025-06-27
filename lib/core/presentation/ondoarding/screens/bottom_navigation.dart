import 'package:doloooki/core/presentation/ondoarding/controllers/bottom_navig_bar_controller.dart';
import 'package:doloooki/core/presentation/ondoarding/widgets/custom_bar.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/screens/patterns_screen.dart';
import 'package:doloooki/mobile/features/profile_feature/presentations/screens/profile_screen.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/recomendations_screen.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/screens/stylist_screen.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/wardrobe_screen.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class BottomNavigation extends StatelessWidget {
  final BottomNavigBarController navController = Get.put(BottomNavigBarController());

  final List<Widget> pages = [
    WardrobeScreen(),
    PatternsScreen(),
    RecomendationsPatternsScreen(),
    StylistScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          body: pages[navController.currentIndex.value],
          bottomNavigationBar: CustomBottomNavBar(
            currentIndex: navController.currentIndex.value,
            onTap: navController.switchTab,
          ),
        ),
      ),
    ));
  }
}