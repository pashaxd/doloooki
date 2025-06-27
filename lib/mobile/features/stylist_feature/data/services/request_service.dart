import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/request_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/services/chat_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RequestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ChatService _chatService = ChatService();

  // Метод для загрузки изображения в Firebase Storage
  Future<String> uploadImageToFirebase(XFile image, String folder) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Создаем уникальное имя файла
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      // Создаем ссылку на место хранения в Storage
      final storageRef = _storage.ref().child('users/${user.uid}/$folder/$fileName');
      
      // Загружаем файл
      final uploadTask = await storageRef.putFile(File(image.path));
      
      // Получаем URL загруженного файла
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      throw Exception('Не удалось загрузить изображение: $e');
    }
  }

  // Метод для загрузки нескольких изображений
  Future<List<String>> uploadImages(List<XFile?> images, String folder) async {
    List<String> imageUrls = [];
    
    for (var image in images) {
      if (image != null) {
        final url = await uploadImageToFirebase(image, folder);
        imageUrls.add(url);
      }
    }
    
    return imageUrls;
  }

  Future<String> createRequest({
    required String stylistId,
    required String stylistName,
    required String title,
    required String request,
    required int looksCount,
    required List<String> fullBodyImages,
    required List<String> portraitImages,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      final requestData = RequestModel(
        id: '',
        userId: user.uid,
        stylistId: stylistId,
        stylistName: stylistName,
        title: title,
        request: request,
        status: 'В процессе',
        createdAt: Timestamp.now(),
        looksCount: looksCount,
        fullBodyImages: fullBodyImages,
        portraitImages: portraitImages,
      );

      // Сохраняем запрос в подколлекцию пользователя
      final docRef = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('requests')
          .add(requestData.toMap());

      // Также сохраняем копию в подколлекцию стилиста для удобства
      await _firestore
          .collection('stylists')
          .doc(stylistId)
          .collection('requests')
          .doc(docRef.id)
          .set(requestData.toMap());

      // Создаем начальные сообщения в чате
      final createdRequest = requestData.copyWith(id: docRef.id);
      await _chatService.createInitialRequestMessage(createdRequest);

      return docRef.id;
    } catch (e) {
      print('Error creating request: $e');
      throw Exception('Не удалось создать запрос: $e');
    }
  }

  Stream<List<RequestModel>> getUserRequests() {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('requests')
        .snapshots()
        .map((snapshot) {
      // Сортируем на клиенте
      final requests = snapshot.docs.map((doc) {
        return RequestModel.fromMap(doc.data(), doc.id);
      }).toList();
      
      // Сортируем по дате создания (новые сначала)
      requests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return requests;
    });
  }

  Future<RequestModel?> getRequestById(String requestId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final doc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('requests')
          .doc(requestId)
          .get();
      
      if (doc.exists) {
        return RequestModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error getting request: $e');
      return null;
    }
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Получаем данные запроса для определения stylistId
      final requestDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) return;
      
      final requestData = requestDoc.data()!;
      final stylistId = requestData['stylistId'];

      // Обновляем статус в запросе пользователя
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('requests')
          .doc(requestId)
          .update({'status': status});

      // Обновляем статус в копии запроса у стилиста
      await _firestore
          .collection('stylists')
          .doc(stylistId)
          .collection('requests')
          .doc(requestId)
          .update({'status': status});

    } catch (e) {
      print('Error updating request status: $e');
      throw Exception('Не удалось обновить статус запроса');
    }
  }
} 