import 'dart:io';
import 'dart:typed_data';
import 'dart:async';
import 'dart:ui' as ui;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/service/clothes_service.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/constants/wardrobe_constants.dart';
import 'package:local_rembg/local_rembg.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/snackbar_utils.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class WardrobeController extends GetxController {
  final ClothesService _clothesService = ClothesService();
  final RxList<ClothesItem> _allClothes = <ClothesItem>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxList<String> selectedTags = <String>[].obs;
  final RxList<String> customTags = <String>[].obs;
  final auth = FirebaseAuth.instance;
  final storage = FirebaseStorage.instance;
  final RxBool isLoading = true.obs;
  StreamSubscription? _clothesSubscription;
  StreamSubscription<User?>? _authSubscription;
  final ImagePicker _picker = ImagePicker();
  final Rx<File?> selectedImage = Rx<File?>(null);
  final RxBool isTagFocused = false.obs;
  
  // Переменные для отслеживания изменений
  final RxBool hasUnsavedChanges = false.obs;
  ClothesItem? _originalItem;
  String? _editingItemId;

  List<String> get categories => WardrobeConstants.categories;
  List<String> get tags => [...WardrobeConstants.tags, ...customTags];

  List<ClothesItem> get clothes {
    List<ClothesItem> filtered = _allClothes.toList();
    
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((item) => item.category == selectedCategory.value).toList();
    }
    
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.name.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    if (selectedTags.isNotEmpty) {
      filtered = filtered.where((item) => 
        selectedTags.any((tag) => item.tags.contains(tag))
      ).toList();
    }
    
    return filtered;
  }

  Future<void> _ensureUserDocument() async {
    try {
      final user = auth.currentUser;
      if (user == null) return;

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({
              'createdAt': FieldValue.serverTimestamp(),
              'updatedAt': FieldValue.serverTimestamp(),
            });
      }
    } catch (e) {
      print('Error ensuring user document: $e');
    }
  }

  @override
  void onInit() {
    super.onInit();
    
    // Слушаем изменения состояния авторизации
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Пользователь вышел из системы, очищаем данные
        _allClothes.value = [];
        customTags.value = [];
        isLoading.value = false;
        _clothesSubscription?.cancel();
        _clothesService.clearCache();
      } else {
        // Пользователь вошел в систему, инициализируем данные
        _initializeUserData();
      }
    });
  }

  Future<void> _initializeUserData() async {
    try {
      await _ensureUserDocument();
      await loadCustomTags();
      await _initializeStream();
    } catch (e) {
      print('Error initializing user data: $e');
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    // Clear any selected image when controller is closed
    selectedImage.value = null;
    _clothesSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeStream() async {
    try {
      isLoading.value = true;
      
      // Отменяем предыдущую подписку, если она существует
      await _clothesSubscription?.cancel();
      
      // Подписываемся на обновления гардероба
      _clothesSubscription = _clothesService.getClothes().listen(
        (items) {
          _allClothes.value = items;
          isLoading.value = false;
          update();
        },
        onError: (error) {
          print('Error in stream: $error');
          isLoading.value = false;
          update();
        },
        cancelOnError: false,
      );

      // Ждем инициализации стрима
      await Future.delayed(Duration(milliseconds: 1000));
      
      // Если данные все еще не загружены, пробуем загрузить напрямую
      if (_allClothes.isEmpty) {
        await _loadClothesDirectly();
      }
      
      isLoading.value = false;
      update();
    } catch (e) {
      print('Error initializing stream: $e');
      isLoading.value = false;
      update();
    }
  }

  Future<void> _loadClothesDirectly() async {
    try {
      final user = auth.currentUser;
      if (user != null) {
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('wardrobe')
            .orderBy('createdAt', descending: true)
            .get();
            
        if (snapshot.docs.isNotEmpty) {
          _allClothes.value = snapshot.docs
              .map((doc) => ClothesItem.fromMap(doc.data()))
              .toList();
        }
      }
    } catch (e) {
      print('Error loading clothes directly: $e');
    }
  }

  Future<void> loadClothes() async {
    try {
      isLoading.value = true;
      
      // Если стрим не инициализирован, инициализируем его
      if (_clothesSubscription == null) {
        await _initializeStream();
        return;
      }
      
      // Иначе пробуем загрузить данные напрямую
      await _loadClothesDirectly();
      
      isLoading.value = false;
      update();
    } catch (e) {
      print('Error loading clothes: $e');
      isLoading.value = false;
      update();
    }
  }

  // Добавляем метод для проверки готовности данных
  bool isDataReady() {
    return !isLoading.value && _allClothes.isNotEmpty;
  }

  Future<String> uploadImage(File imageFile) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'users/${user.uid}/wardrobe_images/$timestamp.jpg';
      final ref = storage.ref().child(path);

      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading image: $e');
      rethrow;
    }
  }

  Future<void> addClothes(ClothesItem item) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Добавляем документ в Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wardrobe')
          .doc(item.id)
          .set({
        ...item.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Обновляем локальный кэш
      _allClothes.insert(0, item);
      
      // Принудительно обновляем UI
      update();
      
      // Перезагружаем данные для синхронизации
      await loadClothes();
    } catch (e) {
      print('Error adding clothes: $e');
      rethrow;
    }
  }

  void setCategory(String category) {
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
  }

  void toggleTag(String tag) {
    if (selectedTags.contains(tag)) {
      selectedTags.remove(tag);
    } else {
      selectedTags.add(tag);
    }
  }

  void clearFilters() {
    selectedCategory.value = '';
    selectedTags.clear();
  }

  /// Удаляет фон с изображения и возвращает Uint8List с белым фоном
  Future<Uint8List?> removeBackground(File imageFile) async {
    try {
      return await runZoned(() async {
        final result = await LocalRembg.removeBackground(
          imagePath: imageFile.path,
        );
        
        if (result.status == 1 && result.imageBytes != null) {
          // Создаем изображение из байтов
          final codec = await ui.instantiateImageCodec(Uint8List.fromList(result.imageBytes!));
          final frame = await codec.getNextFrame();
          final image = frame.image;

          // Создаем новый canvas с белым фоном
          final recorder = ui.PictureRecorder();
          final canvas = ui.Canvas(recorder);
          
          // Заполняем фон белым цветом
          final paint = ui.Paint()..color = Colors.white;
          canvas.drawRect(
            Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
            paint
          );
          
          // Рисуем изображение поверх белого фона
          canvas.drawImage(image, Offset.zero, ui.Paint());
          
          // Конвертируем canvas в изображение
          final picture = recorder.endRecording();
          final img = await picture.toImage(image.width, image.height);
          final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
          
          return byteData?.buffer.asUint8List();
        } else {
          Get.snackbar('Ошибка', result.errorMessage ?? 'Ошибка удаления фона');
          return null;
        }
      }, zoneSpecification: ZoneSpecification(
        print: (_, __, ___, String msg) {
          // Suppress all prints during background removal
        },
      ));
    } catch (e) {
      Get.snackbar('Ошибка', 'Ошибка удаления фона: $e');
      return null;
    }
  }

  Future<void> updateClothes(ClothesItem item) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Используем правильный путь к коллекции
      final clothesRef = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wardrobe')
          .doc(item.id);

      // Проверяем, существует ли документ
      final docSnapshot = await clothesRef.get();
      if (!docSnapshot.exists) {
        throw Exception('Вещь не найдена');
      }

      // Подготавливаем данные для обновления
      final updateData = {
        'name': item.name,
        'description': item.description,
        'category': item.category,
        'tags': item.tags,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Добавляем imageUrl только если он изменился
      if (item.imageUrl != docSnapshot.data()?['imageUrl']) {
        updateData['imageUrl'] = item.imageUrl;
      }

      print('Updating clothes with data: $updateData'); // Добавляем для отладки

      // Обновляем документ
      await clothesRef.update(updateData);

      // Обновляем кэш
      final index = _allClothes.indexWhere((c) => c.id == item.id);
      if (index != -1) {
        _allClothes[index] = item;
        update();
      }

      SnackbarUtils.showSuccess('Изменения сохранены');
    } catch (e) {
      print('Error updating clothes: $e');
      await Get.dialog(
        Center(
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: 350.sp,
                minWidth: 350.sp,
              ),
              margin: EdgeInsets.symmetric(horizontal: 20.sp),
              padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 16.sp),
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/notifications/red.png',
                    width: 60.sp,
                    height: 60.sp,
                  ),
                  SizedBox(height: 16.sp),
                  Text(
                    'Ошибка',
                    style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    'Не удалось обновить вещь',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.sp),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ButtonStyles.primary,
                      child: Text(
                        'Понятно',
                        style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        barrierDismissible: false,
      );
      rethrow;
    }
  }

  Future<void> deleteClothes(String itemId) async {
    try {
      final user = auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Удаляем документ из Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('wardrobe')
          .doc(itemId)
          .delete();

      // Удаляем из кэша
      _allClothes.removeWhere((item) => item.id == itemId);
      update();
    } catch (e) {
      print('Error deleting clothes: $e');
      rethrow;
    }
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (image != null) {
        // Use update() to ensure UI updates are handled properly
        selectedImage.value = File(image.path);
        update();
      } else {
        // Clear the selected image if user cancels
        selectedImage.value = null;
        update();
      }
    } catch (e) {
      print('Ошибка при выборе изображения: $e');
      // Clear the selected image on error
      selectedImage.value = null;
      update();
      Get.snackbar(
        'Ошибка',
        'Не удалось выбрать изображение',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 70,
      );
      
      if (image != null) {
        // Use update() to ensure UI updates are handled properly
        selectedImage.value = File(image.path);
        update();
      } else {
        // Clear the selected image if user cancels
        selectedImage.value = null;
        update();
      }
    } catch (e) {
      print('Ошибка при съемке фото: $e');
      // Clear the selected image on error
      selectedImage.value = null;
      update();
      Get.snackbar(
        'Ошибка',
        'Не удалось сделать фото',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool> addCustomTag(String tag) async {
    if (tag.trim().isEmpty) return false;
    
    final normalizedTag = tag.trim().toLowerCase();
    
    if (WardrobeConstants.tags.any((t) => t.toLowerCase() == normalizedTag)) {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 350.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/red.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Ошибка',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Такой тег уже существует в стандартном списке',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ButtonStyles.primary,
                    child: Text(
                      'Понятно',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      return false;
    }
    
    if (customTags.any((t) => t.toLowerCase() == normalizedTag)) {
      await Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 320.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/red.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Такой тег уже существует',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Выберите другое название для тега',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ButtonStyles.primary,
                    child: Text(
                      'Понятно',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      return false;
    }
    
    try {
      final user = auth.currentUser;
      if (user == null) {
        await Get.dialog(
          AlertDialog(
            backgroundColor: Palette.red400,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Container(
              width: 320.sp,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/notifications/red.png',
                    width: 60.sp,
                    height: 60.sp,
                  ),
                  SizedBox(height: 16.sp),
                  Text(
                    'Ошибка',
                    style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.sp),
                  Text(
                    'Пользователь не авторизован',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.sp),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Get.back(),
                      style: ButtonStyles.primary,
                      child: Text(
                        'Понятно',
                        style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          barrierDismissible: false,
        );
        return false;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('custom_tags')
          .doc(normalizedTag)
          .set({
            'tag': normalizedTag,
            'createdAt': FieldValue.serverTimestamp(),
          });

      customTags.add(normalizedTag);
            
      await Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 320.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/green.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Успех',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Тег успешно добавлен',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ButtonStyles.primary,
                    child: Text(
                      'Отлично',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      return true;
    } catch (e) {
      print('Error saving custom tag: $e');
      await Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 320.sp,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/red.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Ошибка',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Не удалось сохранить тег: ${e.toString()}',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ButtonStyles.primary,
                    child: Text(
                      'Понятно',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      return false;
    }
  }

  void setTagFocus(bool focused) {
    isTagFocused.value = focused;
  }

  Future<void> loadCustomTags() async {
    try {
      final user = auth.currentUser;
      if (user == null) {
        print('User not authenticated');
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('custom_tags')
          .get();
            
      customTags.value = snapshot.docs
          .map((doc) => doc.data()['tag'] as String)
          .toList();
    } catch (e) {
      print('Error loading custom tags: $e');
    }
  }

  // Методы для работы с отслеживанием изменений
  void startEditingItem(String itemId) {
    _editingItemId = itemId;
    _originalItem = _allClothes.firstWhereOrNull((item) => item.id == itemId);
    hasUnsavedChanges.value = false;
  }
  
  void checkForChanges(ClothesItem currentItem) {
    if (_originalItem == null || _editingItemId != currentItem.id) return;
    
    hasUnsavedChanges.value = currentItem.name != _originalItem!.name ||
                             currentItem.description != _originalItem!.description ||
                             currentItem.category != _originalItem!.category ||
                             !_listsEqual(currentItem.tags, _originalItem!.tags);
  }
  
  bool _listsEqual(List<String> list1, List<String> list2) {
    if (list1.length != list2.length) return false;
    for (int i = 0; i < list1.length; i++) {
      if (list1[i] != list2[i]) return false;
    }
    return true;
  }
  
  void clearEditingState() {
    _editingItemId = null;
    _originalItem = null;
    hasUnsavedChanges.value = false;
  }
  
  Future<bool> showUnsavedChangesDialog() async {
    if (!hasUnsavedChanges.value) return true;
    
    return await Get.dialog<bool>(
      AlertDialog(
        contentPadding: EdgeInsets.all(4.sp),
        backgroundColor: Palette.red400,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Несохраненные изменения',
          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
          textAlign: TextAlign.center,
        ),
        content: Text(
          'Вы внесли изменения, но не сохранили их. Если выйти сейчас, изменения будут потеряны.',
          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
          textAlign: TextAlign.center,
        ),
        actions: [
          Column(
            children: [
              SizedBox(height: 6.sp),
              Container(
                width: double.infinity,
                height: 1,
                color: Palette.black300,
              ),
              TextButton(
                onPressed: () => Get.back(result: true),
                child: Text(
                  'Выйти',
                  style: TextStyles.buttonMedium.copyWith(color: Palette.error),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 2.sp),
              Container(
                width: double.infinity,
                height: 1,
                color: Palette.black300,
              ),
              SizedBox(height: 2.sp),
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text(
                  'Отмена',
                  style: TextStyles.buttonMedium.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    ) ?? false;
  }
}