import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/message_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/request_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/services/chat_service.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatController extends GetxController {
  final ChatService _chatService = ChatService();
  final TextEditingController messageController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();
  final FocusNode reviewFocusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxList<MessageModel> messages = <MessageModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isSending = false.obs;
  final RxInt rating = 0.obs;
  final RxBool isReviewSubmitting = false.obs;
  final RxBool isReviewSubmitted = false.obs;
  final RxBool isReviewFocused = false.obs;
  final RxString reviewText = ''.obs;
  
  late final RequestModel request;
  
  void initializeChat(RequestModel requestModel) {
    request = requestModel;
    loadMessages();
    checkIfReviewed();
    
    reviewFocusNode.addListener(() {
      isReviewFocused.value = reviewFocusNode.hasFocus;
    });
    
    reviewController.addListener(() {
      reviewText.value = reviewController.text;
    });
  }

  void loadMessages() {
    _chatService.getChatMessages(request.id).listen((messageList) {
      messages.value = messageList;
      // Прокручиваем к последнему сообщению
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }

  void checkIfReviewed() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      
      final requestDoc = await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('requests')
          .doc(request.id)
          .get();
          
      if (requestDoc.exists && requestDoc.data() != null) {
        isReviewSubmitted.value = requestDoc.data()!['isReviewed'] ?? false;
      }
    } catch (e) {
      print('Error checking if reviewed: $e');
    }
  }

  Future<void> sendMessage() async {
    final content = messageController.text.trim();
    if (content.isEmpty || isSending.value) return;

    try {
      isSending.value = true;
      messageController.clear();
      
      await _chatService.sendTextMessage(
        chatId: request.id,
        content: content,
        stylistId: request.stylistId,
      );
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось отправить сообщение');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        isSending.value = true;
        
        // Загружаем изображение в Firebase Storage
        final imageUrl = await _uploadImageToFirebase(image);
        
        // Отправляем сообщение с URL изображения
        await _chatService.sendImageMessage(
          chatId: request.id,
          imageUrl: imageUrl,
          stylistId: request.stylistId,
        );
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось отправить изображение');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.camera);
      
      if (image != null) {
        isSending.value = true;
        
        // Загружаем изображение в Firebase Storage
        final imageUrl = await _uploadImageToFirebase(image);
        
        // Отправляем сообщение с URL изображения
        await _chatService.sendImageMessage(
          chatId: request.id,
          imageUrl: imageUrl,
          stylistId: request.stylistId,
        );
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось отправить изображение');
    } finally {
      isSending.value = false;
    }
  }

  Future<void> pickImageFromGallery() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        isSending.value = true;
        
        // Загружаем изображение в Firebase Storage
        final imageUrl = await _uploadImageToFirebase(image);
        
        // Отправляем сообщение с URL изображения
        await _chatService.sendImageMessage(
          chatId: request.id,
          imageUrl: imageUrl,
          stylistId: request.stylistId,
        );
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось отправить изображение');
    } finally {
      isSending.value = false;
    }
  }
  
  Future<String> _uploadImageToFirebase(XFile image) async {
    try {
      // Создаем уникальное имя файла
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      
      // Создаем ссылку на место хранения в Storage
      final storageRef = _storage.ref().child('chats/${request.id}/images/$fileName');
      
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

  String formatMessageTime(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }
  
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

  void setRating(int value) {
    rating.value = value;
  }
  
  bool canSubmitReview() {
    return rating.value > 0 && reviewText.value.trim().isNotEmpty && !isReviewSubmitting.value;
  }

  Future<void> submitReview() async {
    if (rating.value == 0 || reviewText.value.trim().isEmpty || isReviewSubmitting.value) {
      return;
    }

    try {
      isReviewSubmitting.value = true;
      
      await _chatService.addReview(
        requestId: request.id,
        stylistId: request.stylistId,
        rating: rating.value,
        comment: reviewText.value.trim(),
      );
      
      isReviewSubmitted.value = true;
      Get.back(); // Закрываем bottom sheet
      
      Get.snackbar(
        'Успех',
        'Ваш отзыв отправлен',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось отправить отзыв: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isReviewSubmitting.value = false;
    }
  }

  void showReviewBottomSheet() {
    reviewController.clear();
    reviewText.value = '';
    rating.value = 0;
    
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Palette.red600,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Obx(() => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
               
                Text(
                  'Оценка консультации',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(20.sp),
              ),
              width: double.infinity,
              child: Column(
                spacing: 10.sp,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Оцените консультацию стилиста', style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                    Text(request.stylistName, style: TextStyles.bodyMedium.copyWith(color: Palette.grey200)),
                    SizedBox(width: 4.sp),
                    Text('•', style: TextStyles.bodyMedium.copyWith(color: Palette.grey200, fontSize: 20.sp   )),
                    SizedBox(width: 4.sp),

                    Text(request.title, style: TextStyles.bodyMedium.copyWith(color: Palette.grey200)),
                  ],),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return GestureDetector(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.sp),
                          child: Container(
                           
                            width: 50.sp,
                            height: 50.sp,
                            decoration: BoxDecoration(
                              color: index < rating.value ? Color(0xFF402A15) : Palette.red400,
                              shape: BoxShape.circle,
                              border: Border.all(color: index < rating.value ? Color(0xFF402A15) : Palette.grey350, width: 1),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/stylist/star.svg',
                                width: 30.sp,
                                height: 30.sp,
                                color: index < rating.value ? Palette.warning : Palette.grey350,
                              
                              ),
                            ),
                          ),
                        ),
                        onTap: () => setRating(index + 1),
                      );
                    }),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            // Поле для комментария
            Text('Комментарий', style: TextStyles.titleSmall.copyWith(color: isReviewFocused.value ? Palette.white100 : Palette.grey100)),
            SizedBox(height: 10.sp),
            Container(
              height: 60.sp,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isReviewFocused.value ? Palette.red200 : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.sp),
                child: TextField(
                  onTapOutside: (event) {
                    reviewFocusNode.unfocus();
                  },
                  focusNode: reviewFocusNode,
                  controller: reviewController,
                  maxLength: 50,
                  style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                  maxLines: 2,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey200),
                    hintText: 'Расскажите о своем опыте работы со стилистом...',
                    counterText: '',
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${reviewText.value.length}/50',
                style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
              ),
            ),
            SizedBox(height: 16),
            // Кнопка отправки
            GestureDetector(
              onTap: (){
                if(canSubmitReview()){
                  submitReview();
                }
              },
              child: Container(
                height: 50.sp,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: canSubmitReview() ? Palette.red100 : Palette.red400,
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Center(
                  child: isReviewSubmitting.value
                    ? CircularProgressIndicator(color: Palette.white100)
                    : Text(
                        'Отправить оценку',
                        style: TextStyles.titleMedium.copyWith(color:canSubmitReview() ? Palette.white100 : Palette.grey350),
                      ),
                ),
              ),
            ),
          ],
        )),
      ),
      isScrollControlled: true,
    );
  }

  @override
  void onClose() {
    messageController.dispose();
    reviewController.dispose();
    reviewFocusNode.dispose();
    scrollController.dispose();
    super.onClose();
  }

  Future<void> finishConsultation() async {
    try {
      isLoading.value = true;
      await _chatService.updateRequestStatus(request.id, 'Завершена');
      Get.snackbar(
        'Консультация завершена',
        'Вы успешно завершили консультацию',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Ошибка',
        'Не удалось завершить консультацию: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }
} 