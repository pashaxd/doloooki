import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doloooki/mobile/features/subscription_feature/models/payment_card.dart';
import 'package:uuid/uuid.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Проверка аутентификации
  bool get isAuthenticated => _auth.currentUser != null;

  // Получение ID текущего пользователя
  String? get currentUserId => _auth.currentUser?.uid;

  // Получение количества карт пользователя
  Future<int> getCardsCount() async {
    if (!isAuthenticated) {
      print('Error: User not authenticated in getCardsCount');
      return 0;
    }

    try {
      final cardsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .get();
      
      return cardsSnapshot.docs.length;
    } catch (e) {
      print('Error getting cards count: $e');
      return 0;
    }
  }

  // Получение всех карт пользователя
  Stream<List<PaymentCard>> getUserCards() {
    if (!isAuthenticated) {
      print('Error: User not authenticated in getUserCards');
      return Stream.value([]);
    }

    try {
      return _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => PaymentCard.fromMap(doc.data()))
              .toList())
          .handleError((error) {
            print('Error in getUserCards stream: $error');
            // Возвращаем пустой список при ошибке
            return <PaymentCard>[];
          });
    } catch (e) {
      print('Error getting user cards: $e');
      return Stream.value([]);
    }
  }

  // Добавление новой карты
  Future<void> addCard({
    required String cardNumber,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    if (!isAuthenticated) {
      print('Error: User not authenticated in addCard');
      throw Exception('User not authenticated');
    }

    try {
      // В реальном приложении здесь должна быть интеграция с платежной системой
      // для безопасного хранения данных карты
      
      final cardId = const Uuid().v4();
      final lastFourDigits = cardNumber.substring(cardNumber.length - 4);

      // Проверяем, есть ли уже карты у пользователя
      final cardsSnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .get();

      // Создаем карту с учетом того, является ли она первой
      var card = PaymentCard(
        id: cardId,
        userId: currentUserId!,
        lastFourDigits: lastFourDigits,
        cardholderName: cardholderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        isDefault: cardsSnapshot.docs.isEmpty, // Если это первая карта, делаем её картой по умолчанию
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .doc(cardId)
          .set(card.toMap());

      print('Card added successfully: $cardId');
    } catch (e) {
      print('Error adding card: $e');
      throw Exception('Failed to add card: $e');
    }
  }

  // Удаление карты
  Future<void> deleteCard(String cardId) async {
    if (!isAuthenticated) {
      print('Error: User not authenticated in deleteCard');
      throw Exception('User not authenticated');
    }

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards')
          .doc(cardId)
          .delete();
      
      print('Card deleted successfully: $cardId');
    } catch (e) {
      print('Error deleting card: $e');
      throw Exception('Failed to delete card: $e');
    }
  }

  // Установка карты по умолчанию
  Future<void> setDefaultCard(String cardId) async {
    if (!isAuthenticated) {
      print('Error: User not authenticated in setDefaultCard');
      throw Exception('User not authenticated');
    }

    try {
      final batch = _firestore.batch();
      final cardsRef = _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('cards');

      // Сбрасываем флаг isDefault для всех карт
      final cards = await cardsRef.get();
      for (var doc in cards.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Устанавливаем новую карту по умолчанию
      batch.update(cardsRef.doc(cardId), {'isDefault': true});

      await batch.commit();
      print('Default card set successfully: $cardId');
    } catch (e) {
      print('Error setting default card: $e');
      throw Exception('Failed to set default card: $e');
    }
  }
} 