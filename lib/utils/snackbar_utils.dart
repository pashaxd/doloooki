import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';

class SnackbarUtils {
  static void showSuccess( String title,) {
    Get.rawSnackbar(
      message: '',
      messageText: Row(
        children: [
          Container(
            width: 20.sp,
            height: 20.sp,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              color: Colors.green,
              size: 14.sp,
            ),
          ),
          SizedBox(width: 6.sp),
          Text(
            title,
            style: TextStyles.titleSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          Spacer(),
          GestureDetector(
            onTap: () => Get.closeCurrentSnackbar(),
            child: Icon(
              Icons.close,
              color: Colors.white,
              size: 20.sp,
            ),
          ),
        ],
      ),
      
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF4CAF50),
      borderRadius: 12.sp,
      margin: EdgeInsets.all(12.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
      shouldIconPulse: false,
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.1),
    );
  }

  static void showError(String message, {String title = 'Ошибка'}) {
    Get.rawSnackbar(
      message: '',
      messageText: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20.sp,
                height: 20.sp,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close,
                  color: Colors.red,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 6.sp),
              Text(
                title,
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Get.closeCurrentSnackbar(),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: 4.sp),
            Padding(
              padding: EdgeInsets.only(left: 26.sp),
              child: Text(
                message,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFFE53E3E),
      borderRadius: 12.sp,
      margin: EdgeInsets.all(12.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      shouldIconPulse: false,
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.1),
    );
  }

  static void showInfo(String message, {String title = 'Информация'}) {
    Get.rawSnackbar(
      message: '',
      messageText: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20.sp,
                height: 20.sp,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.info,
                  color: Colors.blue,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 6.sp),
              Text(
                title,
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Get.closeCurrentSnackbar(),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: 4.sp),
            Padding(
              padding: EdgeInsets.only(left: 26.sp),
              child: Text(
                message,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFF3182CE),
      borderRadius: 12.sp,
      margin: EdgeInsets.all(12.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      shouldIconPulse: false,
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.1),
    );
  }

  static void showWarning(String message, {String title = 'Предупреждение'}) {
    Get.rawSnackbar(
      message: '',
      messageText: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 20.sp,
                height: 20.sp,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning,
                  color: Colors.orange,
                  size: 14.sp,
                ),
              ),
              SizedBox(width: 6.sp),
              Text(
                title,
                style: TextStyles.titleMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () => Get.closeCurrentSnackbar(),
                child: Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16.sp,
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            SizedBox(height: 4.sp),
            Padding(
              padding: EdgeInsets.only(left: 26.sp),
              child: Text(
                message,
                style: TextStyles.bodyMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ],
        ],
      ),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Color(0xFFFF8C00),
      borderRadius: 12.sp,
      margin: EdgeInsets.all(12.sp),
      padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 8.sp),
      shouldIconPulse: false,
      duration: Duration(seconds: 3),
      animationDuration: Duration(milliseconds: 300),
      forwardAnimationCurve: Curves.easeOutBack,
      reverseAnimationCurve: Curves.easeInBack,
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      overlayBlur: 0.5,
      overlayColor: Colors.black.withOpacity(0.1),
    );
  }
} 