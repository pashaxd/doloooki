import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/colors_service.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/recomendations_service.dart';
import 'dart:async';

class ColorsController extends GetxController {
  final ColorsService _service = ColorsService();
  
  final RxList<ColorsModel> colorsModels = <ColorsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  StreamSubscription? _colorsModelsSubscription;

  @override
  void onInit() {
    super.onInit();
    loadColorsModels();
  }

  @override
  void onClose() {
    _colorsModelsSubscription?.cancel();
    super.onClose();
  }

  void loadColorsModels() {
    isLoading.value = true;
    error.value = '';
    
    _colorsModelsSubscription = _service.getColorsModelsStream().listen(
      (models) {
        colorsModels.value = models;
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

  Future<void> refreshColorsModels() async {
    loadColorsModels();
  }
}