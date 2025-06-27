import 'dart:math' as math;
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'patterns_controller.dart';

class AddingPatternController extends GetxController {
  final RxList<Map<String, dynamic>> canvasItems = <Map<String, dynamic>>[].obs;
  final RxList<ClothesItem> _allClothes = <ClothesItem>[].obs;
  final RxDouble sheetSize = 0.4.obs;
  
  // Режим работы с элементами
  final RxString currentMode = 'move'.obs; // 'move', 'scale', 'rotate'
  
  // Сетка
  final RxBool showGrid = true.obs;
  final RxDouble gridSize = 50.0.obs;
  final RxDouble gridOpacity = 0.5.obs;
  final Rx<Color> gridColor = Colors.grey.obs;

  // Выбранный элемент
  final RxInt selectedItemIndex = (-1).obs;
  final RxDouble selectedItemScale = 1.0.obs;
  final RxDouble selectedItemRotation = 0.0.obs;
  final RxInt selectedItemZIndex = 0.obs;

  final RxBool isSaving = false.obs;

  // Контроллеры и фокус для текстовых полей
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final isNameFocused = false.obs;
  final isDescriptionFocused = false.obs;
  
  // Реактивные переменные для отслеживания длины текста
  final RxInt nameLength = 0.obs;
  final RxInt descriptionLength = 0.obs;

  // Отслеживание изменений для редактирования
  final RxBool hasUnsavedChanges = false.obs;
  String? _editingPatternId;
  Map<String, dynamic>? _originalPattern;
  List<Map<String, dynamic>>? _originalCanvasItems;

  bool get isNameValid => nameController.text.trim().isNotEmpty;
  bool get isCheck => canvasItems.isNotEmpty;
  bool get hasSelectedItem => selectedItemIndex.value >= 0;

  bool get isSelectedItemAtFront {
    if (!hasSelectedItem) return false;
    final selectedItem = canvasItems[selectedItemIndex.value];
    final selectedZIndex = selectedItem['zIndex'] as int? ?? 0;
    final maxZIndex = canvasItems.fold<int>(0, (max, item) => math.max(max, item['zIndex'] as int? ?? 0));
    // Элемент считается "на переднем плане", если у него самый высокий zIndex
    // и на холсте больше одного элемента
    return canvasItems.length > 1 && selectedZIndex == maxZIndex;
  }
  
  List<ClothesItem> get clothes {
    List<ClothesItem> filtered = _allClothes.toList();
    
    return filtered;
  }

  void updateSheetSize(double size) {
    sheetSize.value = size.clamp(0.3, 0.8);
    update();
  }

  void addItemToCanvas(Map<String, dynamic> item, Offset position) {
    print('Adding item to canvas: $item at position: $position');
    final newItem = Map<String, dynamic>.from(item);
    newItem['position'] = {'x': position.dx, 'y': position.dy};
    newItem['scale'] = 1.0;
    newItem['rotation'] = 0.0;
    final maxZIndex = canvasItems.fold<int>(0, (max, i) => math.max(max, i['zIndex'] as int? ?? 0));
    newItem['zIndex'] = maxZIndex + 1;
    canvasItems.add(newItem);
    print('Canvas items count: ${canvasItems.length}');
    if (_editingPatternId != null) {
      checkForChanges();
    }
    update();
  }

  void updateItemPosition(int index, Offset newPosition) {
    if (index >= 0 && index < canvasItems.length) {
      final item = Map<String, dynamic>.from(canvasItems[index]);
      item['position'] = {'x': newPosition.dx, 'y': newPosition.dy};
      canvasItems[index] = item;
      if (_editingPatternId != null) {
        checkForChanges();
      }
      update();
    }
  }

  void selectItem(int index) {
    print('Selecting item at index: $index');
    if (index == selectedItemIndex.value) {
      // If clicking the same item, deselect it
      selectedItemIndex.value = -1;
      print('Deselected item');
    } else {
      selectedItemIndex.value = index;
      print('Selected item at index: $index');
    }
    update();
  }

  void updateItemScale(int index, double newScale) {
    if (index >= 0 && index < canvasItems.length) {
      final item = Map<String, dynamic>.from(canvasItems[index]);
      item['scale'] = newScale;
      canvasItems[index] = item;
      if (_editingPatternId != null) {
        checkForChanges();
      }
      update();
    }
  }

  void updateItemRotation(int index, double newRotation) {
    if (index >= 0 && index < canvasItems.length) {
      final item = Map<String, dynamic>.from(canvasItems[index]);
      item['rotation'] = newRotation;
      canvasItems[index] = item;
      if (_editingPatternId != null) {
        checkForChanges();
      }
      update();
    }
  }

  void updateItemZIndex(int index, int zIndex) {
    if (index >= 0 && index < canvasItems.length) {
      canvasItems[index] = {
        ...canvasItems[index],
        'zIndex': zIndex,
      };
      canvasItems.refresh();
      if (_editingPatternId != null) {
        checkForChanges();
      }
    }
  }

