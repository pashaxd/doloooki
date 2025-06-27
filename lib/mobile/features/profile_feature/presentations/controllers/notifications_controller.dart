import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notifications_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsController extends GetxController {
  final NotificationsService _service = NotificationsService();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;

  // Фильтры
  RxBool pushEnabled = true.obs;
  RxBool subscriptionEnabled = true.obs;
  RxBool styleEnabled = false.obs;
  RxBool newsEnabled = false.obs;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    if (userId.isEmpty) return;
    notifications.value = await _service.fetchNotifications(userId);
  }

  Future<void> addNotification(NotificationModel notification) async {
    if (userId.isEmpty) return;
    await _service.addNotification(userId, notification);
    await loadNotifications();
  }

  Future<void> deleteNotification(String notifId) async {
    if (userId.isEmpty) return;
    await _service.deleteNotification(userId, notifId);
    await loadNotifications();
  }

  // Геттер для фильтрованных уведомлений
  List<NotificationModel> get filteredNotifications {
    return notifications.where((n) {
      if (n.type == 'push' && !pushEnabled.value) return false;
      if (n.type == 'subscription' && !subscriptionEnabled.value) return false;
      if (n.type == 'style' && !styleEnabled.value) return false;
      if (n.type == 'news' && !newsEnabled.value) return false;
      return true;
    }).toList();
  }
}
