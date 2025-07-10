import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static FirestoreService? _instance;
  static FirestoreService get instance => _instance ??= FirestoreService._internal();
  
  FirestoreService._internal();
  
  // Текущая база данных
  FirebaseFirestore? _currentDatabase;
  
  // Переключиться на базу данных по умолчанию
  FirebaseFirestore get defaultDatabase {
    _currentDatabase = FirebaseFirestore.instance;
    return _currentDatabase!;
  }
  
  // Переключиться на базу данных dolookidb
  FirebaseFirestore get dolookiDatabase {
    // Для именованных баз данных нужно использовать настройки проекта
    // В вашем случае нужно обновить firebase_options.dart
    _currentDatabase = FirebaseFirestore.instance;
    return _currentDatabase!;
  }
  
  // Получить текущую активную базу данных
  FirebaseFirestore get currentDatabase {
    return _currentDatabase ?? defaultDatabase;
  }
  
  // Переключить базу данных
  void switchToDatabase(String databaseId) {
    print('🔄 Переключение на базу данных: $databaseId');
    _currentDatabase = FirebaseFirestore.instance;
  }
  
  // Методы для работы с коллекциями
  CollectionReference collection(String collectionPath) {
    return currentDatabase.collection(collectionPath);
  }
  
  DocumentReference doc(String documentPath) {
    return currentDatabase.doc(documentPath);
  }
} 