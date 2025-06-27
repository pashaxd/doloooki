import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

enum ViewMode { profile, wardrobe, patterns }

class UserInfoController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ID пользователя, информацию о котором нужно показать
  String? targetUserId;
  
  // Режим просмотра
  final Rx<ViewMode> currentView = ViewMode.profile.obs;
  
  // Реактивные переменные
  final Rx<Map<String, dynamic>?> userProfile = Rx<Map<String, dynamic>?>(null);
  final RxList<ClothesItem> recentClothes = <ClothesItem>[].obs;
  final RxList<ClothesItem> allClothes = <ClothesItem>[].obs; // Все вещи для детального просмотра
  final RxList<PatternItem> recentPatterns = <PatternItem>[].obs;
  final RxList<PatternItem> allPatterns = <PatternItem>[].obs; // Все образы для детального просмотра
  final RxInt totalClothes = 0.obs;
  final RxInt totalPatterns = 0.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    // Получаем ID пользователя из аргументов или используем текущего
    final args = Get.arguments;
    if (args != null && args is Map && args.containsKey('userId')) {
      targetUserId = args['userId'];
      print('🎯 Загружаем информацию о пользователе: $targetUserId');
    }
    
    loadUserData();
  }

  // Метод для установки ID пользователя и загрузки его данных
  void setTargetUser(String userId) {
    targetUserId = userId;
    print('🔄 Переключаемся на пользователя: $userId');
    loadUserData();
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      
      print('📱 Начинаем загрузку данных пользователя...');
      print('🎯 Целевой пользователь: $targetUserId');
      
      if (targetUserId == null) {
        print('❌ ID пользователя не указан');
        return;
      }

      // Загружаем профиль целевого пользователя
      print('🔄 Загружаем профиль пользователя...');
      final userDoc = await _firestore.collection('users').doc(targetUserId!).get();
      if (userDoc.exists) {
        userProfile.value = userDoc.data();
        print('✅ Профиль загружен: ${userProfile.value?['name'] ?? 'Без имени'}');
      } else {
        print('⚠️ Документ пользователя не найден');
        userProfile.value = null;
      }

      // Загружаем статистику гардероба
      print('🔄 Загружаем гардероб...');
      final wardrobeSnapshot = await _firestore
          .collection('users')
          .doc(targetUserId!)
          .collection('wardrobe')
          .get();
      totalClothes.value = wardrobeSnapshot.docs.length;
      print('👔 Всего вещей в гардеробе: ${totalClothes.value}');

      // Загружаем последние вещи (максимум 8 для веб)
      if (totalClothes.value > 0) {
        print('🔄 Загружаем последние вещи...');
        final recentClothesSnapshot = await _firestore
            .collection('users')
            .doc(targetUserId!)
            .collection('wardrobe')
            .orderBy('createdAt', descending: true)
            .limit(8)
            .get();
        
        recentClothes.value = recentClothesSnapshot.docs
            .map((doc) {
              try {
                return ClothesItem.fromMap(doc.data());
              } catch (e) {
                print('❌ Ошибка парсинга вещи ${doc.id}: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<ClothesItem>()
            .toList();
        print('👔 Загружено последних вещей: ${recentClothes.length}');
      } else {
        recentClothes.clear();
        print('📦 Гардероб пуст');
      }

      // Загружаем статистику образов
      print('🔄 Загружаем образы...');
      final patternsSnapshot = await _firestore
          .collection('users')
          .doc(targetUserId!)
          .collection('patterns')
          .get();
      totalPatterns.value = patternsSnapshot.docs.length;
      print('🎨 Всего образов: ${totalPatterns.value}');

      // Загружаем последние образы (максимум 8 для веб)
      if (totalPatterns.value > 0) {
        print('🔄 Загружаем последние образы...');
        final recentPatternsSnapshot = await _firestore
            .collection('users')
            .doc(targetUserId!)
            .collection('patterns')
            .orderBy('createdAt', descending: true)
            .limit(8)
            .get();
        
        recentPatterns.value = recentPatternsSnapshot.docs
            .map((doc) {
              try {
                return PatternItem.fromMap(doc.data());
              } catch (e) {
                print('❌ Ошибка парсинга образа ${doc.id}: $e');
                return null;
              }
            })
            .where((item) => item != null)
            .cast<PatternItem>()
            .toList();
        print('🎨 Загружено последних образов: ${recentPatterns.length}');
      } else {
        recentPatterns.clear();
        print('🎨 Образы отсутствуют');
      }

      print('✅ Загрузка данных завершена успешно');

    } catch (e) {
      print('❌ Ошибка загрузки данных пользователя: $e');
      print('❌ Стек ошибки: ${StackTrace.current}');
    } finally {
      isLoading.value = false;
      print('🏁 Статус загрузки сброшен');
    }
  }

  String getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Доброе утро';
    if (hour < 17) return 'Добрый день';
    return 'Добрый вечер';
  }

  String formatDate(dynamic timestamp) {
    try {
      DateTime date;
      if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is DateTime) {
        date = timestamp;
      } else {
        return 'Недавно';
      }
      
      final now = DateTime.now();
      final difference = now.difference(date);
      
      if (difference.inDays == 0) {
        return 'Сегодня';
      } else if (difference.inDays == 1) {
        return 'Вчера';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} дн. назад';
      } else {
        final months = [
          'янв', 'фев', 'мар', 'апр', 'май', 'июн',
          'июл', 'авг', 'сен', 'окт', 'ноя', 'дек'
        ];
        return '${date.day} ${months[date.month - 1]}';
      }
    } catch (e) {
      return 'Недавно';
    }
  }

  String get userName {
    return userProfile.value?['name'] ?? 
           userProfile.value?['surname'] ?? 
           'Пользователь';
  }

  String get userFullName {
    final profile = userProfile.value;
    if (profile == null) return 'Пользователь';
    
    final parts = [
      profile['surname'],
      profile['name'], 
      profile['secondName']
    ].where((part) => part != null && part.toString().isNotEmpty).toList();
    
    return parts.isNotEmpty ? parts.join(' ') : 'Пользователь';
  }

  String? get userAvatar => userProfile.value?['profileImage'];

  void navigateToWardrobe() {
    // Переход к полному списку гардероба конкретного пользователя
    print('📂 Переход к гардеробу пользователя: $targetUserId');
    currentView.value = ViewMode.wardrobe;
    loadAllClothes();
  }

  void navigateToPatterns() {
    // Переход к полному списку образов конкретного пользователя
    print('🎨 Переход к образам пользователя: $targetUserId');
    currentView.value = ViewMode.patterns;
    loadAllPatterns();
  }

  void backToProfile() {
    currentView.value = ViewMode.profile;
  }

  Future<void> loadAllClothes() async {
    try {
      isLoading.value = true;
      print('🔄 Загружаем все вещи из гардероба...');
      
      final clothesSnapshot = await _firestore
          .collection('users')
          .doc(targetUserId!)
          .collection('wardrobe')
          .orderBy('createdAt', descending: true)
          .get();
      
      allClothes.value = clothesSnapshot.docs
          .map((doc) {
            try {
              return ClothesItem.fromMap(doc.data());
            } catch (e) {
              print('❌ Ошибка парсинга вещи ${doc.id}: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<ClothesItem>()
          .toList();
      
      print('👔 Загружено всего вещей: ${allClothes.length}');
    } catch (e) {
      print('❌ Ошибка загрузки всех вещей: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadAllPatterns() async {
    try {
      isLoading.value = true;
      print('🔄 Загружаем все образы...');
      
      final patternsSnapshot = await _firestore
          .collection('users')
          .doc(targetUserId!)
          .collection('patterns')
          .orderBy('createdAt', descending: true)
          .get();
      
      allPatterns.value = patternsSnapshot.docs
          .map((doc) {
            try {
              return PatternItem.fromMap(doc.data());
            } catch (e) {
              print('❌ Ошибка парсинга образа ${doc.id}: $e');
              return null;
            }
          })
          .where((item) => item != null)
          .cast<PatternItem>()
          .toList();
      
      print('🎨 Загружено всего образов: ${allPatterns.length}');
    } catch (e) {
      print('❌ Ошибка загрузки всех образов: $e');
    } finally {
      isLoading.value = false;
    }
  }

  int getGridColumns(int itemCount) {
    if (itemCount <= 4) return 4;
    if (itemCount <= 9) return 5;
    if (itemCount <= 16) return 6;
    if (itemCount <= 25) return 7;
    return 8;
  }

  Future<void> refreshData() async {
    await loadUserData();
  }
}