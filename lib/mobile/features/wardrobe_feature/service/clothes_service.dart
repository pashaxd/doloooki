import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doloooki/mobile/features/wardrobe_feature/models/clothes_item.dart';
import 'package:get/get.dart';

class ClothesService {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final RxList<ClothesItem> _cachedClothes = <ClothesItem>[].obs;
  bool _isInitialized = false;

  // Получаем коллекцию wardrobe для конкретного пользователя
  CollectionReference<Map<String, dynamic>> _getUserWardrobe() {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }
    return _firestore.collection('users').doc(user.uid).collection('wardrobe');
  }

  Future<void> addClothes(ClothesItem item) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('Пользователь не авторизован');
    }

    await _getUserWardrobe().doc(item.id).set({
      ...item.toMap(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    
    // Обновляем кэш
    _cachedClothes.insert(0, item);
  }

  Stream<List<ClothesItem>> getClothes() {
    final user = _auth.currentUser;
    if (user == null) {
      print('User not authenticated in getClothes');
      return Stream.value([]);
    }

    try {
      // Подписываемся на обновления и обновляем кэш
      return _getUserWardrobe()
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            final items = snapshot.docs.map((doc) => ClothesItem.fromMap(doc.data())).toList();
            _cachedClothes.value = items;
            _isInitialized = true;
            return items;
          })
          .handleError((error) {
            print('Error in getClothes stream: $error');
            // Возвращаем пустой список при ошибке
            return <ClothesItem>[];
          });
    } catch (e) {
      print('Error getting clothes: $e');
      return Stream.value([]);
    }
  }

  // Метод для очистки кэша при выходе из приложения
  void clearCache() {
    _cachedClothes.clear();
    _isInitialized = false;
  }
}