class PaymentCard {
  final String id;
  final String userId;
  final String lastFourDigits;
  final String cardholderName;
  final String expiryMonth;
  final String expiryYear;
  final bool isDefault;
  final DateTime createdAt;

  PaymentCard({
    required this.id,
    required this.userId,
    required this.lastFourDigits,
    required this.cardholderName,
    required this.expiryMonth,
    required this.expiryYear,
    this.isDefault = false,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'lastFourDigits': lastFourDigits,
      'cardholderName': cardholderName,
      'expiryMonth': expiryMonth,
      'expiryYear': expiryYear,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory PaymentCard.fromMap(Map<String, dynamic> map) {
    return PaymentCard(
      id: map['id'] as String,
      userId: map['userId'] as String,
      lastFourDigits: map['lastFourDigits'] as String,
      cardholderName: map['cardholderName'] as String,
      expiryMonth: map['expiryMonth'] as String,
      expiryYear: map['expiryYear'] as String,
      isDefault: map['isDefault'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }
} 