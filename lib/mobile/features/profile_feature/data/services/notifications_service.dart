import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationsService {
  final _firestore = FirebaseFirestore.instance;

  Future<List<NotificationModel>> fetchNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs
        .map((doc) => NotificationModel.fromJson(doc.data()..['id'] = doc.id))
        .toList();
  }

  Future<void> addNotification(String userId, NotificationModel notification) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification.toJson());
  }

  Future<void> deleteNotification(String userId, String notifId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notifId)
        .delete();
  }
}





