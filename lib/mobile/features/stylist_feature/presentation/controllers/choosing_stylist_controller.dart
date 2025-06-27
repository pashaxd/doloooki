import 'package:get/get.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/stylist_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/services/stylist_service.dart';
import 'dart:math';

class ChoosingStylistController extends GetxController {
  final StylistService _stylistService = StylistService();
  
  final RxList<StylistModel> stylists = <StylistModel>[].obs;
  final RxBool isLoading = false.obs;
  final Rx<StylistModel?> selectedStylist = Rx<StylistModel?>(null);
  final RxBool isRandomSelection = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadStylists();
  }

  Future<void> loadStylists() async {
    try {
      print('🚀 Starting to load stylists...');
      isLoading.value = true;
      final fetchedStylists = await _stylistService.getAllStylists();
      print('📦 Received ${fetchedStylists.length} stylists from service');
      stylists.value = fetchedStylists;
      print('✅ Stylists loaded successfully: ${stylists.length} items');
      
      // Выводим информацию о каждом стилисте
      for (var stylist in stylists) {
        print('👤 Stylist: ${stylist.name} - ${stylist.shortDescription}');
      }
    } catch (e) {
      print('❌ Error in loadStylists: $e');
      Get.snackbar('Ошибка', 'Не удалось загрузить список стилистов: $e');
    } finally {
      isLoading.value = false;
      print('🏁 Loading finished. Final count: ${stylists.length}');
    }
  }

  void selectStylist(StylistModel stylist) {
    selectedStylist.value = stylist;
    isRandomSelection.value = false;
  }
  
  void selectRandomStylist() {
    if (stylists.isEmpty) return;
    
    // Если уже выбран случайный стилист, отменяем выбор
    if (isRandomSelection.value) {
      isRandomSelection.value = false;
      selectedStylist.value = null;
      return;
    }
    
    // Отменяем выбор конкретного стилиста
    selectedStylist.value = null;
    isRandomSelection.value = true;
  }

  double getAverageRating(StylistModel stylist) {
    return _stylistService.calculateAverageRating(stylist.reviews);
  }

  bool get isSelectionMade => selectedStylist.value != null || isRandomSelection.value;

  void confirmSelection() {
    if (isRandomSelection.value) {
      // Выбираем случайного стилиста
      if (stylists.isNotEmpty) {
        final random = Random();
        final randomIndex = random.nextInt(stylists.length);
        final randomStylist = stylists[randomIndex];
        
        Get.back(result: {'type': 'random', 'stylist': randomStylist});
      }
    } else if (selectedStylist.value != null) {
      Get.back(result: {'type': 'manual', 'stylist': selectedStylist.value});
    }
  }
} 