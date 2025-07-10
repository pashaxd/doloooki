import 'package:get/get.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/notifications_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class NotificationsController extends GetxController {
  final NotificationsService _service = NotificationsService();
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;
  StreamSubscription<User?>? _authSubscription;

  // Фильтры
  RxBool pushEnabled = true.obs;
  RxBool subscriptionEnabled = true.obs;
  RxBool styleEnabled = true.obs;
  RxBool newsEnabled = false.obs;

  String get userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    
    // Слушаем изменения состояния авторизации
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Пользователь вышел из системы, очищаем данные
        notifications.clear();
      } else {
        // Пользователь вошел в систему, загружаем уведомления с задержкой
        // чтобы избежать состояния гонки с Firestore permissions
        _loadNotificationsWithDelay();
      }
    });

    // Обновляем счётчик при любых изменениях списка уведомлений
    ever(notifications, (_) => _updateUnreadCount());
  }

  // Загрузка уведомлений с задержкой и повторными попытками
  Future<void> _loadNotificationsWithDelay() async {
    // Ждем 500мс для синхронизации Firebase Auth токена с Firestore
    await Future.delayed(Duration(milliseconds: 500));
    
    int retryCount = 0;
    const maxRetries = 3;
    
    while (retryCount < maxRetries) {
      try {
        await loadNotifications();
        return; // Успешно загружено, выходим
      } catch (e) {
        retryCount++;
        print('⚠️ Попытка $retryCount загрузки уведомлений не удалась: $e');
        
        if (e.toString().contains('permission-denied') && retryCount < maxRetries) {
          // Ждем перед повторной попыткой (экспоненциальная задержка)
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
        } else {
          // Если это не ошибка разрешений или достигнуто максимальное количество попыток
          if (e.toString().contains('permission-denied')) {
            notifications.clear();
          }
          break;
        }
      }
    }
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> loadNotifications() async {
    if (userId.isEmpty) return;
    try {
      notifications.value = await _service.fetchNotifications(userId);
    } catch (e) {
      print('Error loading notifications: $e');
      if (e.toString().contains('permission-denied')) {
        // Если нет прав доступа, очищаем уведомления
        notifications.clear();
      }
    }
  }

  Future<void> addNotification(NotificationModel notification) async {
    if (userId.isEmpty) return;
    try {
      await _service.addNotification(userId, notification);
      await loadNotifications();
    } catch (e) {
      print('Error adding notification: $e');
      if (e.toString().contains('permission-denied')) {
        notifications.clear();
      }
    }
  }

  Future<void> deleteNotification(String notifId) async {
    if (userId.isEmpty) return;
    try {
      await _service.deleteNotification(userId, notifId);
      await loadNotifications();
    } catch (e) {
      print('Error deleting notification: $e');
      if (e.toString().contains('permission-denied')) {
        notifications.clear();
      }
    }
  }

  // Создание уведомления о продлении подписки
  Future<void> addSubscriptionRenewalNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Подписка продлена',
      description: 'Ваша подписка успешно продлена. Продолжайте пользоваться всеми функциями приложения.',
      createdAt: DateTime.now(),
      type: 'subscription',
    );
    await addNotification(notification);
  }

  // Создание уведомления об истечении подписки
  Future<void> addSubscriptionExpirationNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Подписка истекает',
      description: 'Ваша подписка истекает завтра. Продлите её, чтобы продолжить пользоваться всеми функциями.',
      createdAt: DateTime.now(),
      type: 'subscription',
    );
    await addNotification(notification);
  }

  // Создание уведомления от стилиста о новом образе
  Future<void> addStylistOutfitNotification({
    required String stylistName,
    required String outfitName,
    String? description,
  }) async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Новый образ от $stylistName',
      description: description ?? 'Стилист $stylistName создал для вас новый образ "$outfitName". Посмотрите его в приложении!',
      createdAt: DateTime.now(),
      type: 'style',
    );
    await addNotification(notification);
  }

  // Создание уведомления о начале пробного периода
  Future<void> addTrialStartNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Пробный период активирован',
      description: 'Ваш 7-дневный пробный период начался. Попробуйте все премиум функции бесплатно!',
      createdAt: DateTime.now(),
      type: 'subscription',
    );
    await addNotification(notification);
  }

  // Создание уведомления о конце пробного периода
  Future<void> addTrialEndNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Пробный период заканчивается',
      description: 'Ваш пробный период заканчивается завтра. Оформите подписку, чтобы продолжить пользоваться всеми функциями.',
      createdAt: DateTime.now(),
      type: 'subscription',
    );
    await addNotification(notification);
  }

  // Создание уведомления об успешной оплате
  Future<void> addPaymentSuccessNotification() async {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'Оплата прошла успешно',
      description: 'Ваша подписка оформлена на 30 дней. Наслаждайтесь всеми премиум функциями!',
      createdAt: DateTime.now(),
      type: 'subscription',
    );
    await addNotification(notification);
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

  // Получение количества непрочитанных уведомлений
  int get totalUnread => unreadCount.value;

  // Получение уведомлений определенного типа
  List<NotificationModel> getNotificationsByType(String type) {
    return notifications.where((n) => n.type == type).toList();
  }

  // Получение последних уведомлений
  List<NotificationModel> getRecentNotifications(int count) {
    final sorted = notifications.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sorted.take(count).toList();
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.isRead).length;
  }

  Future<void> markAllAsRead() async {
    if (userId.isEmpty) return;
    try {
      await _service.markAllNotificationsRead(userId);
      await loadNotifications();
    } catch (e) {
      print('Error marking notifications as read: $e');
    }
  }
}