  void bringToFront(int index) {
    if (index >= 0 && index < canvasItems.length) {
      final maxZIndex = canvasItems.fold(0, (max, item) => 
        (item['zIndex'] as int? ?? 0) > max ? (item['zIndex'] as int? ?? 0) : max);
      updateItemZIndex(index, maxZIndex + 1);
    }
  }

  void sendToBack(int index) {
    if (index >= 0 && index < canvasItems.length) {
      final minZIndex = canvasItems.fold(0, (min, item) => 
        (item['zIndex'] as int? ?? 0) < min ? (item['zIndex'] as int? ?? 0) : min);
      updateItemZIndex(index, minZIndex - 1);
    }
  }

  void toggleLayer() {
    if (!hasSelectedItem) return;
    if (isSelectedItemAtFront) {
      sendToBack(selectedItemIndex.value);
    } else {
      bringToFront(selectedItemIndex.value);
    }
    update();
  }

  void removeItemFromCanvas(int index) {
    if (index >= 0 && index < canvasItems.length) {
      canvasItems.removeAt(index);
      if (selectedItemIndex.value == index) {
        selectedItemIndex.value = -1;
      }
      if (_editingPatternId != null) {
        checkForChanges();
      }
      update();
    }
  }

  void toggleGrid() {
    showGrid.value = !showGrid.value;
  }

  void updateGridSize(double size) {
    gridSize.value = size;
  }

  void updateGridOpacity(double opacity) {
    gridOpacity.value = opacity;
  }

  void updateGridColor(Color color) {
    gridColor.value = color;
  }

  void setMode(String mode) {
    currentMode.value = mode;
    update();
  }

  void loadPatternForEditing(PatternItem pattern) {
    // Очищаем текущие элементы
    canvasItems.clear();
    selectedItemIndex.value = -1;
    
    // Сохраняем оригинальные данные для отслеживания изменений
    _editingPatternId = pattern.id;
    _originalPattern = {
      'name': pattern.name,
      'description': pattern.description,
    };
    _originalCanvasItems = List<Map<String, dynamic>>.from(pattern.usedItems.map((item) => Map<String, dynamic>.from(item)));
    
    // Загружаем данные в форму
    nameController.text = pattern.name;
    descriptionController.text = pattern.description;
    
    // Загружаем элементы из паттерна
    for (int i = 0; i < pattern.usedItems.length; i++) {
      final usedItem = pattern.usedItems[i];
      final canvasItem = {
        'imageUrl': usedItem['imageUrl'],
        'name': usedItem['name'],
        'position': usedItem['position'],
        'scale': usedItem['scale'] ?? 1.0,
        'rotation': usedItem['rotation'] ?? 0.0,
        'zIndex': i, // Присваиваем zIndex по порядку
        'width': 100.0, // Стандартная ширина
        'height': 150.0, // Стандартная высота
      };
      canvasItems.add(canvasItem);
    }
    
    // Сбрасываем флаг изменений
    hasUnsavedChanges.value = false;
    
    update();
  }

  void startEditingPattern(String patternId) {
    _editingPatternId = patternId;
    hasUnsavedChanges.value = false;
  }

  void checkForChanges() {
    if (_editingPatternId == null || _originalPattern == null) {
      print('DEBUG: checkForChanges called but not in editing mode');
      return;
    }
    
    // Проверяем изменения в тексте
    bool nameChanged = nameController.text.trim() != _originalPattern!['name'];
    bool descriptionChanged = descriptionController.text.trim() != _originalPattern!['description'];
    
    print('DEBUG: Name changed: $nameChanged (${nameController.text.trim()} vs ${_originalPattern!['name']})');
    print('DEBUG: Description changed: $descriptionChanged');
    
    // Проверяем изменения в элементах на холсте
    bool canvasChanged = false;
    if (_originalCanvasItems != null) {
      if (canvasItems.length != _originalCanvasItems!.length) {
        canvasChanged = true;
        print('DEBUG: Canvas items count changed: ${canvasItems.length} vs ${_originalCanvasItems!.length}');
      } else {
        for (int i = 0; i < canvasItems.length; i++) {
          final current = canvasItems[i];
          final original = _originalCanvasItems![i];
          
          if (current['imageUrl'] != original['imageUrl'] ||
              current['position']['x'] != original['position']['x'] ||
              current['position']['y'] != original['position']['y'] ||
              current['scale'] != original['scale'] ||
              current['rotation'] != original['rotation']) {
            canvasChanged = true;
            print('DEBUG: Canvas item $i changed');
            break;
          }
        }
      }
    }
    
    final previousValue = hasUnsavedChanges.value;
    hasUnsavedChanges.value = nameChanged || descriptionChanged || canvasChanged;
    
    if (previousValue != hasUnsavedChanges.value) {
      print('DEBUG: hasUnsavedChanges changed to: ${hasUnsavedChanges.value}');
    }
  }

