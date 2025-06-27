import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:doloooki/web/features/users_feature/controllers/adding_pattern_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/controllers/wardrobe_controller.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';


class WebPatternEditor extends StatefulWidget {
  final String userId; // ID пользователя, чей гардероб мы используем
  
  const WebPatternEditor({
    super.key,
    required this.userId,
  });

  @override
  State<WebPatternEditor> createState() => _WebPatternEditorState();
}

class _WebPatternEditorState extends State<WebPatternEditor> {
  late final WebPatternEditorController controller;
  final GlobalKey _canvasKey = GlobalKey();
  final List<String> categories = ['Все', 'Верхняя одежда', 'Платья', 'Юбки', 'Брюки', 'Шорты', 'Футболки', 'Рубашки', 'Свитера', 'Джинсы', 'Сумки', 'Обувь', 'Аксессуары'];
  
  @override
  void initState() {
    super.initState();
    controller = Get.put(WebPatternEditorController(), tag: widget.userId);
    
    // Устанавливаем пользователя и загружаем его гардероб
    controller.setTargetUser(widget.userId);
  }
  
  @override
  void dispose() {
    // Удаляем контроллер при закрытии виджета
    Get.delete<WebPatternEditorController>(tag: widget.userId);
    super.dispose();
  }
  
  void _handleContinue() async {
    if (!controller.hasItems) return;
    
    // Переключаемся в режим сохранения
    controller.enterSaveMode();
  }
  
  void _handleSave() async {
    if (!controller.isNameValid) return;
    
    // Захватываем холст для создания превью
    final imageBytes = await controller.captureCanvas(_canvasKey);
    
    if (imageBytes != null) {
      await controller.createPattern(imageBytes);
    }
  }
  
  void _handleCancel() {
    if (controller.isInSaveMode.value) {
      // Возвращаемся в режим редактирования
      controller.exitSaveMode();
    } else {
      // Закрываем редактор
      Get.delete<WebPatternEditorController>(tag: widget.userId);
      Get.back();
    }
  }
  
  void _showSaveDialog(Uint8List imageBytes) {
    Get.dialog(
      Dialog(
        backgroundColor: Palette.red400,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Создать образ',
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Palette.grey300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.memory(imageBytes, fit: BoxFit.contain),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller.nameController,
                style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                decoration: InputDecoration(
                  labelText: 'Название образа',
                  labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  filled: true,
                  fillColor: Palette.red500,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller.descriptionController,
                maxLines: 2,
                style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                decoration: InputDecoration(
                  labelText: 'Описание (необязательно)',
                  labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  filled: true,
                  fillColor: Palette.red500,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        // Очищаем контроллер перед закрытием
                        Get.delete<WebPatternEditorController>(tag: widget.userId);
                        Get.back();
                      },
                      child: Text(
                        'Отмена',
                        style: TextStyles.buttonLarge.copyWith(color: Palette.grey350),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => ElevatedButton(
                      onPressed: controller.isSaving.value || !controller.isNameValid
                          ? null
                          : () => _createPattern(imageBytes),
                      style: controller.isNameValid ? ButtonStyles.primary : ButtonStyles.secondary,
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(
                              'Создать',
                              style: TextStyles.buttonMedium.copyWith(
                                color: controller.isNameValid ? Palette.white100 : Palette.grey350,
                              ),
                            ),
                    )),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _createPattern(Uint8List imageBytes) async {
    await controller.createPattern(imageBytes);
    
    // Закрываем диалог сохранения сразу
    Get.back();
    
    // Ждем немного чтобы snackbar успел показаться, затем закрываем редактор
    await Future.delayed(const Duration(milliseconds: 300));
    Get.back();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Palette.red400,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Palette.red600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            // Заголовок
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Palette.red500,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Создать образ',
                        style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                      ),
                      Text(
                        'Вы можете создать образ для пользователя',
                        style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      // Очищаем контроллер перед закрытием
                      Get.delete<WebPatternEditorController>(tag: widget.userId);
                      Get.back();
                    },
                    icon: Icon(Icons.close, color: Palette.white100),
                  ),
                ],
              ),
            ),
            
