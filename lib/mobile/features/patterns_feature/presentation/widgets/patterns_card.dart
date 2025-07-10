import 'package:flutter/material.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/screens/pattern_info.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:get/get.dart';

class PatternsCard extends StatelessWidget {
  final PatternItem pattern;

  PatternsCard({super.key, required this.pattern});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => PatternInfo(patternId: pattern.id)),
      child: Container(
        child: Column(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  pattern.imageUrl,
                  width: Consts.screenWidth(context) * 0.4,
                  height: Consts.screenHeight(context) * 0.3,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(Icons.image, size: 60),
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              pattern.name,
              style: TextStyles.titleSmall.copyWith(color: Palette.white100),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}