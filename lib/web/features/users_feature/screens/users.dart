import 'package:doloooki/web/features/users_feature/controllers/users_controller.dart';
import 'package:doloooki/web/features/users_feature/screens/user_info.dart';
import 'package:doloooki/web/features/users_feature/screens/users_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

class Users extends StatelessWidget {
  const Users({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(UsersController());
    return Obx(() {
      switch (controller.index.value) {
        case 0:
          return UsersScreen();
        case 1:
          return UserInfo(userId: controller.selectedUserId);
        default:
          return Container();
      }
    });
  }
}