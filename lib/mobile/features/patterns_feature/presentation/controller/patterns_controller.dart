import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

class PatternsListController extends GetxController {
  final RxList<PatternItem> patterns = <PatternItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPatterns();
  }

  Future<void> fetchPatterns() async {
    isLoading.value = true;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
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
    } finally {
      isLoading.value = false;
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
      rethrow;
    }
  }

  Future<void> refreshPatterns() async {
    await fetchPatterns();
  }
}