import 'dart:io';
import 'dart:typed_data';
import 'package:doloooki/mobile/features/wardrobe_feature/constants/wardrobe_constants.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/controllers/wardrobe_controller.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/screens/wardrobe_screen.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class AddingThing extends StatefulWidget {
  final bool isEditing;
  final ClothesItem? clothesItem;
  
  AddingThing({
    super.key,
    this.isEditing = false,
    this.clothesItem,
  });

  @override
  State<AddingThing> createState() => _AddingThingState();
}

class _AddingThingState extends State<AddingThing> {
  // Controllers for main screen TextFields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Reactive variables for UI state
  final RxString _selectedCategory = ''.obs;
  final RxList<String> _selectedTags = <String>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _removeBg = false.obs;
  final Rx<Uint8List?> _previewImageBytes = Rx<Uint8List?>(null);

  // Controller instance
  final WardrobeController wardrobeController = Get.put(WardrobeController());

  // Focus states for main screen TextFields
  final RxBool _isNameFocused = false.obs;
  final RxBool _isDescriptionFocused = false.obs;

  void _setFocus(String field) {
    _isNameFocused.value = field == 'name';
    _isDescriptionFocused.value = field == 'description';
  }

  @override
  void initState() {
    super.initState();
    if (widget.isEditing && widget.clothesItem != null) {
      _nameController.text = widget.clothesItem!.name;
      _descriptionController.text = widget.clothesItem!.description;
      _selectedCategory.value = widget.clothesItem!.category;
      _selectedTags.value = List.from(widget.clothesItem!.tags);
      
      // Добавляем слушателей для отслеживания изменений при редактировании
      _nameController.addListener(_checkForChanges);
      _descriptionController.addListener(_checkForChanges);
      _selectedCategory.listen((_) => _checkForChanges());
      _selectedTags.listen((_) => _checkForChanges());
    } else {
      // Clear any existing image when opening the screen for new item
      wardrobeController.selectedImage.value = null;
      _previewImageBytes.value = null;
    }
    
    // Subscribe to changes in the selected image from the controller
    ever(wardrobeController.selectedImage, (File? image) {
      if (image != null) {
        _previewImageBytes.value = null; // Clear preview when a new image is selected
        // Automatically process image if removeBg is enabled
        if (_removeBg.value) {
          _processImage();
        }
      }
      // Проверяем изменения при смене изображения в режиме редактирования
      if (widget.isEditing) {
        _checkForChanges();
      }
    });
  }

  void _checkForChanges() {
    if (!widget.isEditing || widget.clothesItem == null) return;
    
    final currentItem = ClothesItem(
      id: widget.clothesItem!.id,
      imageUrl: widget.clothesItem!.imageUrl, // URL не меняется для проверки
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      category: _selectedCategory.value,
      tags: _selectedTags.toList(),
    );
    
    wardrobeController.checkForChanges(currentItem);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    // Clear the selected image when disposing the widget
    wardrobeController.selectedImage.value = null;
    _previewImageBytes.value = null;
    super.dispose();
  }

