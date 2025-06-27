import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:doloooki/mobile/features/patterns_feature/presentation/controller/adding_pattern_controller.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/screens/adding_pattern.dart';
import 'package:doloooki/mobile/features/patterns_feature/presentation/widgets/patterns_card.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/controllers/wardrobe_controller.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/adding_thing.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/widgets/wardrobe_card.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'dart:math' as math;
import 'package:flutter/rendering.dart';
import 'package:flutter_box_transform/flutter_box_transform.dart';
import 'package:flutter/rendering.dart';

class AddingPatternImage extends StatefulWidget {
  final bool isEditing;
  final PatternItem? existingPattern;
  
  const AddingPatternImage({
    super.key,
    this.isEditing = false,
    this.existingPattern,
  });

  @override
  State<AddingPatternImage> createState() => _AddingPatternImageState();
}

class _AddingPatternImageState extends State<AddingPatternImage> {
  final AddingPatternController controller = Get.put(AddingPatternController());
  final DraggableScrollableController _scrollController = DraggableScrollableController();
  final WardrobeController wardrobeController = Get.put(WardrobeController());
  late final TextEditingController _searchController;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  final List<String> categoriesWithAll = ['Все', 'Верхняя одежда', 'Платья', 'Юбки', 'Брюки', 'Шорты', 'Футболки', 'Рубашки', 'Свитера', 'Джинсы', 'Сумки', 'Обувь', 'Аксессуары'];

  Future<Uint8List?> _captureCanvas() async {
    try {
      final boundary = _repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      print("Error capturing canvas: $e");
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      controller.updateSheetSize(_scrollController.size);
    });
    _searchController = TextEditingController(text: wardrobeController.searchQuery.value);
    
