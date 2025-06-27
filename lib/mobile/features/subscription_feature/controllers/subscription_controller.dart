import 'package:doloooki/mobile/features/subscription_feature/models/payment_card.dart';
import 'package:doloooki/mobile/features/subscription_feature/services/payment_service.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class SubscriptionController extends GetxController {
  final PaymentService paymentService = PaymentService();
  StreamSubscription<User?>? _authSubscription;
  
  // Состояние загрузки
  final RxBool isLoading = false.obs;
  
  // Список карт пользователя
  final RxList<PaymentCard> userCards = <PaymentCard>[].obs;
  
  // Выбранная карта
  final Rx<PaymentCard?> selectedCard = Rx<PaymentCard?>(null);

  final RxBool hasSavedCards = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Слушаем изменения состояния авторизации
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Пользователь вышел из системы, очищаем данные
        userCards.value = [];
        hasSavedCards.value = false;
        selectedCard.value = null;
      } else {
        // Пользователь вошел в систему, загружаем карты
        loadUserCards();
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  // Загрузка карт пользователя
  void loadUserCards() {
    // Проверяем авторизацию перед загрузкой
    if (!paymentService.isAuthenticated) {
      print('User not authenticated, skipping card loading');
      userCards.value = [];
      hasSavedCards.value = false;
      selectedCard.value = null;
      return;
    }
    
    paymentService.getUserCards().listen(
      (cards) {
        userCards.value = cards;
        hasSavedCards.value = cards.isNotEmpty;
        
        // Если есть карты и нет выбранной, выбираем первую
        if (cards.isNotEmpty && selectedCard.value == null) {
          selectedCard.value = cards.first;
        }
        // Если карт нет, сбрасываем выбранную карту
        else if (cards.isEmpty) {
          selectedCard.value = null;
        }
      },
      onError: (error) {
        print('Error loading user cards: $error');
        // При ошибке очищаем данные
        userCards.value = [];
        hasSavedCards.value = false;
        selectedCard.value = null;
      },
    );
  }

  // Получение последних 4 цифр выбранной карты
  String get selectedCardLastDigits => selectedCard.value?.lastFourDigits ?? '';

  // Получение имени владельца выбранной карты
  String get selectedCardholderName => selectedCard.value?.cardholderName ?? '';

  // Получение срока действия выбранной карты
  String get selectedCardExpiry => selectedCard.value != null 
      ? '${selectedCard.value!.expiryMonth}/${selectedCard.value!.expiryYear}'
      : '';

  // Установка карты по умолчанию
  Future<void> setDefaultCard(String cardId) async {
    try {
      isLoading.value = true;
      await paymentService.setDefaultCard(cardId);
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось установить карту по умолчанию',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Удаление карты
  Future<void> deleteCard(String cardId) async {
    try {
      isLoading.value = true;
      await paymentService.deleteCard(cardId);
      // Если удалили выбранную карту, выбираем первую из оставшихся
      if (selectedCard.value?.id == cardId) {
        selectedCard.value = userCards.firstWhereOrNull((card) => card.id != cardId);
      }
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось удалить карту',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Выбор карты
  void selectCard(PaymentCard card) {
    selectedCard.value = card;
  }

  // Проверка валидности срока действия карты
  bool isCardExpired(PaymentCard card) {
    final now = DateTime.now();
    final year = int.parse('20${card.expiryYear}');
    final month = int.parse(card.expiryMonth);
    final expiryDate = DateTime(year, month + 1, 0); // последний день месяца
    return now.isAfter(expiryDate);
  }

  // Получение списка неистекших карт
  List<PaymentCard> get validCards => userCards.where((card) => !isCardExpired(card)).toList();

  // Проверка наличия валидных карт
  bool get hasValidCards => validCards.isNotEmpty;
} 