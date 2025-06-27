import 'package:doloooki/web/features/auth_feature/screens/creating_profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/web/features/auth_feature/screens/checking_info_screen.dart';
import 'package:doloooki/web/features/auth_feature/screens/password_reset_success_screen.dart';

class AuthController extends GetxController {
    final emailController = TextEditingController().obs;
  final passwordController = TextEditingController().obs;
  final confirmPasswordController = TextEditingController().obs;
  
  // Firebase instances - используем веб-специфичные настройки
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Реактивные переменные для валидации
  final isEmailValid = false.obs;
  final isPasswordValid = false.obs;
  final isConfirmPasswordValid = false.obs;
  final isButtonEnabled = false.obs;
  final isLoading = false.obs;
  
  // Переменная для управления видимостью пароля
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Настройка веб-специфичной персистентности
    _initializeWebAuth();
    
    // Слушаем изменения в полях
    emailController.value.addListener(_validateEmail);
    passwordController.value.addListener(_validatePassword);
    confirmPasswordController.value.addListener(_validateConfirmPassword);
  }

  Future<void> _initializeWebAuth() async {
    try {
      // Устанавливаем персистентность для веба
      await _auth.setPersistence(Persistence.LOCAL);
      print('Firebase Auth Web persistence initialized');
    } catch (e) {
      print('Error initializing web auth: $e');
    }
  }

  @override
  void onClose() {
    emailController.value.dispose();
    passwordController.value.dispose();
    confirmPasswordController.value.dispose();
    super.onClose();
  }

  void _validateEmail() {
    final email = emailController.value.text.trim();
    // Базовая проверка наличия @ и точки
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    isEmailValid.value = emailRegex.hasMatch(email);
  }

  void _validatePassword() {
    final password = passwordController.value.text;
    // Минимум 8 символов
    isPasswordValid.value = password.length >= 8;
    // Если есть текст в поле подтверждения, проверяем его тоже
    if (confirmPasswordController.value.text.isNotEmpty) {
      _validateConfirmPassword();
    }
  }

  void _validateConfirmPassword() {
    final password = passwordController.value.text;
    final confirmPassword = confirmPasswordController.value.text;
    // Пароли должны совпадать и не быть пустыми
    isConfirmPasswordValid.value = confirmPassword.isNotEmpty && password == confirmPassword;
  }

  void _updateButtonState() {
    isButtonEnabled.value = isEmailValid.value && isPasswordValid.value;
  }

  void _updateButtonStateForRegistration() {
    isButtonEnabled.value = isEmailValid.value && isPasswordValid.value && isConfirmPasswordValid.value;
  }

  void updateButtonState(bool isLogin) {
    if (isLogin) {
      _updateButtonState();
    } else {
      _updateButtonStateForRegistration();
    }
  }

  // Метод для переключения видимости пароля
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  // Метод для переключения видимости подтверждения пароля
  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> onLoginPressed() async {
    if (!isButtonEnabled.value || isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      final email = emailController.value.text.trim();
      final password = passwordController.value.text;
      
      print('Попытка веб-входа с email: $email');
      
      // Веб-специфичная авторизация через Firebase Auth
      // Убеждаемся что персистентность установлена
      await _auth.setPersistence(Persistence.LOCAL);
      
      // Авторизация через Firebase Auth (сохранит сессию автоматически)
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Успешная веб-авторизация: ${userCredential.user?.uid}');
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не найден после авторизации');
      }
      
      // Проверяем, есть ли стилист в коллекции stylists
      final stylistDoc = await _firestore
          .collection('stylists')
          .doc(currentUser.uid)
          .get();
      
      if (!stylistDoc.exists) {
        // Если стилист не найден в коллекции, создаем запись
        await _createStylistRecord(currentUser);
      }
      
      Get.snackbar(
        'Успех',
        'Добро пожаловать в веб-версию!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Переход на дашборд стилиста
      Get.offAll(() => CheckingInfoScreen());
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Произошла ошибка при веб-входе';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Пользователь с таким email не найден';
          break;
        case 'wrong-password':
          errorMessage = 'Неверный пароль';
          break;
        case 'invalid-email':
          errorMessage = 'Некорректный email адрес';
          break;
        case 'user-disabled':
          errorMessage = 'Аккаунт заблокирован';
          break;
        case 'too-many-requests':
          errorMessage = 'Слишком много попыток. Попробуйте позже';
          break;
        case 'network-request-failed':
          errorMessage = 'Ошибка сети. Проверьте подключение к интернету';
          break;
        case 'web-storage-unsupported':
          errorMessage = 'Ваш браузер не поддерживает веб-хранилище';
          break;
      }
      
      Get.snackbar(
        'Ошибка веб-входа',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Ошибка веб-авторизации: ${e.code} - ${e.message}');
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Произошла неожиданная ошибка в веб-версии',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Неожиданная ошибка веб-авторизации: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> onRegisterPressed() async {
    if (!isButtonEnabled.value || isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      final email = emailController.value.text.trim();
      final password = passwordController.value.text;
      
      print('Попытка веб-регистрации с email: $email');
      
      // Веб-специфичная регистрация через Firebase Auth
      // Убеждаемся что персистентность установлена
      await _auth.setPersistence(Persistence.LOCAL);
      
      // Регистрация пользователя
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      print('Успешная веб-регистрация: ${userCredential.user?.uid}');
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw Exception('Пользователь не найден после регистрации');
      }
      
      // Создаем запись в коллекции stylists
      await _createStylistRecord(currentUser);
      
      Get.snackbar(
        'Успех',
        'Аккаунт стилиста создан в веб-версии! Добро пожаловать!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
      // Переход на создание профиля
      Get.offAll(() => const CreatingProfileScreenWeb());
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Произошла ошибка при веб-регистрации';
      
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'Пароль слишком слабый';
          break;
        case 'email-already-in-use':
          errorMessage = 'Аккаунт с таким email уже существует';
          break;
        case 'invalid-email':
          errorMessage = 'Некорректный email адрес';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Регистрация отключена';
          break;
        case 'network-request-failed':
          errorMessage = 'Ошибка сети. Проверьте подключение к интернету';
          break;
        case 'web-storage-unsupported':
          errorMessage = 'Ваш браузер не поддерживает веб-хранилище';
          break;
      }
      
      Get.snackbar(
        'Ошибка веб-регистрации',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Ошибка веб-регистрации: ${e.code} - ${e.message}');
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Произошла неожиданная ошибка в веб-версии',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Неожиданная ошибка веб-регистрации: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createStylistRecord(User user) async {
    try {
      await _firestore.collection('stylists').doc(user.uid).set({
        'email': user.email,
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'isActive': true,
        'name': '', // Можно заполнить позже в профиле
        'surname': '', // Можно заполнить позже в профиле
        'phone': '', // Можно заполнить позже в профиле
        'experience': '', // Опыт работы
        'specialization': [], // Специализации
        'rating': 0.0, // Рейтинг
        'reviewsCount': 0, // Количество отзывов
        'profileImageUrl': '', // URL аватара
        'description': '', // Описание стилиста
        'platform': 'web', // Указываем что создано в веб-версии
      });
      
      print('Запись веб-стилиста создана в Firestore');
    } catch (e) {
      print('Ошибка создания записи веб-стилиста: $e');
      throw e;
    }
  }

  Future<void> signOut() async {
    try {
      // Веб-специфичный выход
      await _auth.signOut();
      print('Успешный выход из веб-версии');
      
      Get.snackbar(
        'Выход',
        'Вы успешно вышли из веб-версии',
        snackPosition: SnackPosition.TOP,
      );
      
      // Переход на страницу авторизации через именованный маршрут
      Get.offAllNamed('/auth');
    } catch (e) {
      print('Ошибка выхода из веб-версии: $e');
      Get.snackbar(
        'Ошибка',
        'Ошибка при выходе из аккаунта',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> onForgotPasswordPressed() async {
    if (!isEmailValid.value || isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      final email = emailController.value.text.trim();
      
      print('Попытка веб-восстановления пароля для email: $email');
      
      // Веб-специфичное восстановление пароля
      await _auth.sendPasswordResetEmail(email: email);
      
      print('Письмо для веб-восстановления отправлено');
      
      // Переход на экран успеха
      Get.off(() => PasswordResetSuccessScreen(email: email));
      
    } on FirebaseAuthException catch (e) {
      String errorMessage = 'Произошла ошибка при веб-восстановлении пароля';
      
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Пользователь с таким email не найден';
          break;
        case 'invalid-email':
          errorMessage = 'Некорректный email адрес';
          break;
        case 'too-many-requests':
          errorMessage = 'Слишком запросов. Попробуйте позже';
          break;
        case 'network-request-failed':
          errorMessage = 'Ошибка сети. Проверьте подключение к интернету';
          break;
      }
      
      Get.snackbar(
        'Ошибка веб-восстановления',
        errorMessage,
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Ошибка веб-восстановления пароля: ${e.code} - ${e.message}');
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Произошла неожиданная ошибка в веб-версии',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      
      print('Неожиданная ошибка веб-восстановления: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Метод для очистки всех полей при переключении между режимами
  void clearAllFields() {
    emailController.value.clear();
    passwordController.value.clear();
    confirmPasswordController.value.clear();
    
    isEmailValid.value = false;
    isPasswordValid.value = false;
    isConfirmPasswordValid.value = false;
    isButtonEnabled.value = false;
    
    isPasswordVisible.value = false;
    isConfirmPasswordVisible.value = false;
  }
}