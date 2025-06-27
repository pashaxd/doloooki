import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/message_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/request_model.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
String _formatDate(Timestamp date) {
    final months = [
      'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
      'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
    ];
    return '${date.toDate().day} ${months[date.toDate().month - 1]}';
  }
  // Создание начального сообщения с информацией о запросе
  Future<void> createInitialRequestMessage(RequestModel request) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // ИСПРАВЛЕНО: Создаем системное сообщение с временем на 1 час раньше создания запроса
      final requestMessage = MessageModel(
        id: '',
        chatId: request.id,
        senderId: 'system',
        senderName: 'Система',
        content: 'Запрос на консультацию',
        type: 'request',
        createdAt: request.createdAt.toDate().subtract(Duration(hours: 1)).toIso8601String(), // На 1 час раньше
        metadata: {
          'requestId': request.id,
          'title': request.title,
          'description': request.request,
          'looksCount': request.looksCount,
          'stylistName': request.stylistName,
          'fullBodyImages': request.fullBodyImages,
          'portraitImages': request.portraitImages,
          'userId': request.userId,
          'createdAt': request.createdAt.toDate().toIso8601String(),
        },
      );

      // Сохраняем сообщение в чат пользователя
      await _firestore
          .collection('users')
          .doc(request.userId)
          .collection('chats')
          .doc(request.id)
          .collection('messages')
          .add(requestMessage.toMap());

      // Сохраняем сообщение в чат стилиста
      await _firestore
          .collection('stylists')
          .doc(request.stylistId)
          .collection('chats')
          .doc(request.id)
          .collection('messages')
          .add(requestMessage.toMap());

      // Создаем приветственное сообщение от стилиста (через 1 секунду после создания запроса)
      final welcomeMessage = MessageModel(
        id: '',
        chatId: request.id,
        senderId: request.stylistId,
        senderName: request.stylistName,
        content: 'Добрый день! Меня зовут ${request.stylistName}, я помогу создать вам с вашим запросом! Ваш образ скоро будет готов! Всего доброго!',
        type: 'text',
        createdAt: request.createdAt.toDate().add(Duration(seconds: 1)).toIso8601String(), // Через 1 секунду после запроса
        metadata: null,
      );

      // Сохраняем приветственное сообщение в оба чата
      await _firestore
          .collection('users')
          .doc(request.userId)
          .collection('chats')
          .doc(request.id)
          .collection('messages')
          .add(welcomeMessage.toMap());

      await _firestore
          .collection('stylists')
          .doc(request.stylistId)
          .collection('chats')
          .doc(request.id)
          .collection('messages')
          .add(welcomeMessage.toMap());

    } catch (e) {
      print('Error creating initial request message: $e');
    }
  }

  // Отправка текстового сообщения
  Future<void> sendTextMessage({
    required String chatId,
    required String content,
    required String stylistId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: user.uid,
        senderName: 'Вы',
        content: content,
        type: 'text',
        createdAt: DateTime.now().toIso8601String(),
        metadata: null,
      );

      // Сохраняем сообщение в чат пользователя
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Сохраняем сообщение в чат стилиста
      await _firestore
          .collection('stylists')
          .doc(stylistId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

    } catch (e) {
      print('Error sending message: $e');
      throw Exception('Не удалось отправить сообщение');
    }
  }

  // Отправка изображения
  Future<void> sendImageMessage({
    required String chatId,
    required String imageUrl,
    required String stylistId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: user.uid,
        senderName: 'Вы',
        content: imageUrl,
        type: 'image',
        createdAt: DateTime.now().toIso8601String(),
        metadata: null,
      );

      // Сохраняем сообщение в чат пользователя
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Сохраняем сообщение в чат стилиста
      await _firestore
          .collection('stylists')
          .doc(stylistId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

    } catch (e) {
      print('Error sending image: $e');
      throw Exception('Не удалось отправить изображение');
    }
  }

  // Получение сообщений чата (из чата пользователя)
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .snapshots()
        .map((snapshot) {
      // Сортируем на клиенте
      final messages = snapshot.docs.map((doc) {
        return MessageModel.fromMap(doc.data(), doc.id);
      }).toList();
      
      // ИСПРАВЛЕНО: Сортируем по дате создания с парсингом DateTime (старые сначала)
      messages.sort((a, b) {
        try {
          final dateA = DateTime.parse(a.createdAt);
          final dateB = DateTime.parse(b.createdAt);
          return dateA.compareTo(dateB);
        } catch (e) {
          print('Ошибка парсинга даты: $e');
          return a.createdAt.compareTo(b.createdAt);
        }
      });
      
      return messages;
    });
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

  // Добавление отзыва о консультации
  Future<void> addReview({
    required String requestId,
    required String stylistId,
    required int rating,
    required String comment,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('Пользователь не авторизован');

      // Получаем данные пользователя для имени
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.exists && userDoc.data()?['name'] != null ? userDoc.data()!['name'] as String : 'Пользователь';

      // Создаем отзыв
      final review = {
        'userId': user.uid,
        'name': userName,
        'comment': comment,
        'rating': rating,
        'createdAt': DateTime.now().toIso8601String(),
        'requestId': requestId,
      };

      // Добавляем отзыв к стилисту
      await _firestore
          .collection('stylists')
          .doc(stylistId)
          .collection('reviews')
          .add(review);

      // Помечаем запрос как оцененный
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('requests')
          .doc(requestId)
          .update({'isReviewed': true});

      // Также обновляем копию запроса у стилиста
      await _firestore
          .collection('stylists')
          .doc(stylistId)
          .collection('requests')
          .doc(requestId)
          .update({'isReviewed': true});

    } catch (e) {
      print('Error adding review: $e');
      throw Exception('Не удалось добавить отзыв: $e');
    }
  }
} 