    // Если это редактирование, загружаем существующий паттерн
    if (widget.isEditing && widget.existingPattern != null) {
      controller.loadPatternForEditing(widget.existingPattern!);
      controller.startEditingPattern(widget.existingPattern!.id);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    wardrobeController.setSearchQuery('');
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (widget.isEditing) {
              final shouldPop = await controller.showUnsavedChangesDialog();
              if (shouldPop) {
                controller.clearEditingState();
              }
              return shouldPop;
            }
            return true;
          },
          child: Scaffold(
            backgroundColor: Palette.red600,
            appBar: AppBar(
              centerTitle: true,
              backgroundColor: Palette.red600,
              title: Text(
                widget.isEditing ? 'Редактирование образа' : 'Создание образа',
                style: TextStyles.titleLarge.copyWith(color: Palette.white100),
              ),
              leading: Container(
                decoration: BoxDecoration(
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Container(
                  child: Center(
                    child: IconButton(
                      onPressed: () async {
                        if (widget.isEditing) {
                          final shouldPop = await controller.showUnsavedChangesDialog();
                          if (shouldPop) {
                            controller.clearEditingState();
                            Get.back();
                          }
                        } else {
                          Get.back();
                        }
                      },
                      icon: Icon(Icons.arrow_back_ios_new, color: Palette.white100,),
                    ),
                  ),
                ),
              ),
              actions: [
                Obx(() => Container(
                  height: 50.sp,
                  width: 50.sp,
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Container(
                    margin: EdgeInsets.all(10.sp),
                    decoration: BoxDecoration(
                      color: controller.isCheck ? Palette.success : Palette.red50,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: GestureDetector(
                        onTap: () async {
                          // 1. Убрать сетку и выделение
                          controller.showGrid.value = false;
                          controller.selectItem(-1);
                          // 2. Дать UI обновиться
                          await Future.delayed(const Duration(milliseconds: 50));
                          await WidgetsBinding.instance.endOfFrame;
                          // 3. Захватить холст с crop (обрезать 20% экрана снизу)
                          final imageBytes = await controller.captureAndPreparePatternImage(
                            context: context,
                            repaintBoundaryKey: _repaintBoundaryKey,
                            sheetSize: 0.8 , 
                          );
                          // 4. Вернуть сетку обратно (если нужно)
                          controller.showGrid.value = true;
                          if (imageBytes != null && mounted) {
                            Get.to(() => AddingPattern(
                              imageBytes: imageBytes,
                              isEditing: widget.isEditing,
                              existingPattern: widget.existingPattern,
                            ));
                          }
                        },
                        child: Icon(
                          Icons.check,
                          color: Palette.black100,
                          size: 24.sp,
                        ),
                      ),
                    ),
                  ),
                )),
              ],
            ),
            body: Stack(
              children: [
                RepaintBoundary(
                  key: _repaintBoundaryKey,
                  child: Stack(
                    children: [
                      // 1. Фон и сетка
                      GestureDetector(
                        onTap: () {
                          // Снимаем выделение при нажатии на фон
                          controller.selectItem(-1);
                        },
                        child: Container(
                          margin: EdgeInsets.all(4.sp),
                          decoration: BoxDecoration(
                            color: Palette.white50,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Obx(() => CustomPaint(
                            size: Size.infinite,
                            painter: controller.showGrid.value
                              ? GridPainter(
                                  gridSize: controller.gridSize.value,
                                  color: controller.gridColor.value.withOpacity(controller.gridOpacity.value),
                                )
                              : null,
                          )),
                        ),
                      ),
                      // 2. DragTarget для дропа из гардероба
                      Positioned.fill(
                        child: DragTarget<Map<String, dynamic>>(
                          onWillAccept: (data) {
                            print('DragTarget: onWillAccept called with data: $data');
                            return true;
                          },
                          onAcceptWithDetails: (DragTargetDetails details) {
                            print('DragTarget: Item dropped at global position: ${details.offset}');
                            // Получаем RenderBox текущего DragTarget
                            final renderBox = context.findRenderObject() as RenderBox;
                            final dropPosition = renderBox.globalToLocal(details.offset);
                            print('DragTarget: Local position: $dropPosition');
                            print('DragTarget: Item data: ${details.data}');
                            controller.addItemToCanvas(details.data, dropPosition);
                          },
                          builder: (context, candidateData, rejectedData) {
                            return Container(
                              color: Colors.transparent,
                            );
                          },
                        ),
                      ),
                      // 3. Элементы на холсте
                      Obx(() {
                        final sortedItems = controller.canvasItems.toList();
                        sortedItems.sort((a, b) {
                          final zA = a['zIndex'] as int? ?? 0;
                          final zB = b['zIndex'] as int? ?? 0;
                          return zA.compareTo(zB);
                        });
                        
                        if (sortedItems.isEmpty) {
                          return Positioned(
                            top: 200.sp,
                            left: 0,
                            right: 0,
                            child: IgnorePointer(
                              child: Container(
                                height: 150.sp,
                                width: 250.sp,
                                margin: EdgeInsets.symmetric(horizontal: 50.sp),
                                decoration: BoxDecoration(
                                  color: Palette.red400,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SvgPicture.asset(
                                      'assets/icons/patterns/svg/armour.svg',
                                      color: Palette.grey350,
                                      width: 48.sp,
                                      height: 48.sp,
                                    ),
                                    SizedBox(height: 6.sp),
                                    
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 28.sp),
                                      child: Text(
                                        'Выберите предметы из гардероба и добавьте их на холст',
                                        style: TextStyles.bodyMedium,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        
                        return Stack(
                          children: [
                            ...sortedItems.map((item) {
                              final index = controller.canvasItems.indexOf(item);
                              final isSelected = controller.selectedItemIndex.value == index;
                              final currentScale = item['scale'] ?? 1.0;
                              final currentRotation = item['rotation'] ?? 0.0;
                              final baseWidth = item['width'] ?? 100.sp;
                              final baseHeight = item['height'] ?? 150.sp;
                              final scaledWidth = baseWidth * currentScale;
                              final scaledHeight = baseHeight * currentScale;
                              
                              return Positioned(
                                left: item['position']['x'],
                                top: item['position']['y'],
                                child: _RotatedHitBox(
                                  width: scaledWidth,
                                  height: scaledHeight,
                                  rotation: currentRotation,
                                  onTap: () {
                                    print('Canvas item tapped at index: $index');
                                    controller.selectItem(index);
                                  },
                                  onPanUpdate: isSelected && controller.currentMode.value == 'move' ? (details) {
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
                                            border: isSelected ? Border.all(color: Palette.red50, width: 2) : null,
                                            borderRadius: BorderRadius.circular(5),
                                          ),
                                          child: Image.network(
                                            item['imageUrl'],
                                            width: scaledWidth,
                                            height: scaledHeight,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        // Кнопка удаления внутри трансформации
                                        if (isSelected)
                                          Positioned(
                                            right: -10.sp,
                                            top: -10.sp,
                                            child: GestureDetector(
                                              onTap: () {
                                                controller.removeItemFromCanvas(index);
                                              },
                                              child: Container(
                                                width: 30.sp,
                                                height: 30.sp,
                                                decoration: BoxDecoration(
                                                  color: Palette.error,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.white, width: 2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.white,
                                                  size: 16.sp,
                                                ),
                                              ),
                                            ),
                                          ),
                                        // Кнопка управления размером/поворотом
                                        if (isSelected && (controller.currentMode.value == 'scale' || controller.currentMode.value == 'rotate'))
                                          Positioned(
                                            right: -10.sp,
                                            bottom: -10.sp,
                                            child: GestureDetector(
                                              onPanStart: null,
                                              onPanUpdate: (details) {
                                                // Обработка в зависимости от режима
                                                switch (controller.currentMode.value) {
                                                  case 'scale':
                                                    final currentScale = item['scale'] ?? 1.0;
                                                    final scaleChange = details.delta.dy * 0.01; // Убираем отрицательное значение - теперь вниз = увеличение, вверх = уменьшение
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
                                                width: 36.sp,
                                                height: 36.sp,
                                                decoration: BoxDecoration(
                                                  color: controller.currentMode.value == 'scale' ? Palette.red100 : Palette.red100,
                                                  borderRadius: BorderRadius.circular(15),
                                                  border: Border.all(color: Colors.white, width: 2),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.black26,
                                                      blurRadius: 4,
                                                      offset: Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: controller.currentMode.value == 'scale' 
                                                  ? SvgPicture.asset(
                                                      'assets/icons/patterns/svg/size.svg', 
                                                      color: Palette.white100,
                                                      width: 4.sp,
                                                      height: 4.sp,
                                                    )
                                                  : SvgPicture.asset(
                                                      'assets/icons/patterns/svg/krutilka.svg', 
                                                      color: Palette.white100,
                                                        width: 4.sp,
                                                      height: 4.sp,
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
                          ],
                        );
                      }),
                    ],
                  ),
                ),
                // Панель управления выбранным элементом
                Obx(() => controller.hasSelectedItem
                  ? Positioned(
                      left: 0,
                      right: 0,
                      bottom: 700.sp * controller.sheetSize.value - 5.sp,
                        child: Container(
                        padding: EdgeInsets.symmetric(vertical: 4.sp),
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 10.sp,
                          children: [
                            Container(
                              width: 50.sp,
                              height: 50.sp,
                              decoration: BoxDecoration(
                                color: controller.currentMode.value == 'move' ? Palette.red100 : Palette.red400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controller.setMode('move');
                                    },
                                    icon: SvgPicture.asset('assets/icons/patterns/svg/cursor.svg', color: controller.currentMode.value == 'move' ? Palette.white100 : Palette.red50,),),
                                ],
                              ),
                            ),
                            Container(
                              width: 50.sp,
                              height: 50.sp,
                              decoration: BoxDecoration(
                                color: controller.currentMode.value == 'scale' ? Palette.red100 : Palette.red400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      controller.setMode('scale');
                                    },
                                    icon: SvgPicture.asset('assets/icons/patterns/svg/size.svg', color: controller.currentMode.value == 'scale' ? Palette.white100 : Palette.red50,),),
                                ],
                              ),
                            ),
                            Container(
                              width: 50.sp,
                              height: 50.sp,
                              decoration: BoxDecoration(
                                color: controller.currentMode.value == 'rotate' ? Palette.red100 : Palette.red400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                  onPressed: () {
                                    controller.setMode('rotate');
                                  },
                                  icon: SvgPicture.asset('assets/icons/patterns/svg/krutilka.svg', color: controller.currentMode.value == 'rotate' ? Palette.white100 : Palette.red50,),),
                                ],
                              ),
                            ),
                            Container(
                              width: 50.sp,
                              height: 50.sp,
                              decoration: BoxDecoration(
                                color: controller.isSelectedItemAtFront ? Palette.red100 : Palette.red400,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: IconButton(
                                tooltip: 'Слои',
                                onPressed: () {
                                  controller.toggleLayer();
                                },
                                icon: SvgPicture.asset(
                                  'assets/icons/patterns/svg/sloi.svg',
                                  color: controller.isSelectedItemAtFront ? Palette.white100 : Palette.red50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SizedBox.shrink()),
                
                // Нижняя панель с гардеробом
                Obx(() => DraggableScrollableSheet(
                  controller: _scrollController,
                  initialChildSize: controller.sheetSize.value,
                  minChildSize: 0.3,
                  maxChildSize: 0.8,
                  snap: true,
                  snapSizes: [0.3, 0.4, 0.8],
                  builder: (context, scrollController) {
                    return GestureDetector(
                      onVerticalDragUpdate: (details) {
                        final newSize = controller.sheetSize.value - (details.delta.dy / context.height);
                        controller.updateSheetSize(newSize);
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.sp),
                        decoration: BoxDecoration(
                          color: Palette.red500,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ручка для перетаскивания
                            Container(
                              height: 30.sp,
                              child: Center(
                                child: Container(
                                  margin: EdgeInsets.symmetric(vertical: 8.sp),
                                  width: 40.sp,
                                  height: 4.sp,
                                  decoration: BoxDecoration(
                                    color: Palette.grey300,
                                    borderRadius: BorderRadius.circular(2.sp),
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              'Ваш гардероб',
                              style: TextStyles.titleLarge,
                            ),
                          SizedBox(height: 10.sp),
                            Container(
                              width: double.infinity,
                              height: 2.sp,
                              color: Palette.red400,
                            ),
                            SizedBox(height: 8.sp),
                            // Поиск
                            Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.sp),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (value) => wardrobeController.setSearchQuery(value),
                                style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                                onTapOutside: (event) => FocusScope.of(context).unfocus(),
                                decoration: InputDecoration(
                                  hintText: 'Поиск...',
                                  hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                  prefixIcon: Icon(Icons.search, color: Palette.grey350),
                                  filled: true,
                                  fillColor: Palette.red400,
                                  contentPadding: EdgeInsets.symmetric(vertical: 0.sp),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide(color: Palette.white100, width: 1.sp),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                              SizedBox(
                              height: 50.sp,
                              child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: categoriesWithAll.length,
                                itemBuilder: (context, index) {
                                  final category = categoriesWithAll[index];
                                  return Obx(() => Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      label: Text(category),
                                      selected: (category == 'Все' && wardrobeController.selectedCategory.value == '') ||
                                                (category != 'Все' && wardrobeController.selectedCategory.value == category),
                                      onSelected: (selected) {
                                        if (category == 'Все') {
                                          wardrobeController.setCategory('');
                                        } else {
                                          wardrobeController.setCategory(category);
                                        }
                                      },
                                      backgroundColor: Palette.red600,
                                      selectedColor: Palette.red100,
                                      side: BorderSide.none,
                                      showCheckmark: false,
                                      labelStyle: TextStyles.bodyMedium.copyWith(
                                        color: ((category == 'Все' && wardrobeController.selectedCategory.value == '') ||
                                               (category != 'Все' && wardrobeController.selectedCategory.value == category))
                                            ? Palette.white100
                                            : Palette.grey350,
                                      ),
                                    ),
                                  ));
                                },
                              ),
                            ),
                            Expanded(
                              child: Obx(() {
                                if (wardrobeController.isLoading.value) {
                                  return Center(child: CircularProgressIndicator());
                                }
                                if (wardrobeController.clothes.isEmpty) {
                                  return SingleChildScrollView(
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Image.asset('assets/icons/bottom_navigation/garderob.png', color: Palette.grey350),
                                            SizedBox(height: 12),
                                            Text('Ваша гардеробная пуста', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
                                            Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.sp),
                                              child: Text(
                                                'Здесь будут храниться все ваши вещи — от любимых джинсов до вечерних нарядов. Начните с малого — добавьте первую вещь!',
                                                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            ElevatedButton(
                                              onPressed: () {
                                                Get.to(() => AddingThing());
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.add, color: Palette.white100),
                                                  SizedBox(width: 8),
                                                  Text('Добавить одежду', style: TextStyles.buttonSmall.copyWith(color: Palette.white100)),
                                                ],
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Palette.red400,
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                                padding: EdgeInsets.symmetric(horizontal: 24.sp, vertical: 12.sp),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                } else {
                                  return GridView.builder(
                                    controller: scrollController,
                                    padding: const EdgeInsets.only(top: 16),
                                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 0.5,
                                    ),
                                    itemCount: wardrobeController.clothes.length,
                                    itemBuilder: (context, index) {
                                      final item = wardrobeController.clothes[index];
                                      return Draggable<Map<String, dynamic>>(
                                        data: {
                                          'imageUrl': item.imageUrl,
                                          'name': item.name,
                                          'position': {'x': 0.0, 'y': 0.0},
                                        },
                                        feedback: Image.network(
                                          item.imageUrl,
                                          width: 100.sp,
                                          height: 150.sp,
                                        ),
                                        childWhenDragging: SizedBox.shrink(),
                                        child: WardrobeCard(item: item),
                                      );
                                    },
                                  );
                                }
                              }),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

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

// CustomPainter для рамки
class _SelectionRectPainter extends CustomPainter {
  _SelectionRectPainter();
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }
  @override
  bool shouldRepaint(_SelectionRectPainter oldDelegate) => true;
}

// Кастомный GestureDetector для повернутых элементов
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
