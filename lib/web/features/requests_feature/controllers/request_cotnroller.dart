import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:doloooki/mobile/features/stylist_feature/data/models/request_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/message_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/services/chat_service.dart';
import 'package:doloooki/utils/palette.dart';

class RequestController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ChatService _chatService = ChatService();
  
  // Список всех консультаций стилиста
  final RxList<RequestModel> requests = <RequestModel>[].obs;
  final RxBool isLoading = false.obs;
  
  // ДОБАВЛЕНО: Карта для хранения данных пользователей
  final RxMap<String, Map<String, dynamic>> usersData = <String, Map<String, dynamic>>{}.obs;
  
  // Переменные для чата
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final RxBool isSending = false.obs;
  final Rx<RequestModel?> currentRequest = Rx<RequestModel?>(null);
  
  @override
  void onInit() {
    super.onInit();
    loadStylistRequests();
  }
  
  @override
  void onClose() {
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
  
  // Загружаем все консультации для текущего стилиста
  Future<void> loadStylistRequests() async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;
      
      print('🔄 Загружаем консультации для стилиста: ${user.uid}');
      
      // ИСПРАВЛЕНО: Загружаем только из коллекции стилиста, чтобы избежать дублирования
      final querySnapshot = await _firestore
          .collection('stylists')
          .doc(user.uid)
          .collection('requests')
          .orderBy('createdAt', descending: true)
          .get();
      
      print('📦 Найдено консультаций: ${querySnapshot.docs.length}');
      
      requests.value = querySnapshot.docs.map((doc) {
        try {
          final data = doc.data();
          return RequestModel.fromMap(data, doc.id);
        } catch (e) {
          print('❌ Ошибка парсинга запроса ${doc.id}: $e');
          return null;
        }
      }).where((request) => request != null).cast<RequestModel>().toList();
      
      print('✅ Загружено консультаций: ${requests.length}');
      
      // ДОБАВЛЕНО: Загружаем данные пользователей для всех консультаций
      await _loadUsersData();
      
    } catch (e) {
      print('❌ Ошибка загрузки консультаций: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось загрузить консультации: $e',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // ДОБАВЛЕНО: Метод для загрузки данных пользователей
  Future<void> _loadUsersData() async {
    try {
      // Получаем уникальные userId из консультаций
      final userIds = requests.map((request) => request.userId).toSet();
      
      print('👥 Загружаем данные пользователей: ${userIds.length}');
      
      // Загружаем данные каждого пользователя
      for (final userId in userIds) {
        try {
          final userDoc = await _firestore.collection('users').doc(userId).get();
          if (userDoc.exists) {
            usersData[userId] = userDoc.data()!;
            print('✅ Загружены данные пользователя: ${userDoc.data()?['name'] ?? 'Без имени'}');
          } else {
            usersData[userId] = {'name': 'Пользователь не найден'};
          }
        } catch (e) {
          print('❌ Ошибка загрузки пользователя $userId: $e');
          usersData[userId] = {'name': 'Ошибка загрузки'};
        }
      }
      
      print('✅ Загружены данные ${usersData.length} пользователей');
      
    } catch (e) {
      print('❌ Ошибка загрузки данных пользователей: $e');
    }
  }
  
  // ДОБАВЛЕНО: Метод для получения имени пользователя
  String getUserName(String userId) {
    final userData = usersData[userId];
    return userData?['name'] ?? 'Загрузка...';
  }
  String getUserImage(String userId) {
    final userData = usersData[userId];
    return userData?['profileImage'] ?? '';
  }
  // Загружаем сообщения для конкретной консультации
  void loadMessages(RequestModel request) {
    currentRequest.value = request;
    print('💬 Загружаем сообщения для консультации: ${request.id}');
    
    // ИСПРАВЛЕНО: Создаем специальный метод для загрузки сообщений стилиста
    _getStylistChatMessages(request.id).listen((messageList) {
      final wasEmpty = messages.isEmpty;
      messages.value = messageList;
      print('📨 Загружено сообщений: ${messageList.length}');
      
      // ИСПРАВЛЕНО: При первом открытии чата показываем начало (системное сообщение)
      // При получении новых сообщений - прокручиваем к концу
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          if (wasEmpty && messageList.isNotEmpty) {
            // ИСПРАВЛЕНО: С reverse: true, для показа старых сообщений нужно прокрутить к максимуму
            scrollController.animateTo(
              scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else if (!wasEmpty) {
            // ИСПРАВЛЕНО: С reverse: true, для новых сообщений прокручиваем к минимуму
            scrollController.animateTo(
              scrollController.position.minScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        }
      });
    }, onError: (error) {
      print('❌ Ошибка загрузки сообщений: $error');
    });
  }
  
  // ДОБАВЛЕНО: Метод для загрузки сообщений из чата стилиста
  Stream<List<MessageModel>> _getStylistChatMessages(String chatId) {
    final user = _auth.currentUser;
    if (user == null) return Stream.value([]);

    return _firestore
        .collection('stylists')
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
  
  // Отправляем текстовое сообщение
  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || isSending.value || currentRequest.value == null) return;
    
    try {
      isSending.value = true;
      final request = currentRequest.value!;
      messageController.clear();
      
      print('📤 Отправляем сообщение в чат: ${request.id}');
      
      // ИСПРАВЛЕНО: Используем специальный метод для стилиста
      await _sendStylistTextMessage(
        chatId: request.id,
        content: content,
        userId: request.userId,
      );
      
      print('✅ Сообщение отправлено');
      
    } catch (e) {
      print('❌ Ошибка отправки сообщения: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось отправить сообщение',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    } finally {
      isSending.value = false;
    }
  }
  
  // ДОБАВЛЕНО: Метод отправки текстового сообщения стилистом
  Future<void> _sendStylistTextMessage({
    required String chatId,
    required String content,
    required String userId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: user.uid,
        senderName: 'Стилист',
        content: content,
        type: 'text',
        createdAt: DateTime.now().toIso8601String(),
        metadata: null,
      );

      // Сохраняем сообщение в чат стилиста
      await _firestore
          .collection('stylists')
          .doc(user.uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Сохраняем сообщение в чат пользователя
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

    } catch (e) {
      print('Error sending stylist message: $e');
      throw Exception('Не удалось отправить сообщение');
    }
  }
  
  // Отправляем изображение
  Future<void> sendImage() async {
    if (currentRequest.value == null) return;
    
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        isSending.value = true;
        final request = currentRequest.value!;
        
        print('🖼️ Загружаем изображение в чат: ${request.id}');
        
        // Загружаем изображение в Firebase Storage для веба
        final imageUrl = await _uploadImageToFirebaseWeb(image, request.id);
        
        // ИСПРАВЛЕНО: Используем специальный метод для стилиста
        await _sendStylistImageMessage(
          chatId: request.id,
          imageUrl: imageUrl,
          userId: request.userId,
        );
        
        print('✅ Изображение отправлено');
      }
    } catch (e) {
      print('❌ Ошибка отправки изображения: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось отправить изображение',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    } finally {
      isSending.value = false;
    }
  }
  
  // ДОБАВЛЕНО: Метод отправки изображения стилистом
  Future<void> _sendStylistImageMessage({
    required String chatId,
    required String imageUrl,
    required String userId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: user.uid,
        senderName: 'Стилист',
        content: imageUrl,
        type: 'image',
        createdAt: DateTime.now().toIso8601String(),
        metadata: null,
      );

      // Сохраняем сообщение в чат стилиста
      await _firestore
          .collection('stylists')
          .doc(user.uid)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

      // Сохраняем сообщение в чат пользователя
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toMap());

    } catch (e) {
      print('Error sending stylist image: $e');
      throw Exception('Не удалось отправить изображение');
    }
  }
  
  // Выбираем изображение с файлов (для веба)
  Future<void> pickImageFromFiles() async {
    if (currentRequest.value == null) return;
    
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        isSending.value = true;
        final request = currentRequest.value!;
        
        print('📁 Загружаем изображение из файлов в чат: ${request.id}');
        
        // Загружаем изображение в Firebase Storage для веба
        final imageUrl = await _uploadImageToFirebaseWeb(image, request.id);
        
        // ИСПРАВЛЕНО: Используем специальный метод для стилиста
        await _sendStylistImageMessage(
          chatId: request.id,
          imageUrl: imageUrl,
          userId: request.userId,
        );
        
        print('✅ Изображение из файлов отправлено');
      }
    } catch (e) {
      print('❌ Ошибка отправки изображения из файлов: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось отправить изображение',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    } finally {
      isSending.value = false;
    }
  }
  
  // Загружаем изображение в Firebase Storage для веба
  Future<String> _uploadImageToFirebaseWeb(XFile image, String chatId) async {
    try {
      // Создаем уникальное имя файла
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      // Создаем ссылку на место хранения в Storage
      final storageRef = _storage.ref().child('chats/$chatId/images/$fileName');
      
      // Для веба используем bytes вместо File
      final bytes = await image.readAsBytes();
      
      // Загружаем файл
      final uploadTask = await storageRef.putData(
        bytes,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      
      // Получаем URL загруженного файла
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('❌ Ошибка загрузки изображения для веба: $e');
      throw Exception('Не удалось загрузить изображение: $e');
    }
  }
  
  // Загружаем изображение в Firebase Storage (для мобильной версии)
  Future<String> _uploadImageToFirebase(XFile image, String chatId) async {
    try {
      // Создаем уникальное имя файла
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      // Создаем ссылку на место хранения в Storage
      final storageRef = _storage.ref().child('chats/$chatId/images/$fileName');
      
      // Загружаем файл
      final uploadTask = await storageRef.putFile(File(image.path));
      
      // Получаем URL загруженного файла
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      print('❌ Ошибка загрузки изображения: $e');
      throw Exception('Не удалось загрузить изображение: $e');
    }
  }
  
  // Завершаем консультацию
  Future<void> finishConsultation(String requestId) async {
    try {
      isLoading.value = true;
      final user = _auth.currentUser;
      if (user == null) return;
      
      print('🏁 Завершаем консультацию: $requestId');
      
      // Получаем данные запроса из коллекции стилиста
      final requestDoc = await _firestore
          .collection('stylists')
          .doc(user.uid)
          .collection('requests')
          .doc(requestId)
          .get();

      if (!requestDoc.exists) return;
      
      final requestData = requestDoc.data()!;
      final userId = requestData['userId'];

      // Обновляем статус в коллекции стилиста
      await _firestore
          .collection('stylists')
          .doc(user.uid)
          .collection('requests')
          .doc(requestId)
          .update({'status': 'Завершена'});

      // Обновляем статус в коллекции пользователя
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('requests')
          .doc(requestId)
          .update({'status': 'Завершена'});
      
      // Обновляем локальный список
      final index = requests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final updatedRequest = requests[index].copyWith(status: 'Завершена');
        requests[index] = updatedRequest;
        requests.refresh();
      }
      
      print('✅ Консультация завершена');
      
      Get.snackbar(
        'Успешно',
        'Консультация завершена',
        backgroundColor: Palette.success,
        colorText: Palette.white100,
      );
      
    } catch (e) {
      print('❌ Ошибка завершения консультации: $e');
      Get.snackbar(
        'Ошибка',
        'Не удалось завершить консультацию: $e',
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  // Форматируем время сообщения
  String formatMessageTime(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
  
  // Форматируем дату сообщения
  String formatMessageDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      final months = [
        'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
        'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return '';
    }
  }
  
  // Форматируем дату для карточки консультации
  String formatRequestDate(Timestamp timestamp) {
    try {
      final date = timestamp.toDate();
      final months = [
        'января', 'февраля', 'марта', 'апреля', 'мая', 'июня',
        'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'
      ];
      return '${date.day} ${months[date.month - 1]}';
    } catch (e) {
      return 'Недавно';
    }
  }
  
  // Получаем цвет статуса
  Color getStatusColor(String status) {
    switch (status) {
      case 'В процессе':
        return Palette.warning;
      case 'Завершена':
        return Palette.success;
      case 'Отменена':
        return Palette.error;
      default:
        return Palette.warning;
    }
  }
  
  // Обновляем список консультаций
  Future<void> refreshRequests() async {
    await loadStylistRequests();
  }
}