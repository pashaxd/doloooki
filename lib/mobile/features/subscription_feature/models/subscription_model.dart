import 'package:cloud_firestore/cloud_firestore.dart';

class SubscriptionModel {
  final String id;
  final String userId;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final String type; // 'trial', 'monthly', 'yearly'
  final bool isTrialUsed;
  final DateTime? trialStartDate;
  final DateTime? trialEndDate;

  SubscriptionModel({
    required this.id,
    required this.userId,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.type,
    this.isTrialUsed = false,
    this.trialStartDate,
    this.trialEndDate,
  });

  factory SubscriptionModel.fromFirestore(String id, Map<String, dynamic> data) {
    return SubscriptionModel(
      id: id,
      userId: data['userId'] ?? '',
      isActive: data['isActive'] ?? false,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      type: data['type'] ?? 'trial',
      isTrialUsed: data['isTrialUsed'] ?? false,
      trialStartDate: (data['trialStartDate'] as Timestamp?)?.toDate(),
      trialEndDate: (data['trialEndDate'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'isActive': isActive,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'type': type,
      'isTrialUsed': isTrialUsed,
      'trialStartDate': trialStartDate != null ? Timestamp.fromDate(trialStartDate!) : null,
      'trialEndDate': trialEndDate != null ? Timestamp.fromDate(trialEndDate!) : null,
    };
  }

  // Проверка, активна ли подписка
  bool get isSubscriptionActive {
    return isActive && DateTime.now().isBefore(endDate);
  }

  // Проверка, истекает ли подписка в течение дня
  bool get isExpiringSoon {
    final now = DateTime.now();
    final tomorrow = now.add(Duration(days: 1));
    return isActive && endDate.isBefore(tomorrow) && endDate.isAfter(now);
  }

  // Получение оставшихся дней подписки
  int get remainingDays {
    final now = DateTime.now();
    if (!isActive || now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays;
  }

  // Создание копии с обновленными полями
  SubscriptionModel copyWith({
    String? id,
    String? userId,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    bool? isTrialUsed,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      type: type ?? this.type,
      isTrialUsed: isTrialUsed ?? this.isTrialUsed,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
    );
  }
} 