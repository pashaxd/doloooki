import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/web/features/users_feature/controllers/users_controller.dart';
import 'package:doloooki/web/features/users_feature/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart' hide UserInfo;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/web_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:doloooki/web/features/users_feature/screens/user_info.dart';


class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UsersController controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    controller = Get.put(UsersController());
    
    // Слушаем изменения табов
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        controller.setFilter(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(24.sp)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок с кнопкой обновления
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Пользователи',
                      style: TextStyles.headlineMedium.copyWith(color: Palette.white100),
                    ),
                    SizedBox(height: ResponsiveUtils.containerSize(8.h)),
                    Text(
                      'Просматривайте пользователей и перемещайтесь к ним для создания гардероба',
                      style: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                    ),
                  ],
                ),
              ),
              Obx(() => IconButton(
                onPressed: controller.isLoading.value ? null : () => controller.refreshUsers(),
                icon: controller.isLoading.value 
                  ? SizedBox(
                      width: ResponsiveUtils.containerSize(20.w),
                      height: ResponsiveUtils.containerSize(20.h),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Palette.white100,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      color: Palette.white100,
                      size: ResponsiveUtils.containerSize(24.sp),
                    ),
              )),
            ],
          ),
          SizedBox(height: ResponsiveUtils.containerSize(32.h)),

          // TabBar фильтры
          SizedBox(
            width: ResponsiveUtils.containerSize(500.w),
            child: TabBar(
              controller: _tabController,
              labelPadding: EdgeInsets.symmetric(horizontal: ResponsiveUtils.containerSize(16.w)),
              indicator: UnderlineTabIndicator(
                borderSide: BorderSide(
                  color: Palette.red100,
                  width: ResponsiveUtils.containerSize(2.h),
                ),
                insets: EdgeInsets.zero,
              ),
              
              indicatorPadding: EdgeInsets.zero,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Palette.grey350.withOpacity(0.3),
              dividerHeight: ResponsiveUtils.containerSize(1.h),
              labelColor: Palette.white100,
              unselectedLabelColor: Palette.grey350,
              labelStyle: TextStyles.titleMedium.copyWith(fontWeight: FontWeight.w600),
              unselectedLabelStyle: TextStyles.titleMedium,
              tabs: [
                Tab(text: 'Все'),
                Tab(text: 'Подписка активна'),
                Tab(text: 'Подписка отключена'),
              ],
            ),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(24.h)),

          // Контент
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return _buildLoadingState();
              }
              
              if (controller.errorMessage.value.isNotEmpty) {
                return _buildErrorState(controller);
              }
              
              if (controller.filteredUsers.isEmpty) {
                return _buildEmptyState();
              }
              
              return _buildUsersTable(controller);
            }),
          ),
        ],
      ),
    );
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
            'Загрузка пользователей...',
            style: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(UsersController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: ResponsiveUtils.containerSize(64.sp),
            color: Palette.error,
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          Text(
            'Ошибка загрузки',
            style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          Text(
            controller.errorMessage.value,
            style: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          SizedBox(
            height: ResponsiveUtils.containerSize(35.h),
            child: ElevatedButton(
              onPressed: () => controller.refreshUsers(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.red400,
                foregroundColor: Palette.white100,
              ),
              child: Text('Попробовать снова', style: TextStyles.bodyMedium),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/left_navigation/users.svg',
            width: ResponsiveUtils.containerSize(100.w),
            height: ResponsiveUtils.containerSize(100.h),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(16.h)),
          Text(
            'Зарегистрированных пользователей нет',
            style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
          ),
          SizedBox(height: ResponsiveUtils.containerSize(8.h)),
          Text(
            'Пока в приложении никто не зарегистрировался',
            style: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable(UsersController controller) {
    return Container(
       decoration: BoxDecoration(
              border: Border.all(
                color: Palette.grey350,
                width: ResponsiveUtils.containerSize(1.h),
              ),
              color: Palette.red600.withOpacity(0.3),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.containerSize(100.r),
              ),
            ),
      child: Column(
        children: [
          // Заголовки таблицы
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.containerSize(24.w),
              vertical: ResponsiveUtils.containerSize(16.h),
            ),
            decoration: BoxDecoration(
              
              color: Palette.red600.withOpacity(0.3),
              borderRadius: BorderRadius.circular(
                ResponsiveUtils.containerSize(12.r),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: ResponsiveUtils.containerSize(40.w),
                  child: Text(
                    '№',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.containerSize(24.w)),
                Expanded(
                  child: Text(
                    'Имя пользователя',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                ),
                SizedBox(
                  width: ResponsiveUtils.containerSize(150.w),
                  child: Text(
                    'Статус подписки',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                ),
                SizedBox(width: ResponsiveUtils.containerSize(40.w)), // Для иконки
              ],
            ),
          ),
      
          // Список пользователей
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Palette.red600.withOpacity(0.1),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(ResponsiveUtils.containerSize(12.r)),
                  bottomRight: Radius.circular(ResponsiveUtils.containerSize(12.r)),
                ),
              ),
              child: Obx(() {
                final users = controller.getCurrentPageUsers();
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final globalIndex = (controller.currentPage.value - 1) * controller.usersPerPage + index + 1;
                    return _buildUserRow(user, globalIndex);
                  },
                );
              }),
            ),
          ),
      
          // Пагинация
          Obx(() => _buildPagination(controller)),
        ],
      ),
    );
  }

  Widget _buildUserRow(UserModel user, int index) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveUtils.containerSize(24.w),
        vertical: ResponsiveUtils.containerSize(16.h),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Palette.red600.withOpacity(0.2),
            width: ResponsiveUtils.containerSize(1.h),
          ),
        ),
      ),
      child: Row(
        children: [
          // Номер
          SizedBox(
            width: ResponsiveUtils.containerSize(40.w),
            child: Text(
              index.toString(),
              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            ),
          ),
          SizedBox(width: ResponsiveUtils.containerSize(24.w)),

          // Аватар и имя
          Expanded(
            child: Row(
              children: [
                user.profileImage.isNotEmpty
                    ? _buildProfileImage(user.profileImage, user.fullName)
                    : Container(
                        width: ResponsiveUtils.containerSize(40.w),
                        height: ResponsiveUtils.containerSize(40.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Palette.red400,
                        ),
                        child: Icon(
                          Icons.person,
                          color: Palette.white100,
                          size: ResponsiveUtils.containerSize(20.sp),
                        ),
                      ),
                SizedBox(width: ResponsiveUtils.containerSize(12.w)),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (user.phone.isNotEmpty)
                        Text(
                          user.phone,
                          style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Статус подписки
          SizedBox(
            width: ResponsiveUtils.containerSize(100.w),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.containerSize(12.w),
                vertical: ResponsiveUtils.containerSize(6.h),
              ),
              decoration: BoxDecoration(
                color: user.hasActiveSubscription ? Palette.success.withOpacity(0.2) : Palette.red100.withOpacity(0.2),
                borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(30.r)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (user.hasActiveSubscription)
                  
                    SvgPicture.asset('assets/icons/stylist/star.svg',
                    width: ResponsiveUtils.containerSize(30.sp),
                    height: ResponsiveUtils.containerSize(30.h),
                    color: user.hasActiveSubscription ? Palette.success : Palette.red400,
                  ),
                  SizedBox(width: ResponsiveUtils.containerSize(4.w)),
                  Text(
                    user.hasActiveSubscription ? 'Активно' : 'Не активно',
                    style: TextStyles.bodySmall.copyWith(
                      color: user.hasActiveSubscription ? Palette.success : Palette.error,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Стрелка
          IconButton(
            onPressed: () => controller.selectUserForInfo(user.id),
            icon: Icon(
              Icons.chevron_right,
              color: Palette.grey350,
              size: ResponsiveUtils.containerSize(20.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPagination(UsersController controller) {
    if (controller.totalPages <= 1) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: ResponsiveUtils.containerSize(16.h)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Предыдущая страница
          IconButton(
            onPressed: controller.currentPage.value > 1
                ? () => controller.goToPage(controller.currentPage.value - 1)
                : null,
            icon: Icon(
              Icons.chevron_left,
              color: controller.currentPage.value > 1 ? Palette.white100 : Palette.grey350,
              size: ResponsiveUtils.containerSize(24.sp),
            ),
          ),

          // Номера страниц
          ...List.generate(controller.totalPages, (index) {
            final pageNumber = index + 1;
            final isCurrentPage = controller.currentPage.value == pageNumber;
            
            return GestureDetector(
              onTap: () => controller.goToPage(pageNumber),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.containerSize(4.w)),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.containerSize(12.w),
                  vertical: ResponsiveUtils.containerSize(8.h),
                ),
                decoration: BoxDecoration(
                  color: isCurrentPage ? Palette.red100 : Colors.transparent,
                  borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(6.r)),
                ),
                child: Text(
                  pageNumber.toString(),
                  style: TextStyles.bodyMedium.copyWith(
                    color: isCurrentPage ? Palette.white100 : Palette.grey350,
                  ),
                ),
              ),
            );
          }),

          // Многоточие если страниц много
          if (controller.totalPages > 5) ...[
            Text(
              '...',
              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            ),
            GestureDetector(
              onTap: () => controller.goToPage(controller.totalPages),
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: ResponsiveUtils.containerSize(4.w)),
                padding: EdgeInsets.symmetric(
                  horizontal: ResponsiveUtils.containerSize(12.w),
                  vertical: ResponsiveUtils.containerSize(8.h),
                ),
                child: Text(
                  controller.totalPages.toString(),
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                ),
              ),
            ),
          ],

          // Следующая страница
          IconButton(
            onPressed: controller.currentPage.value < controller.totalPages
                ? () => controller.goToPage(controller.currentPage.value + 1)
                : null,
            icon: Icon(
              Icons.chevron_right,
              color: controller.currentPage.value < controller.totalPages ? Palette.white100 : Palette.grey350,
              size: ResponsiveUtils.containerSize(24.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl, String fullName) {
    if (imageUrl.isEmpty) {
      return Icon(
        Icons.person,
        color: Palette.white100,
        size: ResponsiveUtils.containerSize(20.sp),
      );
    }

    return WebImageWidget(
      imageUrl: imageUrl,
      width: ResponsiveUtils.containerSize(40.w),
      height: ResponsiveUtils.containerSize(40.w),
      fit: BoxFit.cover,
      isCircular: true,
      debugName: fullName,
      placeholder: Container(
        width: ResponsiveUtils.containerSize(40.w),
        height: ResponsiveUtils.containerSize(40.w),
        decoration: BoxDecoration(
          color: Palette.red400,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Palette.white100,
          ),
        ),
      ),
      errorWidget: Container(
        width: ResponsiveUtils.containerSize(40.w),
        height: ResponsiveUtils.containerSize(40.w),
        decoration: BoxDecoration(
          color: Palette.red400,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.person,
          color: Palette.white100,
          size: ResponsiveUtils.containerSize(20.sp),
        ),
      ),
    );
  }
}