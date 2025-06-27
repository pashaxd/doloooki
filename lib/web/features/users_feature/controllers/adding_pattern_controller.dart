// Контроллер для веб-редактора образов
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/web/features/users_feature/controllers/user_info.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:universal_html/html.dart' as html;

class WebPatternEditorController extends GetxController {
  final RxList<Map<String, dynamic>> canvasItems = <Map<String, dynamic>>[].obs;
  final RxString currentMode = 'move'.obs; // 'move', 'scale', 'rotate'
  final RxInt selectedItemIndex = (-1).obs;
  final RxBool showGrid = true.obs;
  final RxDouble gridSize = 50.0.obs;
  final RxDouble gridOpacity = 0.3.obs;
  final Rx<Color> gridColor = Colors.grey.obs;
  
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final RxBool isSaving = false.obs;
  final RxBool isLoading = false.obs;
  final RxBool isInSaveMode = false.obs; // Новое состояние для режима сохранения
  final RxString nameText = ''.obs; // Для отслеживания текста названия
  
  // Данные пользователя, чей гардероб мы используем
  String? targetUserId;
  final RxList<ClothesItem> userClothes = <ClothesItem>[].obs;
  final RxString selectedCategory = ''.obs;
  final RxString searchQuery = ''.obs;
  
  bool get hasSelectedItem => selectedItemIndex.value >= 0;
  bool get isNameValid => nameText.value.trim().isNotEmpty;
  bool get hasItems => canvasItems.isNotEmpty;
  
  bool get isSelectedItemAtFront {
    if (!hasSelectedItem) return false;
    final selectedItem = canvasItems[selectedItemIndex.value];
    final selectedZIndex = selectedItem['zIndex'] as int? ?? 0;
    final maxZIndex = canvasItems.fold<int>(0, (max, item) => math.max(max, item['zIndex'] as int? ?? 0));
    // Элемент считается "на переднем плане", если у него самый высокий zIndex
    // и на холсте больше одного элемента
    return canvasItems.length > 1 && selectedZIndex == maxZIndex;
  }
  
  // Фильтрованный список вещей
  List<ClothesItem> get filteredClothes {
    List<ClothesItem> filtered = userClothes.toList();
    
    if (selectedCategory.value.isNotEmpty) {
      filtered = filtered.where((item) => item.category == selectedCategory.value).toList();
    }
    
    if (searchQuery.value.isNotEmpty) {
      filtered = filtered.where((item) => 
        item.name.toLowerCase().contains(searchQuery.value.toLowerCase())
      ).toList();
    }
    
    return filtered;
  }
  
  void setTargetUser(String userId) {
    targetUserId = userId;
    loadUserWardrobe();
  }
  