  Future<void> _processImage() async {
    if (wardrobeController.selectedImage.value == null) return;
    
    _isLoading.value = true;
    try {
      // Use controller method to remove background
      final imageBytes = await wardrobeController.removeBackground(wardrobeController.selectedImage.value!);
      if (imageBytes != null) {
        _previewImageBytes.value = imageBytes;
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось обработать изображение');
      // Clear the selected image on error
      wardrobeController.selectedImage.value = null;
      _previewImageBytes.value = null;
    } finally {
      _isLoading.value = false;
    }
  }

  void _showImagePickerBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 200.sp,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Palette.red600,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.sp),
            Container(
              width: 50.sp,
              height: 5.sp,
              decoration: BoxDecoration(
                color: Palette.grey300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            SizedBox(height: 20.sp),
            Text('Загрузка фотографии', style: TextStyles.titleLarge),
            SizedBox(height: 20.sp),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                    wardrobeController.pickImageFromCamera();
                  },
                  child: Container(
                    width: 150.sp,
                    height: 100.sp,
                    decoration: BoxDecoration(
                      color: Palette.red400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Palette.red100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/profile/camera.svg',
                                width: 20.sp,
                                height: 20.sp,
                                colorFilter: ColorFilter.mode(Palette.white100, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.sp),
                          Text('Камера', style: TextStyles.labelMedium),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Get.back();
                    wardrobeController.pickImage();
                  },
                  child: Container(
                    width: 150.sp,
                    height: 100.sp,
                    decoration: BoxDecoration(
                      color: Palette.red400,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Palette.red100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/profile/galery.svg',
                                width: 20.sp,
                                height: 20.sp,
                                colorFilter: ColorFilter.mode(Palette.white100, BlendMode.srcIn),
                              ),
                            ),
                          ),
                          SizedBox(height: 5.sp),
                          Text('Галерея', style: TextStyles.labelMedium),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showCategoryBottomSheet() {
    Get.bottomSheet(
      Container(
        height: 600.sp,
        padding: EdgeInsets.all(16.sp),
        decoration: BoxDecoration(
          color: Palette.red600,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  width: 50.sp,
                  height: 5.sp,
                  decoration: BoxDecoration(
                    color: Palette.grey300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              SizedBox(height: 20.sp),
              Text('Выберите категорию', style: TextStyles.titleLarge),
              SizedBox(height: 20.sp),
              ...WardrobeConstants.categories.map((category) => 
                GestureDetector(
                  onTap: () {
                    _selectedCategory.value = category;
                    Get.back();
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.sp),
                    child: Row(
                      children: [
                        Container(
                          width: 24.sp,
                          height: 24.sp,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: _selectedCategory.value == category ? Palette.red100 : Palette.grey350,
                              width: 2,
                            ),
                            color: _selectedCategory.value == category ? Palette.red100 : Colors.transparent,
                          ),
                          child: _selectedCategory.value == category
                              ? Icon(
                                  Icons.check,
                                  size: 16.sp,
                                  color: Palette.white100,
                                )
                              : null,
                        ),
                        SizedBox(width: 12.sp),
                        Text(
                          category,
                          style: TextStyles.bodyLarge.copyWith(
                            color: Palette.white200,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ).toList(),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Инициализируем отслеживание изменений при редактировании
    if (widget.isEditing && widget.clothesItem != null) {
      wardrobeController.startEditingItem(widget.clothesItem!.id);
    }
    
    return WillPopScope(
      onWillPop: () async {
        if (widget.isEditing) {
          final shouldPop = await wardrobeController.showUnsavedChangesDialog();
          if (shouldPop) {
            wardrobeController.clearEditingState();
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
            widget.isEditing ? 'Редактирование' : 'Добавление одежды',
            style: TextStyles.titleLarge.copyWith(color: Palette.white100)
          ),
          leading: Container(
            decoration: BoxDecoration(
              color: Palette.red400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: IconButton(
              onPressed: () async {
                if (widget.isEditing) {
                  final shouldPop = await wardrobeController.showUnsavedChangesDialog();
                  if (shouldPop) {
                    wardrobeController.clearEditingState();
                    Get.back();
                  }
                } else {
                  Get.back();
                }
              },
              icon: Icon(Icons.arrow_back_ios_new, color: Palette.white100),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showImagePickerBottomSheet,
                child: Center(
                  child: Container(
                    height: Consts.screenHeight(context)*0.35,
                    width: Consts.screenWidth(context)*0.55,
                    decoration: BoxDecoration(
                      color: Palette.red400,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Obx(() {
                      if (wardrobeController.selectedImage.value == null && widget.clothesItem != null) {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            widget.clothesItem!.imageUrl,
                            fit: BoxFit.cover,
                          ),
                        );
                      } else if (wardrobeController.selectedImage.value == null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, size: 48, color: Palette.white100),
                              SizedBox(height: 8),
                            ],
                          ),
                        );
                      } else {
                        return ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _previewImageBytes.value != null
                              ? Image.memory(_previewImageBytes.value!, fit: BoxFit.cover)
                              : Image.file(wardrobeController.selectedImage.value!, fit: BoxFit.cover),
                        );
                      }
                    }),
                  ),
                ),
              ),
              SizedBox(height: 10,),
              Obx(() => wardrobeController.selectedImage.value == null 
                ? Center(
                    child: Text(
                      'Добавить фото',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)
                    )
                  )
                : Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(() => Checkbox(
                          checkColor: Palette.white100,
                          activeColor: Palette.red200,
                          value: _removeBg.value,
                          onChanged: (value) {
                            _removeBg.value = value ?? false;
                            if (_removeBg.value) {
                              _processImage();
                            } else {
                              _previewImageBytes.value = null;
                            }
                          },
                        )),
                        Text(
                          'Удалить фон',
                          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350)
                        ),
                        Obx(() => _isLoading.value 
                          ? Row(
                              children: [
                                const SizedBox(width: 8),
                                SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Palette.white100,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox.shrink()
                      ),
                    ],
                  ),
              ),),
              const SizedBox(height: 24),
              Text('Название одежды', style: TextStyles.labelMedium.copyWith(color:_isNameFocused.value? Palette.white100: Palette.grey350)),
              const SizedBox(height: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: _isNameFocused.value || _nameController.text.isNotEmpty 
                      ? Border.all(color: Palette.white200)
                      : Border.all(width: 0),
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _nameController,
                  onTap: () => _setFocus('name'),
                  onTapOutside: (_) {
                    _setFocus('');
                    FocusScope.of(Get.context!).unfocus();
                  },
                  style: TextStyles.bodyLarge.copyWith(
                    color: Palette.white200,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Введите название',
                    hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                    counterText: '',
                  ),
                ),
              )),
              const SizedBox(height: 24),
              Text('Описание', style: TextStyles.labelMedium.copyWith(color:_isDescriptionFocused.value? Palette.white100: Palette.grey350)),
              const SizedBox(height: 8),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  border: _isDescriptionFocused.value || _descriptionController.text.isNotEmpty 
                      ? Border.all(color: Palette.white200)
                      : Border.all(width: 0),
                  color: Palette.red400,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _descriptionController,
                  onTap: () => _setFocus('description'),
                  onTapOutside: (_) {
                    _setFocus('');
                    FocusScope.of(Get.context!).unfocus();
                  },
                  style: TextStyles.bodyLarge.copyWith(
                    color: Palette.white200,
                  ),
                  maxLines: 3,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Введите описание',
                    hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                    counterText: '',
                  ),
                ),
              )),
              const SizedBox(height: 24),
              Text('Категория', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
              const SizedBox(height: 8),
              Obx(() => GestureDetector(
                onTap: () => _showCategoryBottomSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: _selectedCategory.value.isNotEmpty 
                        ? Border.all(color: Palette.white200)
                        : Border.all(width: 0),
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _selectedCategory.value.isEmpty 
                            ? 'Выберите категорию'
                            : _selectedCategory.value,
                        style: TextStyles.bodyLarge.copyWith(
                          color: _selectedCategory.value.isEmpty 
                              ? Palette.grey350 
                              : Palette.white200,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: Palette.white200),
                    ],
                  ),
                ),
              )),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Теги', style: TextStyles.labelMedium.copyWith(color: Palette.grey350)),
                  ElevatedButton(
                    style: ButtonStyles.outlined,
                    onPressed: () {
                      // Controllers and FocusNode for bottom sheet tag input - declared here to be local to the bottom sheet
                      final TextEditingController tagController = TextEditingController();
                      final FocusNode tagFocusNode = FocusNode();
                      
                      // Set focus state in controller when bottom sheet opens
                      
                      Get.bottomSheet(
                        Container(
                          height: 230.sp,
                          padding: EdgeInsets.all(16.sp),
                          decoration: BoxDecoration(
                            color: Palette.red600,
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                          ),
                          child: GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () => FocusScope.of(Get.context!).unfocus(),
                            child: SingleChildScrollView(
                              padding: EdgeInsets.only(bottom: MediaQuery.of(Get.context!).viewInsets.bottom),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 50.sp,
                                      height: 5.sp,
                                      decoration: BoxDecoration(
                                        color: Palette.grey300,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                  ),
                                  Text('Новый тег', style: TextStyles.titleLarge.copyWith(color: Palette.white100)),
                                  SizedBox(height: 15.sp),
                                  // Tag name text with reactive color
                                  Obx(() => Text('Название тега', style: TextStyles.labelMedium.copyWith(color: wardrobeController.isTagFocused.value ? Palette.white100 : Palette.grey350))),
                                  SizedBox(height: 10.sp),
                                  // Tag input field with reactive border
                                  Obx(() => Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 4.sp),
                                    decoration: BoxDecoration(
                                      border: wardrobeController.isTagFocused.value || tagController.text.isNotEmpty 
                                          ? Border.all(color: Palette.white200)
                                          : Border.all(width: 0),
                                      color: Palette.red400,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: TextField(
                                      controller: tagController,
                                      focusNode: tagFocusNode,
                                      // No autofocus here
                                      // Handle focus state on tap
                                      onTap: () => wardrobeController.setTagFocus(true),
                                      // Handle focus state on tap outside
                                      onTapOutside: (_) {
                                        wardrobeController.setTagFocus(false);
                                        tagFocusNode.unfocus();
                                      },
                                      style: TextStyles.bodyLarge.copyWith(
                                        color: Palette.white200,
                                      ),
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: 'Например: праздничное...',
                                        hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                      ),
                                    ),
                                  )),
                                  SizedBox(height: 20.sp),
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      style: ButtonStyles.primary,
                                      // Add tag on press, wait for result, and close only on success
                                      onPressed: () async {
                                        if (tagController.text.trim().isNotEmpty) {
                                          final success = await wardrobeController.addCustomTag(tagController.text); // Wait for result
                                          if (success) {
                                            Get.back(); // Close only on success
                                          }
                                        }
                                      },
                                      child: Text('Добавить', style: TextStyles.buttonMedium.copyWith(color: Palette.white100)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ).then((_) {
                        // Reset focus state when bottom sheet closes
                        wardrobeController.setTagFocus(false);
                        // Safely dispose controllers/focus node
                        if (tagFocusNode.hasFocus) {
                          tagFocusNode.unfocus();
                        }
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          tagController.dispose();
                          tagFocusNode.dispose();
                        });
                      });
                    },
                    child: Row(
                      children: [
                        Icon(Icons.add, size: 15.sp, color: Palette.white200),
                        SizedBox(width: 4.sp),
                        Text('Добавить', style: TextStyles.buttonExtraSmall)
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Obx(() => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: wardrobeController.tags.map((tag) {
                  return Obx(() => FilterChip(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide.none,
                    showCheckmark: false,
                    label: Text(tag),
                    selected: _selectedTags.contains(tag),
                    onSelected: (selected) {
                      if (selected) {
                        _selectedTags.add(tag);
                      } else {
                        _selectedTags.remove(tag);
                      }
                    },
                    backgroundColor: Palette.red400,
                    selectedColor: Palette.red100,
                    labelStyle: TextStyles.titleSmall.copyWith(
                      color: _selectedTags.contains(tag) ? Palette.white100 : Palette.white200,
                    ),
                  ));
                }).toList(),
              )),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                  style: ButtonStyles.primary,
                  onPressed: _isLoading.value ? null : _saveItem,
                  child: _isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Palette.white100,
                            strokeWidth: 2,
                          ),
                        )
                      : Text('Сохранить', style: TextStyles.buttonMedium.copyWith(color: Palette.white100)),
                )),
              ),
            ]
          ),
        ),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (_isLoading.value) return; // Prevent multiple clicks

    if (!widget.isEditing && wardrobeController.selectedImage.value == null) {
      Get.snackbar('Ошибка', 'Выберите изображение');
      return;
    }

    if (_nameController.text.trim().isEmpty) {
      Get.snackbar('Ошибка', 'Введите название');
      return;
    }
    if (_selectedCategory.value.isEmpty) {
      Get.snackbar('Ошибка', 'Выберите категорию');
      return;
    }
    if (_selectedTags.isEmpty) {
      Get.snackbar('Ошибка', 'Выберите теги');
      return;
    }

    _isLoading.value = true;

    try {
      String imageUrl;
      if (widget.isEditing) {
        if (wardrobeController.selectedImage.value == null) {
          imageUrl = widget.clothesItem!.imageUrl;
        } else {
          if (_removeBg.value) {
            final imageBytes = await wardrobeController.removeBackground(wardrobeController.selectedImage.value!);
            if (imageBytes == null) {
              _isLoading.value = false;
              return;
            }
            final tempFile = File('${wardrobeController.selectedImage.value!.path}_nobg.png');
            await tempFile.writeAsBytes(imageBytes);
            imageUrl = await wardrobeController.uploadImage(tempFile);
            await tempFile.delete();
          } else {
            imageUrl = await wardrobeController.uploadImage(wardrobeController.selectedImage.value!);
          }
        }
      } else {
        if (_removeBg.value) {
          final imageBytes = await wardrobeController.removeBackground(wardrobeController.selectedImage.value!);
          if (imageBytes == null) {
            _isLoading.value = false;
            return;
          }
          final tempFile = File('${wardrobeController.selectedImage.value!.path}_nobg.png');
          await tempFile.writeAsBytes(imageBytes);
          imageUrl = await wardrobeController.uploadImage(tempFile);
          await tempFile.delete();
        } else {
          imageUrl = await wardrobeController.uploadImage(wardrobeController.selectedImage.value!);
        }
      }

      final user = wardrobeController.auth.currentUser;
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      final item = ClothesItem(
        id: widget.isEditing ? widget.clothesItem!.id : const Uuid().v4(),
        imageUrl: imageUrl,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory.value,
        tags: _selectedTags.toList(),
      );

      if (widget.isEditing) {
        await wardrobeController.updateClothes(item);
      } else {
        await wardrobeController.addClothes(item);
      }
      
      // Очищаем выбранное изображение после сохранения
      wardrobeController.selectedImage.value = null;
      
     // Close screen only after successful save
    } catch (e) {
      print('Error saving item: $e');
      Get.snackbar('Ошибка', 'Не удалось сохранить вещь: ${e.toString()}');
    } finally {
      _isLoading.value = false;
    }
  }
}