import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/item_info.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class WardrobeCard extends StatelessWidget {
  final ClothesItem item;

  WardrobeCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Get.to(() => ItemInfo(itemId: item.id,)),
      child: SizedBox(
        width: Consts.screenWidth(context)*0.3,
        height: Consts.screenHeight(context)*0.2, 
        child: Column(
          children: [
            
             ClipRRect(
              
                borderRadius: BorderRadius.circular(20),
                child: Image.network(item.imageUrl, width: Consts.screenWidth(context)*0.3, height: Consts.screenHeight(context)*0.2, fit: BoxFit.cover,),
              ),
            SizedBox(height: 10,),
            Text(item.name, style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
          ],
        ),
      ),
    );
  }
}