  Future<void> loadUserWardrobe() async {
    if (targetUserId == null) return;
    
    try {
      isLoading.value = true;
      print('🔄 Загружаем гардероб пользователя: $targetUserId');
      
      final clothesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId!)
          .collection('wardrobe')
          .orderBy('createdAt', descending: true)
          .get();
      
      userClothes.value = clothesSnapshot.docs
          .map((doc) {
            try {
              return ClothesItem.fromMap(doc.data());
            } catch (e) {
              print('❌ Ошибка парсинга вещи ${doc.id}: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<ClothesItem>()
          .toList();
      
      print('✅ Загружено вещей: ${userClothes.length}');
    } catch (e) {
      print('❌ Ошибка загрузки гардероба: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  void setCategory(String category) {
    selectedCategory.value = category;
  }
  
  void setSearchQuery(String query) {
    searchQuery.value = query;
  }
  
  void addItemToCanvas(Map<String, dynamic> item, Offset position) {
    final newItem = Map<String, dynamic>.from(item);
    
    // Стандартные размеры элемента
    final itemWidth = 120.0;
    final itemHeight = 160.0;
    
    // Центрируем элемент относительно позиции курсора
    final centeredPosition = Offset(
      position.dx - (itemWidth / 2),
      position.dy - (itemHeight / 2),
    );
    
    newItem['position'] = {'x': centeredPosition.dx, 'y': centeredPosition.dy};
    newItem['scale'] = 1.0;
    newItem['rotation'] = 0.0;
    final maxZIndex = canvasItems.fold<int>(0, (max, i) => math.max(max, i['zIndex'] as int? ?? 0));
    newItem['zIndex'] = maxZIndex + 1;
    newItem['width'] = itemWidth;
    newItem['height'] = itemHeight;
    canvasItems.add(newItem);
    print('✅ Добавлена вещь на холст: ${newItem['name']} в позицию ${centeredPosition}');
  }
  
  void updateItemPosition(int index, Offset newPosition) {
    if (index >= 0 && index < canvasItems.length) {
      final item = Map<String, dynamic>.from(canvasItems[index]);
      item['position'] = {'x': newPosition.dx, 'y': newPosition.dy};
      canvasItems[index] = item;
    }
  }
  
  void selectItem(int index) {
    selectedItemIndex.value = (index == selectedItemIndex.value) ? -1 : index;
  }
  
  void updateItemScale(int index, double newScale) {
    if (index >= 0 && index < canvasItems.length) {
      final item = Map<String, dynamic>.from(canvasItems[index]);
      item['scale'] = newScale.clamp(0.3, 2.0);
      canvasItems[index] = item;
    }
  }
  
  void updateItemRotation(int index, double newRotation) {
    if (index >= 0 && index < canvasItems.length) {
      final item = Map<String, dynamic>.from(canvasItems[index]);
      item['rotation'] = newRotation;
      canvasItems[index] = item;
    }
  }
  
  void removeItemFromCanvas(int index) {
    if (index >= 0 && index < canvasItems.length) {
      canvasItems.removeAt(index);
      if (selectedItemIndex.value == index) {
        selectedItemIndex.value = -1;
      }
    }
  }
  
  void setMode(String mode) {
    currentMode.value = mode;
  }
  
  void toggleLayer() {
    if (!hasSelectedItem) return;
    final selectedItem = canvasItems[selectedItemIndex.value];
    final currentZ = selectedItem['zIndex'] as int? ?? 0;
    final maxZ = canvasItems.fold<int>(0, (max, item) => math.max(max, item['zIndex'] as int? ?? 0));
    
    if (currentZ == maxZ) {
      selectedItem['zIndex'] = canvasItems.fold<int>(0, (min, item) => math.min(min, item['zIndex'] as int? ?? 0)) - 1;
    } else {
      selectedItem['zIndex'] = maxZ + 1;
    }
    canvasItems.refresh();
  }
  
  Future<Uint8List?> captureCanvas(GlobalKey canvasKey) async {
    try {
      final boundary = canvasKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      
      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing canvas: $e");
      return null;
    }
  }
  
  Future<String> _uploadPatternImage(Uint8List imageBytes) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = 'users/${user.uid}/pattern_images/$timestamp.png';
      final ref = FirebaseStorage.instance.ref().child(path);

      final uploadTask = ref.putData(imageBytes);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading pattern image: $e');
      rethrow;
    }
  }
  
  Future<void> createPattern(Uint8List imageBytes) async {
    isSaving.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');
      if (targetUserId == null) throw Exception('Не указан пользователь для создания образа');

      print('🔄 Создаем новый образ для пользователя: $targetUserId');
      print('🔄 Создает стилист: ${user.uid}');
      
      final imageUrl = await _uploadPatternImage(imageBytes);
      final usedItems = canvasItems.map((item) => {
        'imageUrl': item['imageUrl'] as String,
        'name': item['name'] ?? 'Неизвестно',
        'position': item['position'],
        'scale': item['scale'],
        'rotation': item['rotation'],
      }).toList();

      final newId = FirebaseFirestore.instance.collection('patterns').doc().id;
      final newPattern = PatternItem(
        id: newId,
        name: nameController.text,
        description: descriptionController.text,
        imageUrl: imageUrl,
        createdAt: Timestamp.now(),
        userId: targetUserId!, // Образ принадлежит целевому пользователю
        usedItems: usedItems,
      );

      // Сохраняем образ в коллекцию целевого пользователя
      await FirebaseFirestore.instance
          .collection('users')
          .doc(targetUserId!) // Используем ID целевого пользователя
          .collection('patterns')
          .doc(newId)
          .set(newPattern.toMap());
          
      print('✅ Образ создан успешно для пользователя: $targetUserId');
      
      // Очищаем данные для следующего использования
      clearCanvas();
      nameController.clear();
      nameText.value = '';
      descriptionController.clear();
      
      // Небольшая задержка перед показом диалога
      await Future.delayed(const Duration(milliseconds: 100));
      
      Get.dialog(
        AlertDialog(
          backgroundColor: Palette.red400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            width: 150.sp,

            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/green.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 8.adaptiveSpacing),
                Text(
                  'Образ создан!',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Теперь вы можете найти его в разделе «Мои образы», отредактировать или поделиться с друзьями',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.adaptiveSpacing),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      print('🔘 Нажата кнопка "Продолжить" в диалоге');
                      Get.back(); // Закрываем диалог
                      // Обновляем информацию о пользователе, чтобы новый образ отобразился
                      try {
                        final userInfoController = Get.find<UserInfoController>();
                        // Обновляем как последние образы, так и полный список
                        userInfoController.loadUserData();
                        print('✅ Обновлен список образов в UserInfoController');
                      } catch (e) {
                        print('❌ UserInfoController не найден для обновления: $e');
                      }
                    },
                    style: ButtonStyles.primary,
                    child: Text(
                      'Продолжить',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
        useSafeArea: true,
        navigatorKey: Get.key,
      );
    } catch (e) {
      print('❌ Ошибка создания образа: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось создать образ: ${e.toString()}',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSaving.value = false;
    }
  }
  
  Future<void> downloadImage(GlobalKey canvasKey) async {
    try {
      final imageBytes = await captureCanvas(canvasKey);
      if (imageBytes == null) {
        Get.snackbar(
          'Ошибка',
          'Не удалось захватить изображение',
          backgroundColor: Palette.error,
          colorText: Palette.white100,
        );
        return;
      }
      
      final fileName = nameText.value.isNotEmpty ? nameText.value : 'pattern';
      final blob = html.Blob([imageBytes], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', '$fileName.png')
        ..click();
      html.Url.revokeObjectUrl(url);
      
      Get.snackbar(
        'Успешно',
        'Изображение скачано!',
        backgroundColor: Palette.success,
        colorText: Palette.white100,
      );
    } catch (e) {
      print('❌ Ошибка скачивания: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось скачать изображение',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    }
  }
  
  void clearCanvas() {
    canvasItems.clear();
    selectedItemIndex.value = -1;
  }
  
  void enterSaveMode() {
    isInSaveMode.value = true;
    showGrid.value = false;
    selectedItemIndex.value = -1; // Снимаем выделение
  }
  
  void exitSaveMode() {
    isInSaveMode.value = false;
    showGrid.value = true;
  }
  
  void safeDispose() {
    try {
      // Очищаем все данные
      canvasItems.clear();
      userClothes.clear();
      selectedItemIndex.value = -1;
      selectedCategory.value = '';
      searchQuery.value = '';
      nameText.value = '';
      targetUserId = null;
      
      // Очищаем контроллеры текста
      if (nameController.hasListeners) {
        nameController.clear();
      }
      if (descriptionController.hasListeners) {
        descriptionController.clear();
      }
      
      print('🧹 WebPatternEditorController очищен');
    } catch (e) {
      print('❌ Ошибка при очистке контроллера: $e');
    }
  }
  
  @override
  void onClose() {
    safeDispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }
  
  @override
  void onInit() {
    super.onInit();
    // Добавляем слушатель для поля названия
    nameController.addListener(() {
      nameText.value = nameController.text;
    });
  }
}