  void clearEditingState() {
    _editingPatternId = null;
    _originalPattern = null;
    _originalCanvasItems = null;
    hasUnsavedChanges.value = false;
  }

  Future<bool> showUnsavedChangesDialog() async {
    if (!hasUnsavedChanges.value) return true;
    
    final result = await Get.dialog<bool>(
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
          'Вы внесли изменения, но не сохранили их. Если выйти сейчас, изменения будут потеряны.',
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
    );
    
    return result ?? false;
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

  Future<void> savePattern({
    required Uint8List imageBytes,
    required String name,
    required String description,
  }) async {
    isSaving.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      final imageUrl = await _uploadPatternImage(imageBytes);
      final newId = FirebaseFirestore.instance.collection('patterns').doc().id;

      // Преобразуем canvasItems в usedItems для сохранения
      final usedItems = canvasItems.map((item) => {
        'imageUrl': item['imageUrl'] as String,
        'name': item['name'] ?? 'Неизвестно',
        'position': item['position'],
        'scale': item['scale'],
        'rotation': item['rotation'],
      }).toList();

      final newPattern = PatternItem(
        id: newId,
        name: name,
        description: description,
        imageUrl: imageUrl,
        createdAt: Timestamp.now(),
        userId: user.uid,
        usedItems: usedItems,
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('patterns')
          .doc(newId)
          .set(newPattern.toMap());
      
      // Обновляем список паттернов
      try {
        final patternsController = Get.find<PatternsListController>();
        await patternsController.refreshPatterns();
      } catch (e) {
        print('PatternsListController not found: $e');
      }
      
      Get.back(); // Возврат с экрана добавления имени
      Get.back(); // Возврат с экрана создания образа
      Get.dialog(
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
                  'assets/icons/notifications/green.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
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
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Get.back(),
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
      );

    } catch (e) {
      print('Failed to save pattern: $e');
      Get.snackbar('Ошибка', 'Не удалось сохранить образ');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> updatePattern({
    required String patternId,
    required String name,
    required String description,
    Uint8List? imageBytes,
  }) async {
    isSaving.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Преобразуем canvasItems в usedItems для сохранения
      final usedItems = canvasItems.map((item) => {
        'imageUrl': item['imageUrl'] as String,
        'name': item['name'] ?? 'Неизвестно',
        'position': item['position'],
        'scale': item['scale'],
        'rotation': item['rotation'],
      }).toList();

      Map<String, dynamic> updateData = {
        'name': name,
        'description': description,
        'usedItems': usedItems,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Если передан новый imageBytes, загружаем новое изображение
      if (imageBytes != null) {
        final imageUrl = await _uploadPatternImage(imageBytes);
        updateData['imageUrl'] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('patterns')
          .doc(patternId)
          .update(updateData);
      
      // Обновляем список паттернов
      try {
        final patternsController = Get.find<PatternsListController>();
        await patternsController.refreshPatterns();
      } catch (e) {
        print('PatternsListController not found: $e');
      }
      
      // Очищаем состояние редактирования
      clearEditingState();
      
      Get.back(); // Возврат с экрана редактирования имени
      Get.back(); // Возврат с экрана редактирования образа
      Get.snackbar('Успех', 'Образ успешно обновлен!');

    } catch (e) {
      print('Failed to update pattern: $e');
      Get.snackbar('Ошибка', 'Не удалось обновить образ');
    } finally {
      isSaving.value = false;
    }
  }

  Future<Uint8List?> captureAndPreparePatternImage({
    required BuildContext context,
    required GlobalKey repaintBoundaryKey,
    required double sheetSize,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final sheetHeightPx = MediaQuery.of(context).size.height * sheetSize;
      final croppedHeight = image.height - sheetHeightPx.toInt();
      ByteData? byteData;
      if (croppedHeight > 0) {
        final recorder = ui.PictureRecorder();
        final canvas = Canvas(recorder);
        final paint = Paint();
        canvas.drawImageRect(
          image,
          Rect.fromLTWH(0, 0, image.width.toDouble(), croppedHeight.toDouble()),
          Rect.fromLTWH(0, 0, image.width.toDouble(), croppedHeight.toDouble()),
          paint,
        );
        final croppedImage = await recorder.endRecording().toImage(image.width, croppedHeight);
        byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      } else {
        byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      }
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing canvas: $e");
      return null;
    }
  }

  void setFocus(String field) {
    if (field == 'name') {
      isNameFocused.value = true;
      isDescriptionFocused.value = false;
    } else if (field == 'description') {
      isNameFocused.value = false;
      isDescriptionFocused.value = true;
    } else {
      isNameFocused.value = false;
      isDescriptionFocused.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    // Добавляем слушатели для отслеживания изменений текста
    nameController.addListener(() {
      nameLength.value = nameController.text.length;
      if (_editingPatternId != null) {
        checkForChanges();
      }
    });
    descriptionController.addListener(() {
      descriptionLength.value = descriptionController.text.length;
      if (_editingPatternId != null) {
        checkForChanges();
      }
    });
  }
}