import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doloooki/web/core/presentation/left_navigation/controllers/left_navigation_controller.dart';

class SettingsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final TextEditingController nameController = TextEditingController();
  final TextEditingController surnameController = TextEditingController();
  final TextEditingController patronymicController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController shortDescriptionController = TextEditingController();
  
  final RxBool isLoading = true.obs;
  final RxString photoUrl = ''.obs;
  final RxString error = ''.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadStylistData();
  }
  
  @override
  void onClose() {
    nameController.dispose();
    surnameController.dispose();
    patronymicController.dispose();
    emailController.dispose();
    descriptionController.dispose();
    shortDescriptionController.dispose();
    super.onClose();
  }
  
  Future<void> loadStylistData() async {
    try {
      isLoading.value = true;
      error.value = '';
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        error.value = 'Пользователь не авторизован';
        return;
      }
      
      print('🔍 Загружаем данные стилиста: ${currentUser.uid}');
      
      // Получаем данные стилиста из коллекции stylists
      final stylistDoc = await _firestore
          .collection('stylists')
          .doc(currentUser.uid)
          .get();
      
      if (stylistDoc.exists) {
        final data = stylistDoc.data() as Map<String, dynamic>;
        
        // Заполняем контроллеры реальными данными
        nameController.text = data['name'] ?? '';
        surnameController.text = data['surname'] ?? '';
        patronymicController.text = data['patronymic'] ?? data['secondName'] ?? '';
        emailController.text = currentUser.email ?? '';
        descriptionController.text = data['description'] ?? '';
        shortDescriptionController.text = data['shortDescription'] ?? '';
        photoUrl.value = data['profileImage'] ?? data['profileImageUrl'] ?? '';
        
        print('✅ Данные стилиста загружены: ${data['name']} ${data['surname']}');
        
        // Обновляем данные в левой навигации
        try {
          final leftNavController = Get.find<LeftNavigationController>();
          leftNavController.refreshStylistData();
        } catch (e) {
          // Если контроллер не найден, это не критично
          print('LeftNavigationController not found: $e');
        }
      } else {
        print('⚠️ Документ стилиста не найден, создаем базовую запись');
        
        // Если документ не существует, создаем его с базовыми данными
        await _createStylistRecord();
      }
      
    } catch (e) {
      error.value = 'Ошибка загрузки данных: $e';
      print('❌ Ошибка загрузки данных стилиста: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> _createStylistRecord() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return;
      
      final basicData = {
        'name': '',
        'surname': '',
        'patronymic': '',
        'email': currentUser.email ?? '',
        'description': '',
        'shortDescription': '',
        'profileImage': '',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await _firestore
          .collection('stylists')
          .doc(currentUser.uid)
          .set(basicData);
      
      // Обновляем UI
      emailController.text = currentUser.email ?? '';
      
      print('✅ Базовая запись стилиста создана');
    } catch (e) {
      print('❌ Ошибка создания записи стилиста: $e');
    }
  }
  
  Future<void> updateProfilePhoto() async {
    try {
      // Показываем диалог выбора источника фото
      final result = await Get.dialog<String>(
        AlertDialog(
          backgroundColor: Palette.red500,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Обновить фото профиля',
            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
          ),
          content: Text(
            'Выберите изображение для обновления фото профиля',
            style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
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
              onPressed: () => Get.back(result: 'gallery'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.red100,
                foregroundColor: Palette.white100,
              ),
              child: Text(
                'Выбрать фото',
                style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
              ),
            ),
          ],
        ),
      );

      if (result == 'gallery') {
        await _pickAndUploadImage();
      }
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось обновить фото: $e',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
        duration: Duration(seconds: 3),
      );
      
      print('❌ Ошибка обновления фото: $e');
    }
  }

  Future<void> _pickAndUploadImage() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        Get.snackbar(
          'Ошибка',
          'Пользователь не авторизован',
          backgroundColor: Palette.error,
          colorText: Palette.white100,
        );
        return;
      }

      // Выбираем изображение
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image == null) return;

      // Показываем загрузку
      Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red500,
          content: Container(
            height: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Palette.white100),
                SizedBox(height: 16),
                Text(
                  'Загрузка фото...',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );

      // Получаем байты изображения
      final bytes = await image.readAsBytes();

      // Создаем ссылку на Firebase Storage
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('stylists')
          .child('profile_images')
          .child('${currentUser.uid}.jpg');

      // Загружаем изображение
      final uploadTask = storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      // Ждем завершения загрузки
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Обновляем документ стилиста в Firestore
      await _firestore
          .collection('stylists')
          .doc(currentUser.uid)
          .update({
        'profileImage': downloadUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Обновляем локальное состояние
      photoUrl.value = downloadUrl;

      // Закрываем диалог загрузки
      Get.back();

      // Показываем успешное сообщение
      Get.snackbar(
        'Успех',
        'Фото профиля обновлено',
        backgroundColor: Palette.success,
        colorText: Palette.white100,
        duration: Duration(seconds: 2),
      );

      // Обновляем данные в левой навигации
      try {
        final leftNavController = Get.find<LeftNavigationController>();
        leftNavController.refreshStylistData();
      } catch (e) {
        // Если контроллер не найден, это не критично
        print('LeftNavigationController not found: $e');
      }

      print('✅ Фото профиля обновлено: $downloadUrl');

    } catch (e) {
      // Закрываем диалог загрузки если он открыт
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить фото: $e',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
        duration: Duration(seconds: 3),
      );

      print('❌ Ошибка загрузки фото: $e');
    }
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SettingsController());
    
    return Container(
      
      color: Colors.transparent,
      padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
      child: Obx(() {
        if (controller.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Palette.white100),
          );
        }
        
        if (controller.error.value.isNotEmpty) {
          return Center(
            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Palette.error, size: 48),
                SizedBox(height: 16),
                Text(
                  controller.error.value,
                  style: TextStyles.bodyMedium.copyWith(color: Palette.error),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => controller.loadStylistData(),
                  child: Text('Повторить'),
                ),
              ],
            ),
          );
        }
        
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Заголовок
              Text(
                'Данные аккаунта',
                style: TextStyles.headlineSmall.copyWith(color: Palette.white100),
              ),
              SizedBox(height: ResponsiveUtils.containerSize(8.h)),
              Text(
                'Здесь вы можете просмотреть данные о своем аккаунте',
                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
              ),
              
              SizedBox(height: ResponsiveUtils.containerSize(32.h)),
              
              // Центрируем и ограничиваем ширину контейнера
              Expanded(
                child:  Container(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.5, // Половина ширины экрана
                      maxHeight: MediaQuery.of(context).size.height * 0.8, // 80% высоты экрана
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Фотография:',
                            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                          ),
                          SizedBox(height: ResponsiveUtils.containerSize(12.h)),
                          
                          // Фото профиля
                          Container(
                            width: ResponsiveUtils.containerSize(100.w),
                            height: ResponsiveUtils.containerSize(100.w), // Делаем квадратным
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                              color: Palette.red500,
                            ),
                            child: Stack(
                              children: [
                                // Основное изображение
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
                                  child: Container(
                                    width: double.infinity,
                                    height: double.infinity,
                                    color: Palette.grey350,
                                    child: controller.photoUrl.value.isNotEmpty
                                        ? Image.network(
                                            controller.photoUrl.value,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Icon(
                                                Icons.person,
                                                color: Palette.white100,
                                                size: ResponsiveUtils.containerSize(48.sp),
                                              );
                                            },
                                          )
                                        : Icon(
                                            Icons.person,
                                            color: Palette.white100,
                                            size: ResponsiveUtils.containerSize(48.sp),
                                          ),
                                  ),
                                ),
                                
                                // Кнопка редактирования всегда видна
                                Positioned(
                                  bottom: ResponsiveUtils.containerSize(5.h),
                                  right: ResponsiveUtils.containerSize(5.w),
                                  child: GestureDetector(
                                    onTap: () => controller.updateProfilePhoto(),
                                    child: Container(
                                      width: ResponsiveUtils.containerSize(30.w),
                                      height: ResponsiveUtils.containerSize(30.w), // Делаем квадратной
                                      decoration: BoxDecoration(
                                        color: Palette.red100,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.edit,
                                        color: Palette.white100,
                                        size: ResponsiveUtils.containerSize(18.sp),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          SizedBox(height: ResponsiveUtils.containerSize(24.h)),
                          
                          // Основной контейнер с данными
                          Container(
                            padding: EdgeInsets.all(ResponsiveUtils.containerSize(20.sp)),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(20.r)),
                              border: Border.all(color: Palette.grey350, width: 1),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Поля с данными в одну колонку
                                Column(
                                  children: [
                                    // Имя
                                    _buildDataField(
                                      label: 'Имя',
                                      controller: controller.nameController,
                                      isEditing: false,
                                    ),
                                    
                                    SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                                    
                                    // Фамилия
                                    _buildDataField(
                                      label: 'Фамилия',
                                      controller: controller.surnameController,
                                      isEditing: false,
                                    ),
                                    
                                    SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                                    
                                    // Отчество
                                    _buildDataField(
                                      label: 'Отчество',
                                      controller: controller.patronymicController,
                                      isEditing: false,
                                    ),
                                    
                                    SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                                    
                                    // E-mail
                                    _buildDataField(
                                      label: 'E-mail',
                                      controller: controller.emailController,
                                      isEditing: false, // Email нельзя редактировать
                                      keyboardType: TextInputType.emailAddress,
                                    ),
                                    
                                    SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                                    
                                    // Краткое описание специализации
                                    _buildDataField(
                                      label: 'Специализация',
                                      controller: controller.shortDescriptionController,
                                      isEditing: false,
                                      maxLines: 2,
                                    ),
                                    
                                    SizedBox(height: ResponsiveUtils.containerSize(16.h)),
                                    
                                    // Полное описание
                                    _buildDataField(
                                      label: 'Описание',
                                      controller: controller.descriptionController,
                                      isEditing: false,
                                      maxLines: 4,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              
            ],
          );
        
      }),
    );
  }
  
  Widget _buildDataField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    TextInputType? keyboardType,
    int? maxLines,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
        ),
        SizedBox(height: ResponsiveUtils.containerSize(8.h)),
        
        Container(
          decoration: BoxDecoration(
            color: Palette.red500,
            borderRadius: BorderRadius.circular(ResponsiveUtils.containerSize(12.r)),
            border: isEditing ? Border.all(color: Palette.red200, width: 1) : null,
          ),
          child: TextField(
            controller: controller,
            enabled: isEditing,
            keyboardType: keyboardType,
            style: TextStyles.bodyLarge.copyWith(
              color: isEditing ? Palette.white100 : Palette.grey200,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: ResponsiveUtils.containerSize(16.w),
                vertical: ResponsiveUtils.containerSize(14.h),
              ),
              hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
            ),
            cursorColor: Palette.white100,
            maxLines: maxLines,
          ),
        ),
      ],
    );
  }
}