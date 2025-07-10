import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/profile_feature/presentations/controllers/notifications_controller.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notifController = Get.put(NotificationsController(), permanent: true);
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: Palette.red600,
        border: Border(top: BorderSide(color: Palette.red500, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavBarItem(
            icon: 'assets/icons/bottom_navigation/garderob.png',
            label: 'Гардероб',
            selected: currentIndex == 0,
            onTap: () => onTap(0),
          ),
          _NavBarItem(
            icon: 'assets/icons/bottom_navigation/obrazi.png',
            label: 'Образы',
            selected: currentIndex == 1,
            onTap: () => onTap(1),
          ),
          _NavBarItem(
            icon: 'assets/icons/bottom_navigation/recomendation.png',
            label: 'Рекомендации',
            selected: currentIndex == 2,
            onTap: () => onTap(2),
          ),
          _NavBarItem(
            icon: 'assets/icons/bottom_navigation/stylist.png',
            label: 'Стилист',
            selected: currentIndex == 3,
            onTap: () => onTap(3),
          ),
          _NavBarItem(
            icon: 'assets/icons/bottom_navigation/profile.png',
            label: 'Профиль',
            selected: currentIndex == 4,
            onTap: () => onTap(4),
            showBadgeRx: notifController.unreadCount,
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final String icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final RxInt? showBadgeRx;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.showBadgeRx,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? Palette.white50 : Palette.grey350;

    Widget iconWidget = Image.asset(icon, color: color, width: 24, height: 24);

    if (showBadgeRx != null) {
      iconWidget = Obx(() => Stack(
            clipBehavior: Clip.none,
            children: [
              Image.asset(icon, color: color, width: 24, height: 24),
              if (showBadgeRx!.value > 0)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ));
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          iconWidget,
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyles.titleSmall.copyWith(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }
}