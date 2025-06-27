import 'package:doloooki/mobile/features/stylist_feature/data/models/stylist_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/review_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/controllers/choosing_stylist_controller.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

class SyliistInfo extends StatelessWidget {
  final StylistModel stylist;
  final ChoosingStylistController controller = Get.put(ChoosingStylistController());
   SyliistInfo({super.key, required this.stylist});

  @override
  Widget build(BuildContext context) {
    controller.getAverageRating(stylist);
    double averageRating = controller.getAverageRating(stylist);
    return Container(
      height: 600.sp,
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Palette.red600,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.sp),
          topRight: Radius.circular(20.sp),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          spacing: 10.sp,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Профиль стилиста', style: TextStyles.titleLarge,),
            Container(
              width: 90.sp,
              height: 90.sp,
              decoration: BoxDecoration(
                color: Palette.red400,
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: stylist.profileImage.isNotEmpty
                    ? Image.network(
                        stylist.profileImage,
                        width: 90.sp,
                        height: 90.sp,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Palette.white100,
                              strokeWidth: 2,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          print('❌ Error loading stylist image: $error');
                          return Container(
                            color: Palette.red400,
                            child: Icon(
                              Icons.person,
                              color: Palette.white100,
                              size: 45.sp,
                            ),
                          );
                        },
                      )
                    : Container(
                        color: Palette.red400,
                        child: Icon(
                          Icons.person,
                          color: Palette.white100,
                          size: 45.sp,
                        ),
                      ),
              ),
            ),
            Text(stylist.name, style: TextStyles.titleLarge,),
            Text(stylist.shortDescription, style: TextStyles.bodyMedium.copyWith(color: Palette.white100)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Container(
                width: 100.sp,
                height: 50.sp,
                decoration: BoxDecoration(
                  border: Border.all(color: Palette.red200),
                  borderRadius: BorderRadius.circular(20.sp),
                  color: Palette.red600,
                 
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                 
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                     
                      children: [
                      SvgPicture.asset('assets/icons/stylist/star.svg'),
                      Text(averageRating.toStringAsFixed(1), style: TextStyles.titleMedium.copyWith(color: Palette.white100),),
        
                    ]),
                    Text('Рейтинг', style: TextStyles.bodySmall.copyWith(color: Palette.white100),),
                  ],),
                ),
              ),
        Container(
                width: 100.sp,
                height: 50.sp,
                decoration: BoxDecoration(
                  border: Border.all(color: Palette.red200),
                  borderRadius: BorderRadius.circular(20.sp),
                  color: Palette.red600,
                 
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                 
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                     
                      children: [
                      SvgPicture.asset('assets/icons/stylist/consult.svg'),
                      Text(stylist.consultationsCount.toString(), style: TextStyles.titleMedium.copyWith(color: Palette.white100),),
        
                    ]),
                    Text('Консультаций', style: TextStyles.bodySmall.copyWith(color: Palette.white100),),
                  ],),
                ),
              ),
               Container(
                width: 100.sp,
                height: 50.sp,
                decoration: BoxDecoration(
                  border: Border.all(color: Palette.red200),
                  borderRadius: BorderRadius.circular(20.sp),
                  color: Palette.red600,
                 
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                 
                    children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                     
                      children: [
                      SvgPicture.asset('assets/icons/stylist/check.svg', color: Palette.success),
                      Text(('${((averageRating/5)*100).round().toString()}%'), style: TextStyles.titleMedium.copyWith(color: Palette.white100),),
        
                    ]),
                    Text('Довольных', style: TextStyles.bodySmall.copyWith(color: Palette.white100),),
                  ],),
                ),
              ),
            ],),
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
               
                borderRadius: BorderRadius.circular(20.sp),
                color: Palette.red400,
               
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, 
                children: [
                  Text('О стилисте', style: TextStyles.titleMedium.copyWith(color: Palette.white100),),
                  SizedBox(height: 10.sp,),
                  Text(stylist.description, style: TextStyles.bodyMedium.copyWith(color: Palette.white100),),
                ],
              )
            ),
            Container(
              padding: EdgeInsets.all(8.sp),
              decoration: BoxDecoration(
                border: Border.all(color: Palette.red200),
                borderRadius: BorderRadius.circular(20.sp),
                color: Palette.red600,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.sp),
                  
                  // Общий рейтинг и количество отзывов
                  Row(
                    children: [
                      // Большая цифра рейтинга
                      Text(
                        averageRating.toStringAsFixed(1),
                        style: TextStyles.titleLarge.copyWith(
                          color: Palette.white100,
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 8.sp),
                      
                      // Звезды общего рейтинга
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(5, (index) {
                              return Padding(
                                padding: EdgeInsets.only(right: 2.sp),
                                child: SvgPicture.asset(
                                  'assets/icons/stylist/star.svg',
                                  width: 16.sp,
                                  height: 16.sp,
                                  colorFilter: ColorFilter.mode(
                                    index < averageRating.round() 
                                        ? Palette.warning 
                                        : Palette.grey350,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              );
                            }),
                          ),
                          SizedBox(height: 4.sp),
                          Text(
                            'Отзывов: ${stylist.reviews.length}',
                            style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16.sp),
                  
                  // Детализация по звездам
                  ...List.generate(5, (index) {
                    int starRating = 5 - index; // 5, 4, 3, 2, 1
                    int count = _getCountForRating(stylist.reviews, starRating);
                    double percentage = stylist.reviews.isNotEmpty 
                        ? count / stylist.reviews.length 
                        : 0.0;
                    
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.sp),
                      child: Row(
                        children: [
                          // Звезды для текущего рейтинга
                          Row(
                            children: List.generate(5, (starIndex) {
                              return Padding(
                                padding: EdgeInsets.only(right: 2.sp),
                                child: SvgPicture.asset(
                                  'assets/icons/stylist/star.svg',
                                  width: 12.sp,
                                  height: 12.sp,
                                  colorFilter: ColorFilter.mode(
                                    starIndex < starRating 
                                        ? Palette.warning 
                                        : Palette.grey350,
                                    BlendMode.srcIn,
                                  ),
                                ),
                              );
                            }),
                          ),
                          
                          SizedBox(width: 8.sp),
                          
                          // Прогресс бар
                          Expanded(
                            child: Container(
                              height: 8.sp,
                              decoration: BoxDecoration(
                                color: Palette.red400,
                                borderRadius: BorderRadius.circular(4.sp),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: percentage,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Palette.warning,
                                    borderRadius: BorderRadius.circular(4.sp),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          
                          SizedBox(width: 8.sp),
                          
                          // Количество отзывов
                          Text(
                            count.toString(),
                            style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 10.sp,),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: stylist.reviews.length,
              itemBuilder: (context, index) {
                final review = stylist.reviews[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12.sp),
               
                  decoration: BoxDecoration(
                    color: Palette.red600,
                    borderRadius: BorderRadius.circular(20.sp),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Заголовок с аватаром, именем и датой
                      Row(
                        children: [
                          // Аватар
                          Container(
                            width: 40.sp,
                            height: 40.sp,
                            decoration: BoxDecoration(
                              color: Palette.red400,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person,
                              color: Palette.white100,
                              size: 20.sp,
                            ),
                          ),
                          SizedBox(width: 12.sp),
                          
                          // Имя и звезды
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  review.name,
                                  style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                ),
                                SizedBox(height: 4.sp),
                                Row(
                                  children: List.generate(5, (starIndex) {
                                    return Padding(
                                      padding: EdgeInsets.only(right: 2.sp),
                                      child: SvgPicture.asset(
                                        'assets/icons/stylist/star.svg',
                                        width: 16.sp,
                                        height: 16.sp,
                                        colorFilter: ColorFilter.mode(
                                          starIndex < review.rating 
                                              ? Palette.warning 
                                              : Palette.grey350,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                          
                          // Дата
                          if (review.createdAt.isNotEmpty)
                            Text(
                              _formatDate(review.createdAt),
                              style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                            ),
                        ],
                      ),
                      
                      // Текст отзыва
                      if (review.comment.isNotEmpty) ...[
                        SizedBox(height: 12.sp),
                        Text(
                          review.comment,
                          style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                        ),
                      ],
                      SizedBox(height: 8.sp,),
                      Container(
                        width: double.infinity,
                        height: 1.sp,
                        color: Palette.red400,
                      )
                    ],
                  ),
                );
              },
            )
          ],
        ),
      ),
    );
  }

  int _getCountForRating(List<ReviewModel> reviews, int rating) {
    return reviews.where((review) => review.rating == rating).length;
  }

  String _formatDate(String date) {
    try {
      // Если дата уже в нужном формате, возвращаем как есть
      if (date.contains('.') && date.length <= 10) {
        return date;
      }
      
      // Пытаемся распарсить дату и отформатировать
      DateTime parsedDate = DateTime.parse(date);
      return '${parsedDate.day.toString().padLeft(2, '0')}.${parsedDate.month.toString().padLeft(2, '0')}.${parsedDate.year}';
    } catch (e) {
      // Если не удалось распарсить, возвращаем первые 10 символов или всю строку
      return date.length > 10 ? date.substring(0, 10) : date;
    }
  }
}