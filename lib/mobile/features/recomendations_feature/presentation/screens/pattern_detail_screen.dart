import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatternDetailScreen extends StatelessWidget {
  final PatternItem pattern;
  
  const PatternDetailScreen({super.key, required this.pattern});

  // Метод для форматирования даты
  String _formatDate(dynamic timestamp) {
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Неизвестно';
      }
      
      final months = [
        'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
        'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
      ];
      
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (e) {
      return 'Неизвестно';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Palette.red600,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Palette.red600,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        foregroundColor: Palette.white100,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: Container(
          decoration: BoxDecoration(
            color: Palette.red400,
            borderRadius: BorderRadius.circular(20),
          ),
          child: IconButton(
            onPressed: () => Get.back(),
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: Palette.white100),
          ),
        ),
      ),
      body: Container(
        color: Palette.red600,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Image.network(
                    pattern.imageUrl,
                    width: Consts.screenWidth(context)*0.9,
                    height: Consts.screenHeight(context)*0.5,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                pattern.name,
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.calendar_today, color: Palette.grey350, size: 16.sp),
                  SizedBox(width: 4.sp),
                  Text(
                    'Создан ${_formatDate(pattern.createdAt)}',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                ],
              ),
              if (pattern.description.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Описание',
                  style: TextStyles.titleSmall.copyWith(color: Palette.white100),
                ),
                const SizedBox(height: 8),
                Text(
                  pattern.description,
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                'Используемые предметы',
                style: TextStyles.titleSmall.copyWith(color: Palette.grey350),
              ),
              const SizedBox(height: 8),
              pattern.usedItems.isEmpty
                ? Text(
                    'Нет данных',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  )
                : GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.5,
                    ),
                    itemCount: pattern.usedItems.length,
                    itemBuilder: (context, index) {
                      final item = pattern.usedItems[index];
                      return SizedBox(
                        width: 100.sp,
                        height: 300.sp,
                        child: Column(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                item['imageUrl'], 
                                width: Consts.screenWidth(context)*0.3, 
                                height: Consts.screenHeight(context)*0.2, 
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              item['name'], 
                              style: TextStyles.titleSmall.copyWith(color: Palette.white100)
                            ),
                          ],
                        ),
                      );
                    },
                  ),
            ],
          ),
        ),
      ),
    );
  }
} 