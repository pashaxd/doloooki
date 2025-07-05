import 'package:get/get.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/recomendations_service.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/colors_service.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

enum RecViewMode {
  main,      // Основной экран с превью
  patterns,  // Все образы 
  colors     // Все палитры
}

class RecController extends GetxController with GetSingleTickerProviderStateMixin {
  final RecomendationsService _recomendationsService = RecomendationsService();
  final ColorsService _colorsService = ColorsService();
  
  // Популярные образы (рекомендационные категории)
  final RxList<PopularModel> popularModels = <PopularModel>[].obs;
  
  // Цветовые палитры
  final RxList<ColorsModel> colorsModels = <ColorsModel>[].obs;
  
  // Состояние загрузки
  final RxBool isLoadingPatterns = false.obs;
  final RxBool isLoadingColors = false.obs;
  final RxString error = ''.obs;
  
  // Подписки на потоки данных
  StreamSubscription? _popularModelsSubscription;
  StreamSubscription? _colorsModelsSubscription;
  
  // Режим просмотра
  final Rx<RecViewMode> currentView = RecViewMode.main.obs;
  
  // Выбранные элементы для детального просмотра
  final Rx<PopularModel?> selectedPopularModel = Rx<PopularModel?>(null);
  final Rx<ColorsModel?> selectedColorsModel = Rx<ColorsModel?>(null);

  // Флаг инициализации
  bool get initialized => !isLoadingPatterns.value && !isLoadingColors.value;

  @override
  void onInit() {
    super.onInit();
    loadPopularModels();
    loadColorsModels();
  }

  @override
  void onClose() {
    _popularModelsSubscription?.cancel();
    _colorsModelsSubscription?.cancel();
    super.onClose();
  }

  // Навигация между режимами
  void navigateToPatterns() {
    currentView.value = RecViewMode.patterns;
    selectedPopularModel.value = null; // Сбрасываем выбранный элемент
  }

  void navigateToColors() {
    currentView.value = RecViewMode.colors;
    selectedColorsModel.value = null; // Сбрасываем выбранный элемент
  }

  void backToMain() {
    currentView.value = RecViewMode.main;
    selectedPopularModel.value = null;
    selectedColorsModel.value = null;
  }

  // Загрузка популярных образов
  void loadPopularModels() {
    isLoadingPatterns.value = true;
    error.value = '';
    
    _popularModelsSubscription = _recomendationsService.getPopularModelsStream().listen(
      (models) {
        popularModels.value = models;
        isLoadingPatterns.value = false;
        error.value = '';
        print('✅ Загружено рекомендационных категорий: ${models.length}');
        for (var model in models) {
          print('📋 Категория: ${model.name} с ${model.patterns.length} паттернами');
        }
      },
      onError: (e) {
        error.value = 'Ошибка загрузки образов: $e';
        isLoadingPatterns.value = false;
        print('❌ Ошибка загрузки популярных моделей: $e');
      },
    );
  }

  // Загрузка цветовых палитр
  void loadColorsModels() {
    isLoadingColors.value = true;
    
    _colorsModelsSubscription = _colorsService.getColorsModelsStream().listen(
      (models) {
        colorsModels.value = models;
        isLoadingColors.value = false;
        print('✅ Загружено цветовых моделей: ${models.length}');
      },
      onError: (e) {
        print('❌ Ошибка загрузки цветовых моделей: $e');
        isLoadingColors.value = false;
      },
    );
  }

  // Выбор рекомендационной категории для детального просмотра
  void selectPopularModel(PopularModel? model) {
    selectedPopularModel.value = model;
    print('🎨 Выбрана категория: ${model?.name ?? "нет"}');
  }

  // Выбор цветовой палитры для детального просмотра
  void selectColorsModel(ColorsModel? colorsModel) {
    selectedColorsModel.value = colorsModel;
    print('🎨 Выбрана палитра: ${colorsModel?.name ?? "нет"}');
  }

