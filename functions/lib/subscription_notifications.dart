import 'package:cloud_firestore/cloud_firestore.dart';

// Cloud Function для отправки уведомлений об истечении подписки
// Эта функция должна запускаться по расписанию (например, каждый день в 9:00)
Future<void> sendSubscriptionExpirationNotifications() async {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final tomorrow = now.add(Duration(days: 1));
  
  try {
    // Получаем всех пользователей, у которых подписка истекает завтра
    final usersSnapshot = await firestore
        .collection('users')
        .where('isPremium', isEqualTo: true)
        .where('premiumEnd', isGreaterThan: Timestamp.fromDate(now))
        .where('premiumEnd', isLessThan: Timestamp.fromDate(tomorrow))
        .get();

    print('Found ${usersSnapshot.docs.length} users with expiring subscriptions');

    // Отправляем уведомления каждому пользователю
    final batch = firestore.batch();
    
    for (final userDoc in usersSnapshot.docs) {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'Подписка истекает',
        'description': 'Ваша подписка истекает завтра. Продлите её, чтобы продолжить пользоваться всеми функциями.',
        'createdAt': Timestamp.now(),
        'type': 'subscription',
      };

      final notificationRef = userDoc.reference
          .collection('notifications')
          .doc();
      
      batch.set(notificationRef, notification);
    }

    await batch.commit();
    print('Expiration notifications sent to ${usersSnapshot.docs.length} users');
  } catch (e) {
    print('Error sending expiration notifications: $e');
    throw Exception('Failed to send expiration notifications: $e');
  }
}

// Cloud Function для отправки уведомлений о конце пробного периода
Future<void> sendTrialEndNotifications() async {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  final tomorrow = now.add(Duration(days: 1));
  
  try {
    // Получаем всех пользователей с пробным периодом, который истекает завтра
    final usersSnapshot = await firestore
        .collection('users')
        .where('isPremium', isEqualTo: true)
        .where('premiumEnd', isGreaterThan: Timestamp.fromDate(now))
        .where('premiumEnd', isLessThan: Timestamp.fromDate(tomorrow))
        .where('hasTrialUsed', isEqualTo: true)
        .get();

    print('Found ${usersSnapshot.docs.length} users with expiring trial');

    // Отправляем уведомления каждому пользователю
    final batch = firestore.batch();
    
    for (final userDoc in usersSnapshot.docs) {
      final notification = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'Пробный период заканчивается',
        'description': 'Ваш пробный период заканчивается завтра. Оформите подписку, чтобы продолжить пользоваться всеми функциями.',
        'createdAt': Timestamp.now(),
        'type': 'subscription',
      };

      final notificationRef = userDoc.reference
          .collection('notifications')
          .doc();
      
      batch.set(notificationRef, notification);
    }

    await batch.commit();
    print('Trial end notifications sent to ${usersSnapshot.docs.length} users');
  } catch (e) {
    print('Error sending trial end notifications: $e');
    throw Exception('Failed to send trial end notifications: $e');
  }
}

// Cloud Function для очистки истекших подписок
Future<void> cleanupExpiredSubscriptions() async {
  final firestore = FirebaseFirestore.instance;
  final now = DateTime.now();
  
  try {
    // Получаем всех пользователей с истекшей подпиской
    final usersSnapshot = await firestore
        .collection('users')
        .where('isPremium', isEqualTo: true)
        .where('premiumEnd', isLessThan: Timestamp.fromDate(now))
        .get();

    print('Found ${usersSnapshot.docs.length} users with expired subscriptions');

    // Обновляем статус подписки
    final batch = firestore.batch();
    
    for (final userDoc in usersSnapshot.docs) {
      batch.update(userDoc.reference, {
        'isPremium': false,
      });
    }

    await batch.commit();
    print('Expired subscriptions cleaned up for ${usersSnapshot.docs.length} users');
  } catch (e) {
    print('Error cleaning up expired subscriptions: $e');
    throw Exception('Failed to cleanup expired subscriptions: $e');
  }
}

// Cloud Function для отправки уведомлений от стилистов
Future<void> sendStylistOutfitNotification({
  required String stylistName,
  required String outfitName,
  String? description,
  List<String>? targetUserIds,
}) async {
  final firestore = FirebaseFirestore.instance;
  
  try {
    final notification = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Новый образ от $stylistName',
      'description': description ?? 'Стилист $stylistName создал новый образ "$outfitName". Посмотрите его в приложении!',
      'createdAt': Timestamp.now(),
      'type': 'style',
    };

    if (targetUserIds != null && targetUserIds.isNotEmpty) {
      // Отправляем уведомление конкретным пользователям
      final batch = firestore.batch();
      
      for (final userId in targetUserIds) {
        final notificationRef = firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc();
        
        batch.set(notificationRef, notification);
      }

      await batch.commit();
      print('Stylist notification sent to ${targetUserIds.length} specific users');
    } else {
      // Отправляем уведомление всем пользователям с активной подпиской
      final now = DateTime.now();
      
      final usersSnapshot = await firestore
          .collection('users')
          .where('isPremium', isEqualTo: true)
          .where('premiumEnd', isGreaterThan: Timestamp.fromDate(now))
          .get();

      final batch = firestore.batch();
      
      for (final userDoc in usersSnapshot.docs) {
        final notificationRef = userDoc.reference
            .collection('notifications')
            .doc();
        
        batch.set(notificationRef, notification);
      }

      await batch.commit();
      print('Stylist notification sent to ${usersSnapshot.docs.length} subscribers');
    }
  } catch (e) {
    print('Error sending stylist notification: $e');
    throw Exception('Failed to send stylist notification: $e');
  }
} 