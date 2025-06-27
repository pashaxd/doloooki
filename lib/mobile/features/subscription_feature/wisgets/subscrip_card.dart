import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionCard extends StatelessWidget {
  const SubscriptionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        padding:  EdgeInsets.symmetric(horizontal: 16.sp,vertical: 16.sp),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(16),
      ),
      child:  Column(
        spacing: 16.sp,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
            Text('Месячная', style: TextStyles.titleMedium,),
            Text('599 ₽ / мес.', style: TextStyles.titleMedium,),
          ],),
          Container(
            
            width: 800.sp,
            height: 250.sp,
            decoration: BoxDecoration(
              color: Palette.red600,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:  EdgeInsets.all(12.sp),
                  child: Row(
                    spacing: 12.sp,
                    children: [
                      Image.asset('assets/icons/supcription/garderob.png',width: 40,height: 40,),
                      Expanded(
                        child: Text(
                          'Неограниченное количество элементов гардероба',
                          style: TextStyles.titleSmall,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(12.sp),
                  child: Row(
                    spacing: 12.sp,
                    children: [
                      Image.asset('assets/icons/supcription/platye.png',width: 40,height: 40,),
                      Expanded(
                        child: Text(
                          'Создание образов без ограничений',
                          style: TextStyles.titleSmall,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(12.sp),
                  child: Row(
                    spacing: 12.sp,
                    children: [
                      Image.asset('assets/icons/supcription/recomendations.png',width: 40,height: 40,),
                      Expanded(
                        child: Text(
                          'Доступ к рекомендациям и готовым образам',
                          style: TextStyles.titleSmall,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:  EdgeInsets.all(12.sp),
                  child: Row(
                    spacing: 12.sp    ,
                    children: [
                      Image.asset('assets/icons/supcription/fon.png',width: 40,height: 40,),
                      Expanded(
                        child: Text(
                          'Удаление фона с фотографии',
                          style: TextStyles.titleSmall,
                          softWrap: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ]
            ),
          )
        ],
      ),
    );
  }
}