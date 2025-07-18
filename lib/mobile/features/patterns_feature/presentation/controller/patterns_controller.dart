import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'dart:async';

class PatternsListController extends GetxController {
  final RxList<PatternItem> patterns = <PatternItem>[].obs;
  final RxBool isLoading = false.obs;
  StreamSubscription<User?>? _authSubscription;

  @override
  void onInit() {
    super.onInit();
    
    // Слушаем изменения состояния авторизации
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user == null) {
        // Пользователь вышел из системы, очищаем данные
        patterns.clear();
        isLoading.value = false;
      } else {
        // Пользователь вошел в систему, загружаем паттерны с задержкой
        _fetchPatternsWithDelay();
      }
    });
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }

  Future<void> fetchPatterns() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      patterns.clear();
      return;
    }

    isLoading.value = true;
    try {
      final snapshot = await FirebaseFirestore.instance
           .collection('users')
          .doc(user.uid)
          .collection('patterns')
          .orderBy('createdAt', descending: true)
          .get();

      patterns.value = snapshot.docs
          .map((doc) => PatternItem.fromMap(doc.data()))
          .toList();
      print(patterns.value);
    } catch (e) {
      print('Ошибка загрузки паттернов: $e');
      if (e.toString().contains('permission-denied')) {
        // Если нет прав доступа, очищаем паттерны
        patterns.clear();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPatternsWithDelay() async {
    // Ждем 500мс для синхронизации Firebase Auth токена с Firestore
    await Future.delayed(Duration(milliseconds: 500));
    
    try {
      await fetchPatterns();
    } catch (e) {
      print('⚠️ Ошибка загрузки паттернов: $e');
      if (e.toString().contains('permission-denied')) {
        // Повторная попытка через секунду
        await Future.delayed(Duration(seconds: 1));
        try {
          await fetchPatterns();
        } catch (e2) {
          print('⚠️ Повторная попытка загрузки паттернов также не удалась: $e2');
          patterns.clear();
          isLoading.value = false;
        }
      }
    }
  }

  bool isDataReady() {
    return !isLoading.value;
  }

  Future<void> deletePattern(String patternId) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('patterns')
          .doc(patternId)
          .delete();

      // Удаляем из локального списка
      patterns.removeWhere((pattern) => pattern.id == patternId);
    } catch (e) {
      print('Ошибка удаления паттерна: $e');
      if (e.toString().contains('permission-denied')) {
        patterns.clear();
      }
      rethrow;
    }
  }

  Future<void> refreshPatterns() async {
    await fetchPatterns();
  }
}