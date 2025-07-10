import 'package:doloooki/mobile/features/profile_feature/presentations/controllers/notifications_controller.dart';
import 'package:doloooki/mobile/features/subscription_feature/screens/subscription.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/creating_profile.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/screens/sms.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/core/presentation/ondoarding/screens/bottom_navigation.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController phoneController = TextEditingController();
  final List<TextEditingController> codeControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final RxBool isButtonEnabled = false.obs;
  final RxBool isSmsButtonEnabled = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isSmsError = false.obs;
  final RxBool canResendSms = false.obs;
  final RxInt resendTimer = 60.obs;
  Timer? _resendTimer;
  Timer? _tokenRefreshTimer;

  String? verificationId;
  int? resendToken;

  @override
  void onInit() {
    super.onInit();
    print('AuthController инициализирован');
    phoneController.addListener(_onPhoneChanged);
    for (var controller in codeControllers) {
      controller.addListener(_onCodeChanged);
    }
    startResendTimer();
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }
  }

  bool isValidPhoneNumber(String phone) {
    // Убираем все нецифровые символы
    String cleanNumber = phone.replaceAll(RegExp(r'[^\d]'), '');
    
    // Проверяем длину (должно быть 11 цифр для российского номера)
    if (cleanNumber.length != 11) return false;
    
    // Проверяем, что номер начинается с 7 или 8
    if (!cleanNumber.startsWith('7') && !cleanNumber.startsWith('8')) return false;
    
    // Проверяем, что вторая цифра (код оператора) от 3 до 9
    int operatorCode = int.parse(cleanNumber.substring(1, 2));
    if (operatorCode < 3 || operatorCode > 9) return false;
    
    return true;
  }

  void _onPhoneChanged() {
    final text = phoneController.text;
    bool isValid = isValidPhoneNumber(text);
    isButtonEnabled.value = text.length == 16 && isValid;
    print('Номер телефона изменен: $text');
    print('Кнопка активна: ${isButtonEnabled.value}');
    print('Номер валидный: $isValid');
  }

  void _onCodeChanged() {
    final allFieldsFilled = codeControllers.every((controller) => 
      controller.text.isNotEmpty && int.tryParse(controller.text) != null);
    isSmsButtonEnabled.value = allFieldsFilled;
  }

  Future<void> onContinuePressed() async {
    if (isLoading.value) return;

    print('onContinuePressed вызван');
    try {
      isLoading.value = true;

      // Форматируем номер телефона
      String cleanNumber = phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanNumber.startsWith('8')) {
        cleanNumber = '7' + cleanNumber.substring(1);
      } else if (!cleanNumber.startsWith('7')) {
        cleanNumber = '7' + cleanNumber;
      }
      if (cleanNumber.length != 11) {
        Get.snackbar(
          'Ошибка',
          'Введите номер полностью в формате +7XXXXXXXXXX',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }
      final phoneNumber = '+$cleanNumber';

      // Проверяем валидность номера
      if (!isValidPhoneNumber(phoneController.text)) {
        Get.snackbar(
          'Ошибка',
          'Неверный формат номера телефона',
          snackPosition: SnackPosition.BOTTOM,
        );
        isLoading.value = false;
        return;
      }

      // Отправляем код подтверждения через Firebase
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          print('Верификация завершена автоматически');
          final userCredential = await _auth.signInWithCredential(credential);
          final user = userCredential.user;
          
          if (user != null) {
            // Проверяем профиль с задержкой и повторными попытками
            final shouldGoToProfileCreation = await _checkUserProfileWithRetry(user.uid);
            
            if (shouldGoToProfileCreation) {
              Get.offAll(() => CreatingProfileScreen());
              return;
            }
            
            // Если профиль существует и заполнен, переходим на главный экран
            Get.offAll(() => BottomNavigation());
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          print('Ошибка верификации: ${e.message}');
          Get.snackbar(
            'Ошибка',
            'Не удалось отправить код подтверждения. Попробуйте позже.',
            snackPosition: SnackPosition.BOTTOM,
          );
          isLoading.value = false;
        },
        codeSent: (String vId, int? resendToken) {
          print('Код отправлен. ID верификации: $vId');
          verificationId = vId;
          this.resendToken = resendToken;
          isLoading.value = false;
          Get.to(() => SmsScreen());
        },
        codeAutoRetrievalTimeout: (String vId) {
          print('Время ожидания кода истекло');
          verificationId = vId;
          isLoading.value = false;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken,
      );

    } catch (e) {
      print('Ошибка при вызове verifyPhoneNumber: $e');
      Get.snackbar(
        'Ошибка',
        'Произошла ошибка при отправке кода. Попробуйте позже.',
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
    }
  }

  Future<void> onSmsContinuePressed() async {
    if (!isSmsButtonEnabled.value || isLoading.value) return;

    try {
      isLoading.value = true;
      
      // Собираем код из всех полей
      String smsCode = codeControllers.map((controller) => controller.text).join();
      
      if (verificationId == null) {
        throw Exception('ID верификации не найден');
      }

      // Создаем учетные данные
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: smsCode,
      );

      // Проверяем код через Firebase
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      
      if (user != null) {
        // Проверяем профиль с задержкой и повторными попытками
        final shouldGoToProfileCreation = await _checkUserProfileWithRetry(user.uid);
        
        if (shouldGoToProfileCreation) {
          Get.offAll(() => CreatingProfileScreen());
          return;
        }
        
        // Если профиль существует и заполнен, переходим на главный экран
        Get.offAll(() => BottomNavigation());
      }
      
    } catch (e) {
      print('Ошибка при верификации SMS: $e');
      isSmsError.value = true;
     
    } finally {
      isLoading.value = false;
    }
  }

  // Проверка профиля пользователя с повторными попытками
  Future<bool> _checkUserProfileWithRetry(String userId) async {
    int retryCount = 0;
    const maxRetries = 3;
    
    // Ждем 500мс для синхронизации Firebase Auth токена с Firestore
    await Future.delayed(Duration(milliseconds: 500));
    
    while (retryCount < maxRetries) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
            
        // Если профиль не существует
        if (!userDoc.exists) {
          print('📝 Профиль пользователя не найден, перенаправляем на создание профиля');
          return true; // Нужно создать профиль
        }
        
        final userData = userDoc.data() as Map<String, dynamic>?;
        if (userData == null ||
            userData['name'] == null ||
            userData['surname'] == null ||
            userData['name'].toString().trim().isEmpty ||
            userData['surname'].toString().trim().isEmpty) {
          print('📝 Профиль пользователя неполный, перенаправляем на создание профиля');
          return true; // Нужно дополнить профиль
        }
        
        print('✅ Профиль пользователя найден и заполнен');
        return false; // Профиль OK, переходим на главный экран
        
      } catch (e) {
        retryCount++;
        print('⚠️ Попытка $retryCount проверки профиля не удалась: $e');
        
        if (e.toString().contains('permission-denied') && retryCount < maxRetries) {
          // Ждем перед повторной попыткой (экспоненциальная задержка)
          await Future.delayed(Duration(milliseconds: 1000 * retryCount));
        } else {
          // Если это не ошибка разрешений или достигнуто максимальное количество попыток
          print('❌ Не удалось проверить профиль после $maxRetries попыток, предполагаем что профиль нужно создать');
          return true; // В случае ошибки лучше показать создание профиля
        }
      }
    }
    
    return true; // Если все попытки неудачны, показываем создание профиля
  }

  void startResendTimer() {
    canResendSms.value = false;
    resendTimer.value = 60;
    _resendTimer?.cancel();
    
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (resendTimer.value > 0) {
        resendTimer.value--;
      } else {
        canResendSms.value = true;
        timer.cancel();
      }
    });
  }

  void resetVerificationState() {
    for (var controller in codeControllers) {
      controller.clear();
    }
    isLoading.value = false;
    isButtonEnabled.value = phoneController.text.length == 16 && isValidPhoneNumber(phoneController.text);
    startResendTimer();
  }

  void resendSms() {
    if (canResendSms.value) {
      onContinuePressed();
      startResendTimer();
    }
  }

  @override
  void onClose() {
    for (var controller in codeControllers) {
      controller.clear();
    }
    phoneController.dispose();
    for (var controller in codeControllers) {
      controller.dispose();
    }
    _resendTimer?.cancel();
    _tokenRefreshTimer?.cancel();
    super.onClose();
  }
}