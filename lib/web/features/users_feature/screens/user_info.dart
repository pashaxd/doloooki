import 'package:doloooki/web/features/users_feature/controllers/user_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/web_image_widget.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/web/features/users_feature/controllers/users_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:doloooki/web/features/users_feature/widgets/adding_patern.dart';

class UserInfo extends StatelessWidget {
  final String? userId;
  
  const UserInfo({super.key, this.userId});

  @override
  Widget build(BuildContext context) {
    // Создаем контроллер с тегом для уникальности
    final tag = userId ?? 'default';
    final controller = Get.put(UserInfoController(), tag: tag);
    
    // Устанавливаем целевого пользователя если передан userId
    if (userId != null && controller.targetUserId != userId) {
      controller.setTargetUser(userId!);
    }

    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }

      // Переключение между видами
      switch (controller.currentView.value) {
        case ViewMode.wardrobe:
          return Align(
            alignment: Alignment.topCenter,
            child: _buildCategoryView(controller, 'Гардероб', controller.allClothes),
          );
        case ViewMode.patterns:
          return Align(
            alignment: Alignment.topCenter,
            child: _buildCategoryView(controller, 'Образы', controller.allPatterns),
          );
        case ViewMode.profile:
        default:
          return _buildProfileView(controller);
      }
    });
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Palette.red400,
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          Text(
            'Загрузка профиля...',
            style: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileView(UserInfoController controller) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопкой назад
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final usersController = Get.find<UsersController>();
                    usersController.goBackToUsersList();
                  },
                  icon: Icon(
                    Icons.arrow_back,
                    color: Palette.white100,
                    size: ResponsiveUtils.containerSize(24.sp),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.containerSize(8.w)),
                Text(
                  'Профиль пользователя',
                  style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => controller.refreshData(),
                  icon: Icon(
                    Icons.refresh,
                    color: Palette.white100,
                    size: ResponsiveUtils.containerSize(24.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.containerSize(24.h)),

            // Профиль пользователя
            _buildUserProfile(controller),
            SizedBox(height: ResponsiveUtils.containerSize(32.h)),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Блок Гардероб
                _buildWardrobeSection(controller),
                SizedBox(height: ResponsiveUtils.containerSize(32.h)),
                
                // Блок Образы
                _buildPatternsSection(controller),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile(UserInfoController controller) {
    final userProfile = controller.userProfile.value;
    final avatarUrl = userProfile?['profileImage'] ?? '';
    final phoneNumber = userProfile?['phone'] ?? '';
    
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
        border: Border.all(
          color: Palette.red400,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Аватар пользователя
          avatarUrl.isNotEmpty
              ? WebImageWidget(
                  imageUrl: avatarUrl,
                  width: ResponsiveUtils.containerSize(40.w),
                  height: ResponsiveUtils.containerSize(40.w),
                  isCircular: true,
                  debugName: controller.userFullName,
                  placeholder: Container(
                    width: ResponsiveUtils.containerSize(80.w),
                    height: ResponsiveUtils.containerSize(80.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Palette.red400,
                    ),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Palette.white100,
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    width: ResponsiveUtils.containerSize(80.w),
                    height: ResponsiveUtils.containerSize(80.w),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Palette.red400,
                    ),
                    child: Icon(
                      Icons.person,
                      color: Palette.white100,
                      size: ResponsiveUtils.containerSize(40.sp),
                    ),
                  ),
                )
              : Container(
                  width: ResponsiveUtils.containerSize(80.w),
                  height: ResponsiveUtils.containerSize(80.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Palette.red400,
                  ),
                  child: Icon(
                    Icons.person,
                    color: Palette.white100,
                    size: ResponsiveUtils.containerSize(40.sp),
                  ),
                ),
          SizedBox(width: ResponsiveUtils.containerSize(20.w)),
          
          // Информация о пользователе
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.userFullName.isNotEmpty ? controller.userFullName : 'Пользователь',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                ),
                if (phoneNumber.isNotEmpty) ...[
                  SizedBox(height: ResponsiveUtils.containerSize(4.h)),
                  Text(
                    phoneNumber,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                ],
                SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                // Статус подписки (placeholder)
               
              ],
            ),
          ),
           Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(12.w),
                    vertical: ResponsiveUtils.containerSize(6.h),
                  ),
                  decoration: BoxDecoration(
                    color: Palette.success.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Palette.success,
                        size: ResponsiveUtils.containerSize(16.sp),
                      ),
                      SizedBox(width: ResponsiveUtils.containerSize(4.w)),
                      Text(
                        'Активно',
                        style: TextStyles.bodySmall.copyWith(color: Palette.success),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildWardrobeSection(UserInfoController controller) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(12.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
        border: Border.all(
              color: Palette.red400,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Гардероб',
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
          
              
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          
          SizedBox(
            height: ResponsiveUtils.containerSize(450.h),
            child: controller.recentClothes.isEmpty
                ? _buildEmptyState('Нет вещей в гардеробе')
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.recentClothes.length,
                    itemBuilder: (context, index) {
                      final item = controller.recentClothes[index];
                      return _buildHorizontalItemCard(item.imageUrl, item.name);
                    },
                  ),
          ),
          Center(
            child: TextButton(
              onPressed: () => controller.navigateToWardrobe(),
              child: Text('Перейти в гардероб', style: TextStyles.titleMedium.copyWith(color: Palette.grey350),),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternsSection(UserInfoController controller) {
    return Container(
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(12.sp)),
      decoration: BoxDecoration(
        color: Palette.red400,
        borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
        border: Border.all(
          color: Palette.red400,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Образы',
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              const Spacer(),
              // Кнопка "Создать образ"
              ElevatedButton.icon(
                onPressed: () {
                  // Передаем ID пользователя, чей гардероб мы хотим использовать
                  final targetUserId = controller.targetUserId ?? userId;
                  if (targetUserId != null) {
                    showPatternEditor(userId: targetUserId);
                  }
                },
                icon: Icon(
                  Icons.add,
                  color: Palette.white100,
                  size: ResponsiveUtils.containerSize(16.sp),
                ),
                label: Text(
                  'Создать образ',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Palette.red100,
                  foregroundColor: Palette.white100,
                  padding: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtils.containerSize(16.w),
                    vertical: ResponsiveUtils.containerSize(8.h),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(20.r)),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          
          SizedBox(
            height: ResponsiveUtils.containerSize(450.h),
            child: controller.recentPatterns.isEmpty
                ? _buildEmptyState('Нет созданных образов')
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: controller.recentPatterns.length,
                    itemBuilder: (context, index) {
                      final item = controller.recentPatterns[index];
                      return _buildHorizontalItemCard(item.imageUrl, item.name);
                    },
                  ),
          ),
          Center(
            child: TextButton(
              onPressed: () => controller.navigateToPatterns(),
              child: Text('Перейти в гардероб', style: TextStyles.titleMedium.copyWith(color: Palette.grey350),),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHorizontalItemCard(String imageUrl, String name) {
    return Container(
        width: ResponsiveUtils.containerSize(120.w),
        
      margin: EdgeInsets.only(right: ResponsiveUtils.containerSize(12.w)),
      child: Column(
      
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Изображение
          Expanded(
            child: Container(

              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(8.r)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                child: WebImageWidget(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  debugName: name,
                  placeholder: Container(
                    color: Palette.red400,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Palette.grey350,
                      ),
                    ),
                  ),
                  errorWidget: Container(
                    color: Palette.red400,
                    child: Icon(
                      Icons.image,
                      color: Palette.grey350,
                      size: ResponsiveUtils.containerSize(24.sp),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          // Название
          Center(
            child: Text(
              name,
              style: TextStyles.titleSmall.copyWith(color: Palette.white100),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Text(
        message,
        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
      ),
    );
  }

  Widget _buildCategoryView(UserInfoController controller, String title, List<dynamic> items) {
    final columns = controller.getGridColumns(items.length);
    
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(16.sp)),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок с кнопкой назад
            Row(
              children: [
                IconButton(
                  onPressed: () => controller.backToProfile(),
                  icon: Icon(
                    Icons.arrow_back,
                    color: Palette.white100,
                    size: ResponsiveUtils.containerSize(24.sp),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.containerSize(8.w)),
                Text(
                  'Профиль пользователя',
                  style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
                ),
                Spacer(),
                IconButton(
                  onPressed: () => controller.refreshData(),
                  icon: Icon(
                    Icons.refresh,
                    color: Palette.white100,
                    size: ResponsiveUtils.containerSize(24.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: ResponsiveUtils.containerSize(24.h)),

            // Профиль пользователя (как в основном виде)
            _buildUserProfile(controller),
            SizedBox(height: ResponsiveUtils.containerSize(32.h)),

            // Секция с элементами
            Container(
              padding: EdgeInsets.all(ResponsiveUtils.containerSize(12.sp)),
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
                border: Border.all(
                  color: Palette.red400,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                      ),
                    ],
                  ),
                  SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                  
                  // GridView с элементами
                  items.isEmpty
                      ? Container(
                          height: ResponsiveUtils.containerSize(200.h),
                          child: _buildEmptyState('Нет элементов в категории'),
                        )
                      : GridView.builder(
                          shrinkWrap: true,

                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            crossAxisSpacing: ResponsiveUtils.containerSize(12.w),
                            mainAxisSpacing: ResponsiveUtils.containerSize(12.h),
                            childAspectRatio: 1, // Пропорции как в оригинальных карточках
                          ),
                          itemCount: items.length,
                          itemBuilder: (context, index) {
                            final item = items[index];
                            String imageUrl = '';
                            String name = '';
                            
                            if (item is ClothesItem) {
                              imageUrl = item.imageUrl;
                              name = item.name;
                            } else if (item is PatternItem) {
                              imageUrl = item.imageUrl;
                              name = item.name;
                            }
                            
                            return _buildHorizontalItemCard(imageUrl, name);
                          },
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

}