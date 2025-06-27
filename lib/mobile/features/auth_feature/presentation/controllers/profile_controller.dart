import 'dart:io';
import 'dart:async';
import 'dart:io' show InternetAddress, SocketException;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/subscription_feature/screens/subscription.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doloooki/mobile/features/auth_feature/presentation/controllers/auth_controller.dart';

class CreatingProfileController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController secondNameController = TextEditingController();
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Добавляем FocusNode и RxBool для фокуса
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode surnameFocusNode = FocusNode();
  final FocusNode secondNameFocusNode = FocusNode();

  final RxBool isNameFocused = false.obs;
  final RxBool isSurnameFocused = false.obs;
  final RxBool isSecondNameFocused = false.obs;

  // Добавляем RxBool для отслеживания состояния кнопки
  final RxBool isButtonEnabled = false.obs;

  RxString phone = ''.obs;

  void setFocus(String field) {
    isNameFocused.value = field == 'name';
    isSurnameFocused.value = field == 'surname';
    isSecondNameFocused.value = field == 'secondName';
  }

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_validateFields);
    surnameController.addListener(_validateFields);
    secondNameController.addListener(_validateFields);
    // Добавляем слушатели для FocusNode
    nameFocusNode.addListener(() {
      isNameFocused.value = nameFocusNode.hasFocus;
    });
    surnameFocusNode.addListener(() {
      isSurnameFocused.value = surnameFocusNode.hasFocus;
    });
    secondNameFocusNode.addListener(() {
      isSecondNameFocused.value = secondNameFocusNode.hasFocus;
    });
    // Копируем номер телефона из AuthController, если есть
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      if (authController.phoneController.text.isNotEmpty) {
        phone.value = authController.phoneController.text;
      }
    }
  }

  // Метод для проверки заполнения полей
  void _validateFields() {
    isButtonEnabled.value = nameController.text.isNotEmpty && 
                          surnameController.text.isNotEmpty;
  }

  Future<bool> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 30,
      );
      
      if (image != null) {
        profileImage.value = File(image.path);
        // Выводим размер файла для проверки
        final fileSize = await profileImage.value!.length();
        print('Размер файла: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }
    } catch (e) {
      print('Ошибка при выборе изображения: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось выбрать изображение',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 400,
        maxHeight: 400,
        imageQuality: 30,
      );
      
      if (image != null) {
        profileImage.value = File(image.path);
        // Выводим размер файла для проверки
        final fileSize = await profileImage.value!.length();
        print('Размер файла: ${(fileSize / 1024).toStringAsFixed(2)} KB');
      }
    } catch (e) {
      print('Ошибка при съемке фото: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось сделать фото',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<String?> uploadImage() async {
    if (profileImage.value == null) return null;
    
    try {
      // Проверяем подключение к интернету
      final hasInternet = await _checkInternetConnection();
      if (!hasInternet) {
        throw Exception('Нет подключения к интернету');
      }

      final String userId = _auth.currentUser?.uid ?? '';
      if (userId.isEmpty) {
        throw Exception('Пользователь не авторизован');
      }

      // Проверяем токен авторизации
      final token = await _auth.currentUser?.getIdToken();
      if (token == null) {
        throw Exception('Токен авторизации не получен');
      }
      print('Токен авторизации получен');

      // Создаем уникальное имя файла
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'profile_$timestamp.jpg';
      
      print('Попытка загрузки изображения с именем: $fileName');
      
      // Создаем ссылку на файл
      final fileRef = _storage.ref().child('users').child(userId).child(fileName);
      
      print('Создана ссылка на файл: ${fileRef.fullPath}');
      
      // Загружаем файл с метаданными
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': userId,
          'uploadedAt': timestamp,
        },
      );
      
      print('Начало загрузки файла...');
      
      // Загружаем файл с повторными попытками
      int attempts = 0;
      const maxAttempts = 3;
      
      while (attempts < maxAttempts) {
        try {
          // Проверяем подключение перед каждой попыткой
          final hasInternet = await _checkInternetConnection();
          if (!hasInternet) {
            throw Exception('Нет подключения к интернету');
          }

          // Читаем файл в байты и загружаем
          final bytes = await profileImage.value!.readAsBytes();
          final uploadTask = await fileRef.putData(bytes, metadata);

          print('Загрузка файла завершена, получение URL...');
          
          // Получаем URL для скачивания
          final downloadUrl = await uploadTask.ref.getDownloadURL();
          print('Изображение успешно загружено. URL: $downloadUrl');
          
          return downloadUrl;
        } catch (e) {
          attempts++;
          print('Попытка $attempts из $maxAttempts не удалась: $e');
          
          if (attempts == maxAttempts) {
            rethrow;
          }
          
          // Ждем перед следующей попыткой
          await Future.delayed(Duration(seconds: attempts * 2));
        }
      }
      
      return null;
    } catch (e) {
      print('Ошибка при загрузке изображения: $e');
      if (e is FirebaseException) {
        print('Код ошибки Firebase: ${e.code}');
        print('Сообщение об ошибке Firebase: ${e.message}');
        print('Детали ошибки Firebase: ${e.toString()}');
        print('Stack trace: ${e.stackTrace}');
      }
      
      String errorMessage = 'Не удалось загрузить изображение. ';
      if (e.toString().contains('permission-denied')) {
        errorMessage += 'Нет прав доступа к хранилищу. Проверьте правила доступа Firebase Storage.';
      } else if (e.toString().contains('object-not-found')) {
        errorMessage += 'Ошибка доступа к хранилищу. Проверьте настройки Firebase Storage.';
      } else if (e.toString().contains('not initialized')) {
        errorMessage += 'Ошибка инициализации Firebase Storage.';
      } else if (e.toString().contains('Could not connect') || e.toString().contains('-1004')) {
        errorMessage += 'Ошибка подключения к серверу. Проверьте подключение к интернету и настройки Firebase.';
      } else if (e.toString().contains('Нет подключения к интернету')) {
        errorMessage += 'Отсутствует подключение к интернету. Проверьте ваше сетевое подключение.';
      } else if (e.toString().contains('Токен авторизации не получен')) {
        errorMessage += 'Ошибка авторизации. Попробуйте выйти и войти снова.';
      } else {
        errorMessage += 'Проверьте подключение к интернету.';
      }
      
      Get.snackbar(
        'Ошибка',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      return null;
    }
  }

  Future<void> saveProfile() async {
    if (!isButtonEnabled.value || isLoading.value) return;

    try {
      isLoading.value = true;
      
      // Проверяем авторизацию
      final user = _auth.currentUser;
      if (user == null) {
        Get.snackbar(
          'Ошибка',
          'Необходимо войти в аккаунт',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Проверяем обязательные поля
      if (nameController.text.isEmpty || surnameController.text.isEmpty) {
        Get.snackbar(
          'Ошибка',
          'Имя и фамилия обязательны для заполнения',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      final String? imageUrl = await uploadImage();
      
      // Сохраняем данные в Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'name': nameController.text,
        'surname': surnameController.text,
        'secondName': secondNameController.text,
        'profileImage': imageUrl,
        'phone': phone.value,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Успех',
        'Профиль успешно сохранен',
        snackPosition: SnackPosition.BOTTOM,
      );
      
       await Get.offAll(SubscriptionScreen());
      
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось сохранить профиль. Проверьте подключение к интернету.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    nameController.removeListener(_validateFields);
    surnameController.removeListener(_validateFields);
    secondNameController.removeListener(_validateFields);
    nameController.dispose();
    surnameController.dispose();
    secondNameController.dispose();
    // Освобождаем FocusNode
    nameFocusNode.dispose();
    surnameFocusNode.dispose();
    secondNameFocusNode.dispose();
    super.onClose();
  }
} 