import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/web/core/presentation/left_navigation/controllers/left_navigation_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

class NavigationItemWidget extends StatelessWidget {
  final bool isSelected;
  final String icon;
  final String title;
  final int index;
  NavigationItemWidget({super.key, required this.isSelected, required this.icon, required this.title, required this.index});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LeftNavigationController>();
    return GestureDetector(
      onTap: () {
        controller.selectedIndex.value = index;
      },
      child: Container(
        padding: EdgeInsets.all(6.sp.adaptiveSpacing),
        decoration: BoxDecoration(
          color: isSelected ? Palette.red100 : Palette.red600,
          borderRadius: BorderRadius.circular(20.sp.adaptiveRadius),
        ),
        child: Row(
          children: [
            _buildIcon(),
            SizedBox(width: 10.w.adaptiveSpacing),
            Text(title, style: isSelected ? TextStyles.titleSmall.copyWith(color: Palette.white100) : TextStyles.bodyMedium.copyWith(color: Palette.grey350),),
            
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return SvgPicture.asset(
      icon,
      width: 15.sp.adaptiveIcon,
      height: 15.sp.adaptiveIcon,
      colorFilter: ColorFilter.mode(
        isSelected ? Palette.white100 : Palette.grey350,
        BlendMode.srcIn,
      ),
      placeholderBuilder: (context) {
        // Fallback на Material Icon если SVG не загрузился
        return Icon(
          _getFallbackIcon(icon),
          color: isSelected ? Palette.white100 : Palette.grey350,
          size: 20.sp.adaptiveIcon,
        );
      },
    );
  }

  // Fallback иконки если SVG не загружается
  IconData _getFallbackIcon(String iconPath) {
    if (iconPath.contains('users')) return Icons.people_outline;
    if (iconPath.contains('consultations')) return Icons.chat_bubble_outline;
    if (iconPath.contains('recomendations')) return Icons.recommend_outlined;
    if (iconPath.contains('settings')) return Icons.settings_outlined;
    return Icons.circle_outlined;
  }
}