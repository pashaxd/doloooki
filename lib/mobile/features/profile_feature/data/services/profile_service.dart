import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/core/presentation/ondoarding/screens/onboarding_screen.dart';

class ProfileService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  Future<Map<String, dynamic>?> fetchProfile() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _firestore.collection('users').doc(user.uid).get();
    return doc.data();
  }

  Future<void> updateProfile(Map<String, dynamic> data) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).update(data);
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<File?> pickImageFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 30,
    );
    return image != null ? File(image.path) : null;
  }

  Future<File?> pickImageFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 30,
    );
    return image != null ? File(image.path) : null;
  }

  Future<String?> uploadImage(File image) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'profile_$timestamp.jpg';
      final fileRef = _storage.ref().child('users').child(user.uid).child(fileName);
      final metadata = SettableMetadata(
        contentType: 'image/jpeg',
        customMetadata: {
          'userId': user.uid,
          'uploadedAt': timestamp,
        },
      );
      final bytes = await image.readAsBytes();
      final uploadTask = await fileRef.putData(bytes, metadata);
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Ошибка при загрузке изображения: $e');
      return null;
    }
  }

  Future<bool> checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    try {
      // Показываем диалог подтверждения
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Удаление аккаунта',
            style: TextStyles.titleLarge.copyWith(color: Palette.white100),
          ),
          content: Text(
            'Вы действительно хотите удалить свой аккаунт? Все ваши данные будут безвозвратно утеряны.',
            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Отмена',
                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.error,
                foregroundColor: Palette.white100,
              ),
              child: Text(
                'Удалить навсегда',
                style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      
      if (confirmed != true) return;
      
      await _performAccountDeletion();
      
    } catch (e) {
      print('Ошибка при удалении аккаунта: $e');
      
      // Если требуется повторная аутентификация
      if (e.toString().contains('requires-recent-login')) {
        final reauth = await _handleReauthentication();
        if (reauth) {
          try {
            await _performAccountDeletion();
          } catch (e2) {
            Get.snackbar(
              'Ошибка',
              'Не удалось удалить аккаунт: ${e2.toString()}',
              backgroundColor: Palette.error,
              colorText: Palette.white100,
            );
          }
        }
      } else {
        Get.snackbar(
          'Ошибка',
          'Произошла ошибка при удалении аккаунта: ${e.toString()}',
          backgroundColor: Palette.error,
          colorText: Palette.white100,
        );
      }
    }
  }

  Future<void> _performAccountDeletion() async {
    final user = _auth.currentUser;
    if (user == null) return;
    
    final userId = user.uid;
    final userDocRef = _firestore.collection('users').doc(userId);
    
    // 1. Удаляем все подколлекции
    await _deleteSubcollection(userDocRef, 'cards');
    await _deleteSubcollection(userDocRef, 'notifications');
    await _deleteSubcollection(userDocRef, 'patterns');
    await _deleteSubcollection(userDocRef, 'wardrobe');
    
    // 2. Удаляем все файлы из Storage
    await _deleteUserStorage(userId);
    
    // 3. Удаляем основной документ пользователя
    await userDocRef.delete();
    
    // 4. Удаляем аккаунт Firebase
    await user.delete();
    
    // 5. Очищаем контроллеры и переходим на онбординг
    Get.deleteAll();
    Get.offAll(OnboardingScreen());
  }

  Future<bool> _handleReauthentication() async {
    final user = _auth.currentUser;
    if (user == null) return false;
    
    try {
      // Находим провайдер телефона
      final phoneProvider = user.providerData.firstWhere(
        (provider) => provider.providerId == 'phone',
        orElse: () => throw Exception('Phone provider not found'),
      );
      
      final phoneNumber = phoneProvider.phoneNumber!;
      
      // Показываем диалог с информацией о повторной аутентификации
      final shouldProceed = await Get.dialog<bool>(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'Подтверждение безопасности',
            style: TextStyles.titleLarge.copyWith(color: Palette.white100),
          ),
          content: Text(
            'Для удаления аккаунта необходимо подтвердить ваш номер телефона: $phoneNumber\n\nМы отправим SMS с кодом подтверждения.',
            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text(
                'Отмена',
                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
              ),
            ),
            ElevatedButton(
              onPressed: () => Get.back(result: true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.red100,
                foregroundColor: Palette.white100,
              ),
              child: Text(
                'Отправить код',
                style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
              ),
            ),
          ],
        ),
        barrierDismissible: false,
      );
      
      if (shouldProceed != true) return false;
      
      // Отправляем SMS код
      bool authSuccess = false;
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await user.reauthenticateWithCredential(credential);
            authSuccess = true;
            Get.snackbar(
              'Успех',
              'Аутентификация прошла успешно',
              backgroundColor: Palette.success,
              colorText: Palette.white100,
            );
          } catch (e) {
            print('Ошибка автоматической аутентификации: $e');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          Get.snackbar(
            'Ошибка',
            'Не удалось отправить код: ${e.message}',
            backgroundColor: Palette.error,
            colorText: Palette.white100,
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _showSMSCodeDialog(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          print('Время ожидания истекло');
        },
      );
      
      return authSuccess;
      
    } catch (e) {
      print('Ошибка при повторной аутентификации: $e');
      return false;
    }
  }

  void _showSMSCodeDialog(String verificationId) {
    final codeController = TextEditingController();
    
    Get.dialog(
      AlertDialog(
        backgroundColor: Palette.red400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Введите код из SMS',
          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Введите 6-значный код, отправленный на ваш номер телефона',
              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            ),
            SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
              decoration: InputDecoration(
                hintText: '000000',
                hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                filled: true,
                fillColor: Palette.red500,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                counterText: '',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Отмена',
              style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final credential = PhoneAuthProvider.credential(
                  verificationId: verificationId,
                  smsCode: codeController.text.trim(),
                );
                
                await _auth.currentUser?.reauthenticateWithCredential(credential);
                Get.back(); // Закрываем диалог
                
                Get.snackbar(
                  'Успех',
                  'Аутентификация прошла успешно. Удаляем аккаунт...',
                  backgroundColor: Palette.success,
                  colorText: Palette.white100,
                );
                
                // Пытаемся удалить аккаунт снова
                await _performAccountDeletion();
                
              } catch (e) {
                Get.snackbar(
                  'Ошибка',
                  'Неверный код. Попробуйте еще раз.',
                  backgroundColor: Palette.error,
                  colorText: Palette.white100,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Palette.red100,
              foregroundColor: Palette.white100,
            ),
            child: Text(
              'Подтвердить',
              style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  // Вспомогательный метод для удаления подколлекции
  Future<void> _deleteSubcollection(DocumentReference docRef, String subcollectionName) async {
    try {
      final subcollectionRef = docRef.collection(subcollectionName);
      final snapshot = await subcollectionRef.get();
      
      // Удаляем все документы в подколлекции батчами (максимум 500 операций за раз)
      final batches = <WriteBatch>[];
      var currentBatch = _firestore.batch();
      var operationCount = 0;
      
      for (var doc in snapshot.docs) {
        currentBatch.delete(doc.reference);
        operationCount++;
        
        if (operationCount >= 500) {
          batches.add(currentBatch);
          currentBatch = _firestore.batch();
          operationCount = 0;
        }
      }
      
      if (operationCount > 0) {
        batches.add(currentBatch);
      }
      
      // Выполняем все батчи
      for (var batch in batches) {
        await batch.commit();
      }
      
      print('Подколлекция $subcollectionName удалена');
    } catch (e) {
      print('Ошибка при удалении подколлекции $subcollectionName: $e');
    }
  }
  
  // Вспомогательный метод для удаления файлов пользователя из Storage
  Future<void> _deleteUserStorage(String userId) async {
    try {
      final userStorageRef = _storage.ref().child('users').child(userId);
      
      // Получаем список всех файлов пользователя
      final listResult = await userStorageRef.listAll();
      
      // Удаляем все файлы
      for (var item in listResult.items) {
        try {
          await item.delete();
          print('Файл ${item.name} удален');
        } catch (e) {
          print('Ошибка при удалении файла ${item.name}: $e');
        }
      }
      
      // Рекурсивно удаляем файлы из подпапок
      for (var prefix in listResult.prefixes) {
        await _deleteStorageFolder(prefix);
      }
      
      print('Все файлы пользователя $userId удалены из Storage');
    } catch (e) {
      print('Ошибка при удалении файлов из Storage: $e');
    }
  }
  
  // Рекурсивный метод для удаления папок в Storage
  Future<void> _deleteStorageFolder(Reference folderRef) async {
    try {
      final listResult = await folderRef.listAll();
      
      // Удаляем все файлы в текущей папке
      for (var item in listResult.items) {
        try {
          await item.delete();
        } catch (e) {
          print('Ошибка при удалении файла ${item.name}: $e');
        }
      }
      
      // Рекурсивно удаляем подпапки
      for (var prefix in listResult.prefixes) {
        await _deleteStorageFolder(prefix);
      }
    } catch (e) {
      print('Ошибка при удалении папки ${folderRef.fullPath}: $e');
    }
  }
}