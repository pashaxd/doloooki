import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/controllers/colors.controller.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/controllers/popular_info_controller.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/pattern_detail_screen.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/widgets/colors_card.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/widgets/combinations.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class ColorsInfoScreen extends StatelessWidget {
  final ColorsModel colorsModel;
  
  const ColorsInfoScreen({super.key, required this.colorsModel});

  String _formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ColorsController());
    
   

    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          appBar: AppBar(
            backgroundColor: Palette.red600,
            leading: Container(
              margin: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: IconButton(
                onPressed: () => Get.back(),
                icon: Icon(Icons.arrow_back_ios_new, color: Palette.white100),
              ),
            ),
            title: Text(
              colorsModel.name,
              style: TextStyles.titleLarge.copyWith(color: Palette.white100),
            ),
            centerTitle: true,
          ),
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
            child: SingleChildScrollView(
              child: Column(
              
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   ColorsCard(colorsModel: colorsModel, isMainColors: true),
                   Text(colorsModel.name, style: TextStyles.titleMedium.copyWith(color: Palette.white100),),
                  Text(colorsModel.description, style: TextStyles.bodyMedium.copyWith(color: Palette.white300),),
                  SizedBox(height: 12.sp),
                  Text('Основные цвета', style: TextStyles.titleSmall.copyWith(color: Palette.white100),),
                  SizedBox(height: 8.sp),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      childAspectRatio: 0.65,
                      crossAxisSpacing: 4.sp,
                      mainAxisSpacing: 4.sp,
                    ),
                    itemCount: colorsModel.colors.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.only(top: 50.sp),
                        decoration: BoxDecoration(
                          color: Palette.parseHexColor(colorsModel.colors[index]),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            colorsModel.colors[index], 
                            style: TextStyles.labelSmall.copyWith(color: Palette.white100)
                          ),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 12.sp),
                  Text('Удачные сочетания', style: TextStyles.titleSmall.copyWith(color: Palette.white100),),
                  SizedBox(height: 8.sp),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                      crossAxisSpacing: 4.sp,
                      mainAxisSpacing: 4.sp,
                    ),
                    itemCount: (colorsModel.combinations.length / 4).floor(),
                    itemBuilder: (context, index) {
                      return CombinationsCard(combinations: colorsModel.combinations);
                    },
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