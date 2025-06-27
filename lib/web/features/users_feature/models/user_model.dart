import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String secondName;
  final String surname;
  final String phone;
  final String profileImage;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool hasActiveSubscription; // Это поле можно вычислять на основе подписок

  UserModel({
    required this.id,
    required this.name,
    required this.secondName,
    required this.surname,
    required this.phone,
    required this.profileImage,
    required this.createdAt,
    required this.updatedAt,
    this.hasActiveSubscription = false,
  });

  String get fullName => '$surname $name $secondName'.trim();

  factory UserModel.fromFirestore(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      name: data['name'] ?? '',
      secondName: data['secondName'] ?? '',
      surname: data['surname'] ?? '',
      phone: data['phone'] ?? '',
      profileImage: data['profileImage'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // Здесь можно добавить логику проверки активной подписки
      // Например, проверить поле subscription или дату окончания подписки
      hasActiveSubscription: _checkActiveSubscription(data),
    );
  }

  static bool _checkActiveSubscription(Map<String, dynamic> data) {
    // Здесь добавьте логику проверки активной подписки
    // Например, если есть поле subscriptionEndDate:
    // final endDate = (data['subscriptionEndDate'] as Timestamp?)?.toDate();
    // return endDate != null && endDate.isAfter(DateTime.now());
    
    // Пока возвращаем случайное значение для демонстрации
    return data['hasActiveSubscription'] ?? (data.hashCode % 3 == 0);
  }
}
