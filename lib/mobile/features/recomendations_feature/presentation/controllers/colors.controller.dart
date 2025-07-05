import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/colors_service.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/recomendations_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class ColorsController extends GetxController {
  final ColorsService _service = ColorsService();
  
  final RxList<ColorsModel> colorsModels = <ColorsModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  StreamSubscription? _colorsModelsSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Слушаем изменения состояния авторизации
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Пользователь вышел из системы, отменяем подписки и очищаем данные
        _colorsModelsSubscription?.cancel();
        colorsModels.clear();
        isLoading.value = false;
        error.value = '';
      } else {
        // Пользователь вошел в систему, загружаем цвета
        loadColorsModels();
      }
    });
  }

  @override
  void onClose() {
    _colorsModelsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  void loadColorsModels() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      colorsModels.clear();
      return;
    }

    isLoading.value = true;
    error.value = '';
    
    _colorsModelsSubscription?.cancel(); // Отменяем предыдущую подписку
    
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
        if (e.toString().contains('permission-denied')) {
          // Если нет прав доступа, очищаем данные
          colorsModels.clear();
        }
      },
    );
  }

  Future<void> refreshColorsModels() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      colorsModels.clear();
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      loadColorsModels();
    } catch (e) {
      error.value = 'Ошибка обновления: $e';
      print('Error refreshing: $e');
      if (e.toString().contains('permission-denied')) {
        colorsModels.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }
}