            // Основной контент
            Expanded(
              child: Row(
                children: [
                  // Левая панель - холст
                  Expanded(
                    flex: 3,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Palette.white50,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          // Холст с сеткой
                          RepaintBoundary(
                            key: _canvasKey,
                            child: GestureDetector(
                              onTap: () => controller.selectItem(-1),
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Palette.white50,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Obx(() => CustomPaint(
                                  painter: controller.showGrid.value
                                      ? GridPainter(
                                          gridSize: controller.gridSize.value,
                                          color: controller.gridColor.value
                                              .withOpacity(controller.gridOpacity.value),
                                        )
                                      : null,
                                  child: Stack(
                                    children: [
                                      // DragTarget для приема элементов
                                      Positioned.fill(
                                        child: DragTarget<Map<String, dynamic>>(
                                          onAcceptWithDetails: (details) {
                                            // Находим RenderBox холста для правильного расчета позиции
                                            final canvasRenderBox = _canvasKey.currentContext?.findRenderObject() as RenderBox?;
                                            if (canvasRenderBox != null) {
                                              // Преобразуем глобальную позицию в локальную относительно холста
                                              final localPosition = canvasRenderBox.globalToLocal(details.offset);
                                              // Учитываем отступы холста (margin 8px)
                                              final adjustedPosition = Offset(
                                                localPosition.dx - 8,
                                                localPosition.dy - 8,
                                              );
                                              controller.addItemToCanvas(details.data, adjustedPosition);
                                            }
                                          },
                                          builder: (context, candidateData, rejectedData) {
                                            return Container(color: Colors.transparent);
                                          },
                                        ),
                                      ),
                                      
                                      // Элементы на холсте
                                      _buildCanvasItems(),
                                    ],
                                  ),
                                )),
                              ),
                            ),
                          ),
                          
                          // Панель управления выбранным элементом
                          _buildControlPanel(),
                        ],
                      ),
                    ),
                  ),
                  
                  // Правая панель - гардероб или форма сохранения
                  Obx(() => controller.isInSaveMode.value 
                      ? _buildSaveForm()
                      : _buildWardrobePanel()),
                ],
              ),
            ),
            
            // Нижняя панель с кнопками
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCanvasItems() {
    return Obx(() {
      if (controller.canvasItems.isEmpty) {
        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.style,
                size: 64,
                color: Colors.grey,
              ),
              SizedBox(height: 16),
              Text(
                'Перетащите предметы из гардероба\nчтобы создать образ',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      }
      
      final sortedItems = controller.canvasItems.toList();
      sortedItems.sort((a, b) {
        final zA = a['zIndex'] as int? ?? 0;
        final zB = b['zIndex'] as int? ?? 0;
        return zA.compareTo(zB);
      });
      
      return Stack(
        children: sortedItems.map((item) {
          final index = controller.canvasItems.indexOf(item);
          final isSelected = controller.selectedItemIndex.value == index;
          final currentScale = item['scale'] ?? 1.0;
          final currentRotation = item['rotation'] ?? 0.0;
          final baseWidth = item['width'] ?? 120.0;
          final baseHeight = item['height'] ?? 160.0;
          final scaledWidth = baseWidth * currentScale;
          final scaledHeight = baseHeight * currentScale;
          
          return Positioned(
            left: item['position']['x'],
            top: item['position']['y'],
            child: _RotatedHitBox(
              width: scaledWidth,
              height: scaledHeight,
              rotation: currentRotation,
              onTap: controller.isInSaveMode.value ? null : () {
                print('Canvas item tapped at index: $index');
                controller.selectItem(index);
              },
              onPanUpdate: (isSelected && controller.currentMode.value == 'move' && !controller.isInSaveMode.value) ? (details) {
                final newPosition = Offset(
                  item['position']['x'] + details.delta.dx,
                  item['position']['y'] + details.delta.dy,
                );
                controller.updateItemPosition(index, newPosition);
              } : null,
              child: Transform.rotate(
                angle: currentRotation,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: scaledWidth,
                      height: scaledHeight,
                      decoration: BoxDecoration(
                        border: isSelected
                            ? Border.all(color: Palette.red50, width: 2)
                            : null,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: Image.network(
                          item['imageUrl'],
                          width: scaledWidth,
                          height: scaledHeight,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    
                    // Кнопка удаления
                    if (isSelected)
                      Positioned(
                        right: -10,
                        top: -10,
                        child: GestureDetector(
                          onTap: () => controller.removeItemFromCanvas(index),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    
                    // Кнопка управления размером/поворотом
                    if (isSelected && 
                        (controller.currentMode.value == 'scale' || 
                         controller.currentMode.value == 'rotate'))
                      Positioned(
                        right: -10,
                        bottom: -10,
                        child: GestureDetector(
                          onPanStart: null,
                          onPanUpdate: (details) {
                            // Обработка в зависимости от режима (как в мобильной версии)
                            switch (controller.currentMode.value) {
                              case 'scale':
                                final currentScale = item['scale'] ?? 1.0;
                                // Убираем отрицательное значение - теперь вниз = увеличение, вверх = уменьшение
                                final scaleChange = details.delta.dy * 0.01;
                                final newScale = (currentScale + scaleChange).clamp(0.1, 3.0);
                                controller.updateItemScale(index, newScale);
                                break;
                              case 'rotate':
                                final currentRotation = item['rotation'] ?? 0.0;
                                // Более интуитивная логика поворота: комбинируем горизонтальное и вертикальное движение
                                // Движение по диагонали для естественного вращения (инвертируем направление)
                                final rotationChange = -(details.delta.dx - details.delta.dy) * 0.01;
                                final newRotation = currentRotation + rotationChange;
                                controller.updateItemRotation(index, newRotation);
                                break;
                            }
                          },
                          onPanEnd: null,
                          onPanCancel: null,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Palette.red500,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 1),
                            ),
                            child: Center(
                              child: controller.currentMode.value == 'scale' 
                                ? SvgPicture.asset(
                                    'assets/icons/patterns/svg/size.svg', 
                                    color: Palette.white100,
                                    width: 12,
                                    height: 12,
                                  )
                                : SvgPicture.asset(
                                    'assets/icons/patterns/svg/krutilka.svg', 
                                    color: Palette.white100,
                                    width: 12,
                                    height: 12,
                                  ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      );
    });
  }
  
  Widget _buildControlPanel() {
    return Obx(() => (controller.hasSelectedItem && !controller.isInSaveMode.value)
        ? Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                
                borderRadius: BorderRadius.circular(16),
                
                
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Кнопка перемещения
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: controller.currentMode.value == 'move' ? Palette.red100 : Palette.red400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => controller.setMode('move'),
                      tooltip: 'Перемещение',
                      icon: SvgPicture.asset(
                        'assets/icons/patterns/svg/cursor.svg',
                        color: controller.currentMode.value == 'move' ? Palette.white100 : Palette.red50,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  
                  // Кнопка масштабирования
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: controller.currentMode.value == 'scale' ? Palette.red100 : Palette.red400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => controller.setMode('scale'),
                      tooltip: 'Масштаб',
                      icon: SvgPicture.asset(
                        'assets/icons/patterns/svg/size.svg',
                        color: controller.currentMode.value == 'scale' ? Palette.white100 : Palette.red50,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  
                  // Кнопка поворота
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: controller.currentMode.value == 'rotate' ? Palette.red100 : Palette.red400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => controller.setMode('rotate'),
                      tooltip: 'Поворот',
                      icon: SvgPicture.asset(
                        'assets/icons/patterns/svg/krutilka.svg',
                        color: controller.currentMode.value == 'rotate' ? Palette.white100 : Palette.red50,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                  
                  // Кнопка слоев
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: controller.isSelectedItemAtFront ? Palette.red100 : Palette.red400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      onPressed: () => controller.toggleLayer(),
                      tooltip: 'Слои',
                      icon: SvgPicture.asset(
                        'assets/icons/patterns/svg/sloi.svg',
                        color: controller.isSelectedItemAtFront ? Palette.white100 : Palette.red50,
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        : const SizedBox.shrink());
  }
  
  Widget _buildWardrobePanel() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок гардероба
           Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Гардероб пользователя',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                ),
                const SizedBox(height: 16),
                
                // Поиск
                TextField(
                  onChanged: (value) => controller.setSearchQuery(value),
                  style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                  decoration: InputDecoration(
                    hintText: 'Поиск в гардеробе...',
                    hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    prefixIcon: Icon(Icons.search, color: Palette.grey350),
                    filled: true,
                    fillColor: Palette.red400,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Категории
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return Obx(() => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: (category == 'Все' && controller.selectedCategory.value == '') ||
                                    (category != 'Все' && controller.selectedCategory.value == category),
                          onSelected: (selected) {
                            if (category == 'Все') {
                              controller.setCategory('');
                            } else {
                              controller.setCategory(category);
                            }
                          },
                          backgroundColor: Palette.red600,
                          selectedColor: Palette.red100,
                          side: BorderSide.none,
                          showCheckmark: false,
                          labelStyle: TextStyles.bodySmall.copyWith(
                            color: ((category == 'Все' && controller.selectedCategory.value == '') ||
                                   (category != 'Все' && controller.selectedCategory.value == category))
                                ? Palette.white100
                                : Palette.grey350,
                          ),
                        ),
                      ));
                    },
                  ),
                ),
              ],
            ),
          
          
          // Список вещей
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              
              if (controller.userClothes.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.checkroom, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'Гардероб пустой',
                        style: TextStyle(color: Colors.grey, fontSize: 18),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'У пользователя нет вещей\nв гардеробе',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),
                      SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () async {
                          await controller.loadUserWardrobe();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Palette.red400,
                          foregroundColor: Colors.white,
                        ),
                        child: Text('Обновить'),
                      ),
                    ],
                  ),
                );
              }
              
              final filteredClothes = controller.filteredClothes;
              
              return GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: filteredClothes.length,
                itemBuilder: (context, index) {
                  final item = filteredClothes[index];
                  return Draggable<Map<String, dynamic>>(
                    data: {
                      'imageUrl': item.imageUrl,
                      'name': item.name,
                    },
                    feedback: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(item.imageUrl, fit: BoxFit.cover),
                        ),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.5,
                      child: _buildClothesCard(item),
                    ),
                    child: _buildClothesCard(item),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveForm() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Заголовок
           Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Сохранить образ',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                ),
                const SizedBox(height: 8),
                Text(
                  'Заполните информацию об образе',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                ),
              ],
            ),
          
          
          // Поля формы
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Поле названия
                  TextField(
                    controller: controller.nameController,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    decoration: InputDecoration(
                      labelText: 'Название образа',
                      labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      filled: true,
                      fillColor: Palette.red500,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                    ),
                    maxLength: 50,
                  ),
                  const SizedBox(height: 16),
                  
                  // Поле описания
                  TextField(
                    controller: controller.descriptionController,
                    maxLines: 3,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    decoration: InputDecoration(
                      labelText: 'Описание (необязательно)',
                      labelStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      filled: true,
                      fillColor: Palette.red500,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      counterText: '',
                      alignLabelWithHint: true,
                    ),
                    maxLength: 200,
                  ),
                  
                  const Spacer(),
                  
                  // Кнопка "Скачать образ"
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Obx(() => ElevatedButton.icon(
                      onPressed: controller.hasItems ? () async {
                        // Используем метод контроллера для скачивания
                        await controller.downloadImage(_canvasKey);
                      } : null,
                      icon: Icon(Icons.download, color: controller.hasItems ? Palette.white100 : Palette.grey350),
                      label: Text(
                        'Скачать образ',
                        style: TextStyles.bodyMedium.copyWith(
                          color: controller.hasItems ? Palette.white100 : Palette.grey350,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.hasItems ? Palette.red400 : Palette.grey350,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBottomPanel() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Palette.red500,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Obx(() => Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _handleCancel,
              child: Text(
                controller.isInSaveMode.value ? 'Назад' : 'Отмена',
                style: TextStyles.buttonSmall.copyWith(color: Palette.grey350),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: controller.isInSaveMode.value
                ? Obx(() => ElevatedButton(
                    onPressed: controller.isSaving.value || !controller.isNameValid ? null : _handleSave,
                    style: controller.isNameValid ? ButtonStyles.primary : ButtonStyles.secondary,
                    child: controller.isSaving.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            'Создать',
                            style: TextStyles.buttonSmall.copyWith(
                              color: controller.isNameValid ? Palette.white100 : Palette.grey350,
                            ),
                          ),
                  ))
                : Obx(() => ElevatedButton(
                    onPressed: controller.hasItems ? _handleContinue : null,
                    style: controller.hasItems ? ButtonStyles.primary : ButtonStyles.secondary,
                    child: Text(
                      'Продолжить',
                      style: TextStyles.buttonSmall.copyWith(
                        color: controller.hasItems ? Palette.white100 : Palette.grey350,
                      ),
                    ),
                  )),
          ),
        ],
      )),
    );
  }
  
  Widget _buildClothesCard(ClothesItem item) {
    return 
       Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(
                item.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              item.name,
              style: TextStyles.bodySmall.copyWith(color: Palette.white100),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      
    );
  }
}

// Painter для сетки
class GridPainter extends CustomPainter {
  final double gridSize;
  final Color color;

  GridPainter({
    required this.gridSize,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1;

    // Вертикальные линии
    for (double i = 0; i < size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    // Горизонтальные линии
    for (double i = 0; i < size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) {
    return oldDelegate.gridSize != gridSize || oldDelegate.color != color;
  }
}

// Кастомный GestureDetector для повернутых элементов (скопировано из мобильной версии)
class _RotatedHitBox extends StatelessWidget {
  final double width;
  final double height;
  final double rotation;
  final VoidCallback? onTap;
  final Function(DragUpdateDetails)? onPanUpdate;
  final Widget child;

  const _RotatedHitBox({
    Key? key,
    required this.width,
    required this.height,
    required this.rotation,
    this.onTap,
    this.onPanUpdate,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Вычисляем размеры bounding box для повернутого элемента
    final cos = math.cos(rotation).abs();
    final sin = math.sin(rotation).abs();
    final boundingWidth = width * cos + height * sin;
    final boundingHeight = width * sin + height * cos;
    
    return SizedBox(
      width: boundingWidth,
      height: boundingHeight,
      child: GestureDetector(
        onTap: onTap,
        onPanUpdate: onPanUpdate,
        behavior: HitTestBehavior.opaque,
        child: Center(
          child: child,
        ),
      ),
    );
  }
}

// Функция для показа редактора образов
void showPatternEditor({
  required String userId, // ID пользователя, чей гардероб используется
}) {
  Get.dialog(
    WebPatternEditor(
      userId: userId,
    ),
    barrierDismissible: false,
  );
}
