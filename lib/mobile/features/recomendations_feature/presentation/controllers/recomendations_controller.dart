import 'package:get/get.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/recomendations_service.dart';
import 'dart:async';

class RecomendationsController extends GetxController {
  final RecomendationsService _service = RecomendationsService();
  
  final RxList<PopularModel> popularModels = <PopularModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  StreamSubscription? _popularModelsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadPopularModels();
  }

  @override
  void onClose() {
    _popularModelsSubscription?.cancel();
    super.onClose();
  }

  void loadPopularModels() {
    isLoading.value = true;
    error.value = '';
    
    _popularModelsSubscription = _service.getPopularModelsStream().listen(
      (models) {
        popularModels.value = models;
        isLoading.value = false;
        error.value = '';
      },
      onError: (e) {
        error.value = 'Ошибка загрузки: $e';
        isLoading.value = false;
        print('Error in stream: $e');
      },
    );
  }

  Future<void> refreshPopularModels() async {
    try {
      isLoading.value = true;
      error.value = '';
      final models = await _service.getPopularModels();
      popularModels.value = models;
    } catch (e) {
      error.value = 'Ошибка обновления: $e';
      print('Error refreshing: $e');
    } finally {
      isLoading.value = false;
    }
  }
} 