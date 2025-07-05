import 'package:get/get.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/services/recomendations_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class RecomendationsController extends GetxController {
  final RecomendationsService _service = RecomendationsService();
  
  final RxList<PopularModel> popularModels = <PopularModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  
  StreamSubscription? _popularModelsSubscription;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Слушаем изменения состояния авторизации
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Пользователь вышел из системы, отменяем подписки и очищаем данные
        _popularModelsSubscription?.cancel();
        popularModels.clear();
        isLoading.value = false;
        error.value = '';
      } else {
        // Пользователь вошел в систему, загружаем рекомендации
        loadPopularModels();
      }
    });
  }

  @override
  void onClose() {
    _popularModelsSubscription?.cancel();
    _authSubscription?.cancel();
    super.onClose();
  }

  void loadPopularModels() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      popularModels.clear();
      return;
    }

    isLoading.value = true;
    error.value = '';
    
    _popularModelsSubscription?.cancel(); // Отменяем предыдущую подписку
    
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
        if (e.toString().contains('permission-denied')) {
          // Если нет прав доступа, очищаем данные
          popularModels.clear();
        }
      },
    );
  }

  Future<void> refreshPopularModels() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      popularModels.clear();
      return;
    }

    try {
      isLoading.value = true;
      error.value = '';
      final models = await _service.getPopularModels();
      popularModels.value = models;
    } catch (e) {
      error.value = 'Ошибка обновления: $e';
      print('Error refreshing: $e');
      if (e.toString().contains('permission-denied')) {
        popularModels.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }
} 