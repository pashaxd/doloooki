import 'package:doloooki/mobile/features/recomendations_feature/presentation/controllers/colors.controller.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/widgets/colors_card.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ColorsRecomendations extends StatelessWidget {
   ColorsRecomendations({super.key});
  final ColorsController controller = Get.find<ColorsController>();
  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
          onRefresh: () => controller.refreshColorsModels(),
          color: Palette.red100,
          child: ListView.builder(
            physics: AlwaysScrollableScrollPhysics(),
            itemCount: controller.colorsModels.length,
            itemBuilder: (context, index) {
              final colorsModel = controller.colorsModels[index];
              return ColorsCard(colorsModel: colorsModel, isMainColors: false);
            },
          ),
          );
  }
}