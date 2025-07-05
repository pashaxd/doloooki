import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class StylistNotificationsService {
  final _firestore = FirebaseFirestore.instance;

  // Отправка уведомления пользователю о новом образе от стилиста
  Future<void> sendOutfitNotification({
    required String userId,
    required String stylistName,
    required String outfitName,
    String? description,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Новый образ от $stylistName',
        description: description ?? 'Стилист $stylistName создал для вас новый образ "$outfitName". Посмотрите его в приложении!',
        createdAt: DateTime.now(),
        type: 'style',
      );

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notification.toJson());

      print('Stylist notification sent to user: $userId');
    } catch (e) {
      print('Error sending stylist notification: $e');
      throw Exception('Failed to send stylist notification: $e');
    }
  }

  // Отправка уведомления всем пользователям с активной подпиской
  Future<void> sendOutfitNotificationToAllSubscribers({
    required String stylistName,
    required String outfitName,
    String? description,
  }) async {
    try {
      final now = DateTime.now();
      
      // Получаем всех пользователей с активной подпиской
      final usersSnapshot = await _firestore
          .collection('users')
          .where('isPremium', isEqualTo: true)
          .where('premiumEnd', isGreaterThan: Timestamp.fromDate(now))
          .get();

      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Новый образ от $stylistName',
        description: description ?? 'Стилист $stylistName создал новый образ "$outfitName". Посмотрите его в приложении!',
        createdAt: DateTime.now(),
        type: 'style',
      );

      // Отправляем уведомление каждому пользователю
      final batch = _firestore.batch();
      
      for (final userDoc in usersSnapshot.docs) {
        final notificationRef = userDoc.reference
            .collection('notifications')
            .doc();
        
        batch.set(notificationRef, notification.toJson());
      }

      await batch.commit();
      print('Stylist notification sent to ${usersSnapshot.docs.length} subscribers');
    } catch (e) {
      print('Error sending stylist notification to all subscribers: $e');
      throw Exception('Failed to send stylist notification to all subscribers: $e');
    }
  }

  // Отправка уведомления конкретным пользователям
  Future<void> sendOutfitNotificationToUsers({
    required List<String> userIds,
    required String stylistName,
    required String outfitName,
    String? description,
  }) async {
    try {
      final notification = NotificationModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Новый образ от $stylistName',
        description: description ?? 'Стилист $stylistName создал для вас новый образ "$outfitName". Посмотрите его в приложении!',
        createdAt: DateTime.now(),
        type: 'style',
      );

      final batch = _firestore.batch();
      
      for (final userId in userIds) {
        final notificationRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc();
        
        batch.set(notificationRef, notification.toJson());
      }

      await batch.commit();
      print('Stylist notification sent to ${userIds.length} users');
    } catch (e) {
      print('Error sending stylist notification to users: $e');
      throw Exception('Failed to send stylist notification to users: $e');
    }
  }

  // Получение списка пользователей с активной подпиской
  Future<List<String>> getActiveSubscribers() async {
    try {
      final now = DateTime.now();
      
      final usersSnapshot = await _firestore
          .collection('users')
          .where('isPremium', isEqualTo: true)
          .where('premiumEnd', isGreaterThan: Timestamp.fromDate(now))
          .get();

      return usersSnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      print('Error getting active subscribers: $e');
      return [];
    }
  }

  // Получение статистики уведомлений
  Future<Map<String, dynamic>> getNotificationStats() async {
    try {
      final now = DateTime.now();
      final weekAgo = now.subtract(Duration(days: 7));
      
      // Получаем количество пользователей с активной подпиской
      final activeSubscribersSnapshot = await _firestore
          .collection('users')
          .where('isPremium', isEqualTo: true)
          .where('premiumEnd', isGreaterThan: Timestamp.fromDate(now))
          .get();

      // Получаем количество уведомлений за последнюю неделю
      final notificationsSnapshot = await _firestore
          .collectionGroup('notifications')
          .where('createdAt', isGreaterThan: Timestamp.fromDate(weekAgo))
          .where('type', isEqualTo: 'style')
          .get();

      return {
        'activeSubscribers': activeSubscribersSnapshot.docs.length,
        'notificationsThisWeek': notificationsSnapshot.docs.length,
        'lastUpdated': now.toIso8601String(),
      };
    } catch (e) {
      print('Error getting notification stats: $e');
      return {
        'activeSubscribers': 0,
        'notificationsThisWeek': 0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    }
  }
} 