import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/colors_recomendations.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/screens/recomendations_patterns.dart';
import 'package:doloooki/mobile/features/recomendations_feature/presentation/controllers/colors.controller.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class RecomendationsPatternsScreen extends StatefulWidget {
  const RecomendationsPatternsScreen({super.key});

  @override
  State<RecomendationsPatternsScreen> createState() => _RecomendationsPatternsScreenState();
}

class _RecomendationsPatternsScreenState extends State<RecomendationsPatternsScreen> 
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late ColorsController _colorsController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _colorsController = Get.put(ColorsController());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          body: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.sp, vertical: 8.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Рекомендации', 
                      style: TextStyles.headlineMedium.copyWith(color: Palette.white100),
                    ),
                    SizedBox(height: 16.sp),
                     TabBar(
                        controller: _tabController,
                       
                       
                        labelPadding: EdgeInsets.symmetric(horizontal: 8.sp),
                        indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(
                            color: Palette.red100,
                            width: 2.w,
                          ),
                          insets: EdgeInsets.zero,
                        ),
                        indicatorPadding: EdgeInsets.zero,
                        indicatorSize: TabBarIndicatorSize.tab,
                        dividerColor: Palette.white100,
                        dividerHeight: 1.sp,
                        labelColor: Palette.white100,
                        unselectedLabelColor: Palette.grey350,
                        labelStyle: TextStyles.titleMedium,
                        unselectedLabelStyle: TextStyles.titleMedium,
                        tabs: [
                          Tab(text: 'Популярные образы'),
                          Tab(text: 'Цветовые палитры'),
                        ],
                      
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    RecomendationsPatterns(),
                    ColorsRecomendations(),
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


