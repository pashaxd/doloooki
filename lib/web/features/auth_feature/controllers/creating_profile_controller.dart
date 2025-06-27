import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doloooki/web/features/auth_feature/screens/checking_info_screen.dart';

class CreatingProfileController extends GetxController {
  final nameController = TextEditingController();
  final shortDescriptionController = TextEditingController();
  final descriptionController = TextEditingController();
  
  // Реактивные переменные
  final isNameValid = false.obs;
  final isShortDescriptionValid = false.obs;
  final isDescriptionValid = false.obs;
  final isPhotoSelected = false.obs;
  final isLoading = false.obs;
  final selectedImagePath = ''.obs;
  
  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Image picker
  final ImagePicker _picker = ImagePicker();
  XFile? selectedImage;

  @override
  void onInit() {
    super.onInit();
    nameController.addListener(_validateName);
    shortDescriptionController.addListener(_validateShortDescription);
    descriptionController.addListener(_validateDescription);
  }

  @override
  void onClose() {
    nameController.dispose();
    shortDescriptionController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  void _validateName() {
    isNameValid.value = nameController.text.trim().isNotEmpty;
  }

  void _validateShortDescription() {
    isShortDescriptionValid.value = shortDescriptionController.text.trim().isNotEmpty;
  }

  void _validateDescription() {
    isDescriptionValid.value = descriptionController.text.trim().isNotEmpty;
  }

  bool get isFormValid => isNameValid.value && 
                         isShortDescriptionValid.value && 
                         isDescriptionValid.value && 
                         isPhotoSelected.value;

  Future<void> selectPhoto() async {
    try {
      // Выбор изображения из галереи
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        selectedImage = image;
        selectedImagePath.value = image.path;
        isPhotoSelected.value = true;
        
        print('Выбрана фотография: ${image.path}');
      }
    } catch (e) {
      print('Ошибка выбора фотографии: $e');
    }
  }

  Future<String?> _uploadPhotoToStorage() async {
    if (selectedImage == null) return null;
    
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');
      
      // Создаем уникальное имя файла
      final fileName = 'stylist_photos/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Загружаем файл в Firebase Storage
      final ref = _storage.ref().child(fileName);
      
      // Для веба используем bytes
      final bytes = await selectedImage!.readAsBytes();
      final uploadTask = await ref.putData(bytes);
      
      // Получаем URL загруженного файла
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      print('Фото загружено в Storage: $downloadUrl');
      return downloadUrl;
      
    } catch (e) {
      print('Ошибка загрузки фото в Storage: $e');
      throw e;
    }
  }

  Future<void> onContinuePressed() async {
    if (!isFormValid || isLoading.value) return;
    
    try {
      isLoading.value = true;
      
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      print('Начинаем сохранение профиля для: ${user.uid}');
      
      // Загружаем фото в Storage
      String? photoUrl;
      if (selectedImage != null) {
        photoUrl = await _uploadPhotoToStorage();
      }
      
      // Обновляем данные стилиста в Firestore
      await _firestore.collection('stylists').doc(user.uid).update({
        'name': nameController.text.trim(),
        'shortDescription': shortDescriptionController.text.trim(),
        'description': descriptionController.text.trim(),
        'profileImage': photoUrl ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
        'profileCompleted': true,
        'isActive': false, 
      });
      
      print('Профиль стилиста отправлен на проверку');
      
      // Переход на экран проверки информации
      Get.offAll(() =>  CheckingInfoScreen());
      
    } catch (e) {
      print('Ошибка сохранения профиля: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void removePhoto() {
    selectedImage = null;
    selectedImagePath.value = '';
    isPhotoSelected.value = false;
  }
} 