  // Обновление данных
  Future<void> refreshData() async {
    try {
      print('🔄 Обновление данных рекомендаций...');
      
      // Обновляем популярные модели
      isLoadingPatterns.value = true;
      final patterns = await _recomendationsService.getPopularModels();
      popularModels.value = patterns;
      
      // Обновляем цветовые модели
      isLoadingColors.value = true;
      final colors = await _colorsService.getColorsModels();
      colorsModels.value = colors;
      
      error.value = '';
      print('✅ Данные рекомендаций обновлены');
      
    } catch (e) {
      error.value = 'Ошибка обновления: $e';
      print('❌ Ошибка обновления данных: $e');
    } finally {
      isLoadingPatterns.value = false;
      isLoadingColors.value = false;
    }
  }

  // Форматирование даты
  String formatDate(DateTime date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.day} ${months[date.month - 1]}';
  }

  // Получение цвета по hex строке
  int getColorFromHex(String hexColor) {
    try {
      // Убираем все символы # из строки
      String cleanColor = hexColor.replaceAll('#', '');
      
      // Если длина меньше 6 символов, дополняем нулями
      if (cleanColor.length == 3) {
        cleanColor = cleanColor.split('').map((char) => char + char).join();
      }
      
      // Добавляем альфа-канал если его нет
      if (cleanColor.length == 6) {
        cleanColor = 'FF' + cleanColor;
      }
      
      // Парсим цвет
      return int.parse(cleanColor, radix: 16);
    } catch (e) {
      print('Ошибка парсинга цвета $hexColor: $e');
      // Возвращаем серый цвет по умолчанию в случае ошибки
      return 0xFF808080; // Серый цвет
    }
  }

  // Получение изображения для рекомендационной категории (первый паттерн)
  String getPopularModelImage(PopularModel model) {
    if (model.patterns.isNotEmpty) {
      return model.patterns.first.imageUrl;
    }
    return ''; // Возвращаем пустую строку если нет паттернов
  }

  // Удаление категории образов
  Future<void> deletePatternCategory(PopularModel model) async {
    try {
      final confirmed = await _showDeleteConfirmationDialog(
        title: 'Удалить категорию образов?',
        content: 'Категория "${model.name}" будет удалена безвозвратно.\nВсе образы в этой категории также будут удалены.',
      );

      if (!confirmed) return;

      // Удаляем документ из Firestore
      await FirebaseFirestore.instance
          .collection('recPatterns')
          .doc(model.id)
          .delete();

      // Показываем уведомление об успешном удалении
      Get.snackbar(
        'Успех',
        'Категория образов "${model.name}" удалена',
        backgroundColor: Palette.success,
        colorText: Palette.white100,
        duration: Duration(seconds: 3),
      );

      // Возвращаемся к главному экрану
      backToMain();
      
      print('✅ Категория образов "${model.name}" успешно удалена');
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось удалить категорию: $e',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
        duration: Duration(seconds: 5),
      );
      
      print('❌ Ошибка удаления категории образов: $e');
    }
  }

  // Удаление цветовой палитры
  Future<void> deleteColorPalette(ColorsModel model) async {
    try {
      final confirmed = await _showDeleteConfirmationDialog(
        title: 'Удалить цветовую палитру?',
        content: 'Палитра "${model.name}" будет удалена безвозвратно.\nВсе цвета и комбинации будут потеряны.',
      );

      if (!confirmed) return;

      // Удаляем документ из Firestore
      await FirebaseFirestore.instance
          .collection('recColors')
          .doc(model.id)
          .delete();

      // Показываем уведомление об успешном удалении
      Get.snackbar(
        'Успех',
        'Цветовая палитра "${model.name}" удалена',
        backgroundColor: Palette.success,
        colorText: Palette.white100,
        duration: Duration(seconds: 3),
      );

      // Возвращаемся к главному экрану
      backToMain();
      
      print('✅ Цветовая палитра "${model.name}" успешно удалена');
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось удалить палитру: $e',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
        duration: Duration(seconds: 5),
      );
      
      print('❌ Ошибка удаления цветовой палитры: $e');
    }
  }

  // Создание цветовой палитры
  Future<void> createColorPalette({
    required String name,
    required String description,
    required List<String> colors,
    required List<String> combinations,
  }) async {
    try {
      // Валидация данных
      if (name.trim().isEmpty) {
        throw Exception('Название палитры не может быть пустым');
      }

      if (colors.length < 4) {
        throw Exception('Добавьте минимум 4 цвета');
      }

      if (combinations.isEmpty) {
        throw Exception('Добавьте минимум одну комбинацию');
      }

      // Валидация цветов
      for (final color in colors) {
        if (!_isValidHexColor(color)) {
          throw Exception('Неверный формат цвета: $color');
        }
      }

      // Валидация комбинаций
      for (final combination in combinations) {
        final colorsList = combination.split(',').map((c) => c.trim()).toList();
        if (colorsList.length != 4) {
          throw Exception('Каждая комбинация должна содержать 4 цвета');
        }
        
        for (final color in colorsList) {
          if (!_isValidHexColor(color)) {
            throw Exception('Неверный формат цвета в комбинации: $color');
          }
        }
      }

      // Создаем документ в Firestore
      final paletteDoc = FirebaseFirestore.instance.collection('recColors').doc();
      
      await paletteDoc.set({
        'name': name.trim(),
        'description': description.trim(),
        'colors': colors,
        'combinations': combinations,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('✅ Цветовая палитра "$name" успешно создана');
      
    } catch (e) {
      print('❌ Ошибка создания цветовой палитры: $e');
      rethrow;
    }
  }

  // Валидация HEX цвета
  bool _isValidHexColor(String hexColor) {
    if (hexColor.isEmpty) return false;
    
    // Убираем # если есть
    final cleanColor = hexColor.replaceAll('#', '');
    
    // Проверяем длину (должно быть 6 символов)
    if (cleanColor.length != 6) return false;
    
    // Проверяем, что все символы - валидные hex символы
    return RegExp(r'^[0-9A-Fa-f]+$').hasMatch(cleanColor);
  }

  // Получение статистики цветовых палитр
  Map<String, int> getColorPaletteStats() {
    int totalColors = 0;
    int totalCombinations = 0;
    
    for (final palette in colorsModels) {
      totalColors += palette.colors.length;
      totalCombinations += palette.combinations.length;
    }
    
    return {
      'palettes': colorsModels.length,
      'colors': totalColors,
      'combinations': totalCombinations,
    };
  }

  // Поиск палитр по названию
  List<ColorsModel> searchColorPalettes(String query) {
    if (query.trim().isEmpty) return colorsModels;
    
    final lowercaseQuery = query.toLowerCase();
    return colorsModels.where((palette) {
      return palette.name.toLowerCase().contains(lowercaseQuery) ||
             palette.description.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  // Проверка, используется ли цвет в палитрах
  bool isColorUsedInPalettes(String hexColor) {
    for (final palette in colorsModels) {
      if (palette.colors.contains(hexColor)) return true;
      
      for (final combination in palette.combinations) {
        if (combination.contains(hexColor)) return true;
      }
    }
    return false;
  }

  // Получение популярных цветов
  List<String> getPopularColors({int limit = 10}) {
    final colorFrequency = <String, int>{};
    
    for (final palette in colorsModels) {
      for (final color in palette.colors) {
        colorFrequency[color] = (colorFrequency[color] ?? 0) + 1;
      }
      
      for (final combination in palette.combinations) {
        final colors = combination.split(',').map((c) => c.trim()).toList();
        for (final color in colors) {
          colorFrequency[color] = (colorFrequency[color] ?? 0) + 1;
        }
      }
    }
    
    final sortedColors = colorFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedColors.take(limit).map((entry) => entry.key).toList();
  }

  // Диалог подтверждения удаления
  Future<bool> _showDeleteConfirmationDialog({
    required String title,
    required String content,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        backgroundColor: Palette.red500,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          title,
          style: TextStyles.titleMedium.copyWith(color: Palette.white100),
        ),
        content: Text(
          content,
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
              'Удалить',
              style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );

    return result ?? false;
  }
}
