import 'package:doloooki/mobile/features/subscription_feature/models/payment_card.dart';
import 'package:doloooki/mobile/features/subscription_feature/models/subscription_model.dart';
import 'package:doloooki/mobile/features/subscription_feature/services/payment_service.dart';
import 'package:doloooki/mobile/features/subscription_feature/services/subscription_service.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:async';

class SubscriptionController extends GetxController {
  final PaymentService paymentService = PaymentService();
  final SubscriptionService subscriptionService = SubscriptionService();
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<SubscriptionModel>>? _expiringSubscriptionsSubscription;
  
  // Состояние загрузки
  final RxBool isLoading = false.obs;
  
  // Список карт пользователя
  final RxList<PaymentCard> userCards = <PaymentCard>[].obs;
  
  // Выбранная карта
  final Rx<PaymentCard?> selectedCard = Rx<PaymentCard?>(null);

  final RxBool hasSavedCards = false.obs;

  // Подписка
  final Rx<SubscriptionModel?> currentSubscription = Rx<SubscriptionModel?>(null);
  final RxBool needsSubscription = false.obs;
  final RxBool hasUsedTrial = false.obs;

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
        currentSubscription.value = null;
        needsSubscription.value = false;
        hasUsedTrial.value = false;
      } else {
        // Пользователь вошел в систему, загружаем данные
        loadUserData();
      }
    });

    // Слушаем подписки, которые истекают
    _expiringSubscriptionsSubscription = subscriptionService
        .getExpiringSubscriptions()
        .listen((expiringSubscriptions) {
      for (final subscription in expiringSubscriptions) {
        subscriptionService.createExpirationNotification(
          subscription.userId, 
          subscription
        );
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    _expiringSubscriptionsSubscription?.cancel();
    super.onClose();
  }

  // Загрузка данных пользователя
  Future<void> loadUserData() async {
    loadUserCards();
    await loadSubscriptionData();
  }

  // Загрузка данных подписки
  Future<void> loadSubscriptionData() async {
    try {
      final subscription = await subscriptionService.getCurrentSubscription();
      currentSubscription.value = subscription;
      
      final trialUsed = await subscriptionService.hasUsedTrial();
      hasUsedTrial.value = trialUsed;
      
      final needsSub = await subscriptionService.needsSubscription();
      needsSubscription.value = needsSub;
      
      // Если нужна подписка, показываем окно подписки
      if (needsSub) {
        showSubscriptionDialog();
      }
    } catch (e) {
      print('Error loading subscription data: $e');
    }
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

  // Показать диалог подписки
  void showSubscriptionDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Запрещаем закрытие по кнопке назад
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.sp),
            padding: EdgeInsets.all(20.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.amber,
                  size: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Попробуйте премиум функции',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Получите доступ ко всем функциям приложения на 7 дней бесплатно',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.sp),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          startTrialPeriod();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Начать пробный период'),
                      ),
                    ),
                    SizedBox(width: 12.sp),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed('/subscription');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text('Купить подписку'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  // Начать пробный период
  Future<void> startTrialPeriod() async {
    try {
      isLoading.value = true;
      await subscriptionService.startTrialPeriod();
      await loadSubscriptionData();
      Get.snackbar(
        'Успех',
        'Пробный период активирован на 7 дней',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось активировать пробный период',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Покупка месячной подписки
  Future<void> purchaseMonthlySubscription() async {
    try {
      isLoading.value = true;
      await subscriptionService.purchaseMonthlySubscription();
      await loadSubscriptionData();
      Get.snackbar(
        'Успех',
        'Подписка оформлена на 30 дней',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось оформить подписку',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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

  // Проверка, активна ли подписка
  bool get isSubscriptionActive => currentSubscription.value?.isSubscriptionActive ?? false;

  // Получение оставшихся дней подписки
  int get remainingDays => currentSubscription.value?.remainingDays ?? 0;
} 