import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/subscription_model.dart';
import 'package:uuid/uuid.dart';

class SubscriptionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Получение ID текущего пользователя
  String? get currentUserId => _auth.currentUser?.uid;

  // Проверка аутентификации
  bool get isAuthenticated => _auth.currentUser != null;

  // Получение текущей подписки пользователя
  Future<SubscriptionModel?> getCurrentSubscription() async {
    if (!isAuthenticated) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subscriptions')
          .doc('current')
          .get();

      if (doc.exists) {
        return SubscriptionModel.fromFirestore(doc.id, doc.data()!);
      }
      return null;
    } catch (e) {
      print('Error getting current subscription: $e');
      return null;
    }
  }

  // Создание пробного периода (7 дней)
  Future<void> startTrialPeriod() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final now = DateTime.now();
      final trialEnd = now.add(Duration(days: 7));

      final subscription = SubscriptionModel(
        id: 'current',
        userId: currentUserId!,
        isActive: true,
        startDate: now,
        endDate: trialEnd,
        type: 'trial',
        isTrialUsed: true,
        trialStartDate: now,
        trialEndDate: trialEnd,
      );

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subscriptions')
          .doc('current')
          .set(subscription.toFirestore());

      // Обновляем статус пользователя
      await _firestore.collection('users').doc(currentUserId).update({
        'isPremium': true,
        'premiumStart': Timestamp.fromDate(now),
        'premiumEnd': Timestamp.fromDate(trialEnd),
        'hasTrialUsed': true,
      });

      print('Trial period started successfully');
    } catch (e) {
      print('Error starting trial period: $e');
      throw Exception('Failed to start trial period: $e');
    }
  }

  // Покупка месячной подписки
  Future<void> purchaseMonthlySubscription() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final now = DateTime.now();
      final subscriptionEnd = now.add(Duration(days: 30));

      final subscription = SubscriptionModel(
        id: 'current',
        userId: currentUserId!,
        isActive: true,
        startDate: now,
        endDate: subscriptionEnd,
        type: 'monthly',
        isTrialUsed: true, // Пробный период уже использован
      );

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subscriptions')
          .doc('current')
          .set(subscription.toFirestore());

      // Обновляем статус пользователя
      await _firestore.collection('users').doc(currentUserId).update({
        'isPremium': true,
        'premiumStart': Timestamp.fromDate(now),
        'premiumEnd': Timestamp.fromDate(subscriptionEnd),
      });

      print('Monthly subscription purchased successfully');
    } catch (e) {
      print('Error purchasing monthly subscription: $e');
      throw Exception('Failed to purchase subscription: $e');
    }
  }

  // Проверка, использовал ли пользователь пробный период
  Future<bool> hasUsedTrial() async {
    if (!isAuthenticated) return false;

    try {
      final doc = await _firestore.collection('users').doc(currentUserId).get();
      return doc.data()?['hasTrialUsed'] ?? false;
    } catch (e) {
      print('Error checking trial usage: $e');
      return false;
    }
  }

  // Проверка, нужна ли подписка (нет активной подписки)
  Future<bool> needsSubscription() async {
    final subscription = await getCurrentSubscription();
    if (subscription == null) return true;
    return !subscription.isSubscriptionActive;
  }

  // Продление подписки
  Future<void> extendSubscription(Duration duration) async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      final currentSubscription = await getCurrentSubscription();
      final now = DateTime.now();
      
      // Если подписка истекла, начинаем с текущей даты
      // Если активна, продлеваем с даты окончания
      final startDate = currentSubscription?.isSubscriptionActive == true 
          ? currentSubscription!.endDate 
          : now;
      
      final newEndDate = startDate.add(duration);

      final subscription = SubscriptionModel(
        id: 'current',
        userId: currentUserId!,
        isActive: true,
        startDate: startDate,
        endDate: newEndDate,
        type: duration.inDays >= 30 ? 'monthly' : 'trial',
        isTrialUsed: true,
      );

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subscriptions')
          .doc('current')
          .set(subscription.toFirestore());

      // Обновляем статус пользователя
      await _firestore.collection('users').doc(currentUserId).update({
        'isPremium': true,
        'premiumStart': Timestamp.fromDate(startDate),
        'premiumEnd': Timestamp.fromDate(newEndDate),
      });

      print('Subscription extended successfully');
    } catch (e) {
      print('Error extending subscription: $e');
      throw Exception('Failed to extend subscription: $e');
    }
  }

  // Отмена подписки
  Future<void> cancelSubscription() async {
    if (!isAuthenticated) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('subscriptions')
          .doc('current')
          .update({
        'isActive': false,
      });

      // Обновляем статус пользователя
      await _firestore.collection('users').doc(currentUserId).update({
        'isPremium': false,
      });

      print('Subscription cancelled successfully');
    } catch (e) {
      print('Error cancelling subscription: $e');
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Получение подписок, которые истекают в течение дня
  Stream<List<SubscriptionModel>> getExpiringSubscriptions() {
    // Если пользователь не авторизован — просто возвращаем пустой поток,
    // чтобы не пытаться выполнять запрос без UID.
    if (!isAuthenticated) {
      return Stream.value([]);
    }

    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));

    // Запрашиваем только подписки текущего пользователя, что полностью
    // соответствует правилам безопасности Firestore.
    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('subscriptions')
        .where('endDate', isGreaterThan: Timestamp.fromDate(now))
        .where('endDate', isLessThan: Timestamp.fromDate(tomorrow))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SubscriptionModel.fromFirestore(doc.id, doc.data()))
            // фильтруем активные подписки в памяти, чтобы не нужен был
            // композитный индекс (isActive == true)
            .where((sub) => sub.isActive)
            .toList());
  }

  // Создание уведомления об истечении подписки
  Future<void> createExpirationNotification(String userId, SubscriptionModel subscription) async {
    try {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'Подписка истекает',
        'description': 'Ваша подписка истекает завтра. Продлите её, чтобы продолжить пользоваться всеми функциями.',
        'createdAt': Timestamp.now(),
        'type': 'subscription',
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notification);

      print('Expiration notification created for user: $userId');
    } catch (e) {
      print('Error creating expiration notification: $e');
    }
  }
} 