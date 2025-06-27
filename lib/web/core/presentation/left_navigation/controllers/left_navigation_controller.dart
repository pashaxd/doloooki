import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeftNavigationController extends GetxController {
  final RxInt selectedIndex = 2.obs;
  final RxBool isOpen = true.obs;
  
  // Добавляем поля для данных стилиста
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final RxString stylistName = ''.obs;
  final RxString stylistEmail = ''.obs;
  final RxString stylistSurname = ''.obs;
  final RxBool isLoadingStylistData = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadStylistData();
  }

  void toggleMenu() {
    isOpen.value = !isOpen.value;
  }

  void changeIndex(int index) {
    selectedIndex.value = index;
    
    // Если переключились на экран настроек (индекс 3), обновляем данные стилиста
    if (index == 3) {
      refreshStylistData();
    }
  }

  // Метод для загрузки данных стилиста
  Future<void> loadStylistData() async {
    try {
      isLoadingStylistData.value = true;
      
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        print('❌ Пользователь не авторизован');
        return;
      }
      
      stylistEmail.value = currentUser.email ?? '';
      
      // Получаем данные стилиста из коллекции stylists
      final stylistDoc = await _firestore
          .collection('stylists')
          .doc(currentUser.uid)
          .get();
      
      if (stylistDoc.exists) {
        final data = stylistDoc.data() as Map<String, dynamic>;
        
        stylistName.value = data['name'] ?? '';
        stylistSurname.value = data['surname'] ?? '';
        
        print('✅ Данные стилиста загружены: ${stylistName.value} ${stylistSurname.value}');
      } else {
        print('⚠️ Документ стилиста не найден');
      }
      
    } catch (e) {
      print('❌ Ошибка загрузки данных стилиста: $e');
    } finally {
      isLoadingStylistData.value = false;
    }
  }

  // Метод для принудительного обновления данных стилиста
  Future<void> refreshStylistData() async {
    await loadStylistData();
  }

  // Геттер для полного имени стилиста
  String get fullStylistName {
    if (stylistName.value.isEmpty && stylistSurname.value.isEmpty) {
      return 'Стилист';
    }
    return '${stylistName.value} ${stylistSurname.value}'.trim();
  }
}