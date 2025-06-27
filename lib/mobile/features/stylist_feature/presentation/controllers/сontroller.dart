import 'dart:typed_data';

import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:doloooki/mobile/features/subscription_feature/services/payment_service.dart';
import 'package:doloooki/mobile/features/subscription_feature/models/payment_card.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/stylist_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/services/request_service.dart';

class AddingRequestController extends GetxController {
  final RxList<XFile?> selectedImages = List<XFile?>.filled(3, null).obs;
  final RxList<Uint8List?> previewImages = List<Uint8List?>.filled(3, null).obs;
  final RxList<XFile?> fullBodyImages = List<XFile?>.filled(3, null).obs;
  final RxList<Uint8List?> fullBodyPreviews = List<Uint8List?>.filled(3, null).obs;
  final RxList<XFile?> portraitImages = List<XFile?>.filled(3, null).obs;
  final RxList<Uint8List?> portraitPreviews = List<Uint8List?>.filled(3, null).obs;
  final TextEditingController requestController = TextEditingController();
  final FocusNode requestFocusNode = FocusNode();
  final RxBool isRequestFocused = false.obs;
  final RxInt selectedLooksCount = 1.obs;
  final PaymentService paymentService = PaymentService();
  final RequestService requestService = RequestService();
  final RxBool isLoading = false.obs;
  final RxList<PaymentCard> userCards = <PaymentCard>[].obs;
  final Rx<PaymentCard?> selectedCard = Rx<PaymentCard?>(null);
  final RxBool hasSavedCards = false.obs;
  final RxBool isRequestReady = false.obs;
  final RxInt onePatternPrice = 500.obs;
  final RxInt stylistConsultationPrice = 2500.obs;
  final TextEditingController titleController = TextEditingController();
  final FocusNode titleFocusNode = FocusNode();
  final RxBool isTitleFocused = false.obs;
  final RxBool isTitleReady = false.obs;
  final RxString title = ''.obs;
  final RxString requestText = ''.obs;
  
  // Stylist selection
  final Rx<StylistModel?> selectedStylist = Rx<StylistModel?>(null);
  final RxString selectedStylistText = 'Выберите стилиста'.obs;
  
  @override
  void onInit() {
    super.onInit();
    loadUserCards();
    requestFocusNode.addListener(() {
      isRequestFocused.value = requestFocusNode.hasFocus;
    });
    titleFocusNode.addListener(() {
      isTitleFocused.value = titleFocusNode.hasFocus;
    });
    requestController.addListener(_updateRequestReady);
    requestController.addListener(() {
      requestText.value = requestController.text;
    });
    titleController.addListener(_updateRequestReady);
    titleController.addListener(() {
      title.value = titleController.text;
    });
    _updateRequestReady();
  }

  @override
  void onClose() {
    requestController.dispose();
    requestFocusNode.dispose();
    titleController.dispose();
    titleFocusNode.dispose();
    super.onClose();
  }

  void _updateRequestReady() {
    isRequestReady.value = 
      fullBodyImages.any((img) => img != null) &&
      portraitImages.any((img) => img != null) &&
      titleController.text.trim().isNotEmpty &&
      requestController.text.trim().isNotEmpty &&
      selectedLooksCount.value > 0 &&
      selectedStylist.value != null;
  }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImages[index] = image;
      previewImages[index] = await image.readAsBytes();
    }
  }

  Future<void> pickImageFromCamera(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      selectedImages[index] = image;
      previewImages[index] = await image.readAsBytes();
    }
  }

  Future<void> pickImageFromGallery(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      selectedImages[index] = image;
      previewImages[index] = await image.readAsBytes();
    }
  }

  void removeImage(int index) {
    selectedImages[index] = null;
    previewImages[index] = null;
  }

  Future<void> pickFullBodyImageFromCamera(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      fullBodyImages[index] = image;
      fullBodyPreviews[index] = await image.readAsBytes();
      _updateRequestReady();
    }
  }

  Future<void> pickFullBodyImageFromGallery(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      fullBodyImages[index] = image;
      fullBodyPreviews[index] = await image.readAsBytes();
      _updateRequestReady();
    }
  }

  void removeFullBodyImage(int index) {
    fullBodyImages[index] = null;
    fullBodyPreviews[index] = null;
    _updateRequestReady();
  }

  Future<void> pickPortraitImageFromCamera(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      portraitImages[index] = image;
      portraitPreviews[index] = await image.readAsBytes();
      _updateRequestReady();
    }
  }

  Future<void> pickPortraitImageFromGallery(int index) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      portraitImages[index] = image;
      portraitPreviews[index] = await image.readAsBytes();
      _updateRequestReady();
    }
  }

  void removePortraitImage(int index) {
    portraitImages[index] = null;
    portraitPreviews[index] = null;
    _updateRequestReady();
  }

  void setLooksCount(int count) {
    selectedLooksCount.value = count;
    _updateRequestReady();
  }

  void setStylistSelection({String? type, StylistModel? stylist}) {
    if (type == 'manual' && stylist != null) {
      selectedStylist.value = stylist;
      selectedStylistText.value = '${stylist.name} (${stylist.shortDescription})';
    } else if (type == 'random' && stylist != null) {
      selectedStylist.value = stylist;
      selectedStylistText.value = 'Автоматический выбор: ${stylist.name}';
    }
    _updateRequestReady();
  }

  void loadUserCards() {
    paymentService.getUserCards().listen((cards) {
      userCards.value = cards;
      hasSavedCards.value = cards.isNotEmpty;
      if (cards.isNotEmpty && selectedCard.value == null) {
        selectedCard.value = cards.first;
      }
    });
  }

  void selectCard(PaymentCard card) {
    selectedCard.value = card;
  }

  Future<void> deleteCard(String cardId) async {
    try {
      isLoading.value = true;
      await paymentService.deleteCard(cardId);
      try {
        selectedCard.value = userCards.firstWhere((card) => card.id != cardId);
      } catch (e) {
        selectedCard.value = null;
      }
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось удалить карту', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  bool isCardExpired(PaymentCard card) {
    final now = DateTime.now();
    final year = int.parse('20${card.expiryYear}');
    final month = int.parse(card.expiryMonth);
    final expiryDate = DateTime(year, month + 1, 0);
    return now.isAfter(expiryDate);
  }

  Future<void> addCard({
    required String cardNumber,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
    required String cvv,
  }) async {
    try {
      isLoading.value = true;
      await paymentService.addCard(
        cardNumber: cardNumber,
        cardholderName: cardholderName,
        expiryMonth: expiryMonth,
        expiryYear: expiryYear,
        cvv: cvv,
      );
      loadUserCards();
      Get.snackbar('Успех', 'Карта успешно добавлена', snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Ошибка', 'Не удалось добавить карту', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void clearForm() {
    // Очищаем фотографии в полный рост
    for (int i = 0; i < fullBodyImages.length; i++) {
      fullBodyImages[i] = null;
      fullBodyPreviews[i] = null;
    }
    
    // Очищаем портретные фотографии
    for (int i = 0; i < portraitImages.length; i++) {
      portraitImages[i] = null;
      portraitPreviews[i] = null;
    }
    
    // Очищаем текст запроса и заголовок
    titleController.clear();
    title.value = '';
    requestController.clear();
    requestText.value = '';
    
    // Сбрасываем количество образов на 1
    selectedLooksCount.value = 1;
    
    // Сбрасываем выбор стилиста
    selectedStylist.value = null;
    selectedStylistText.value = 'Выберите стилиста';
    
    // Обновляем состояние готовности запроса
    _updateRequestReady();
    
    // Убираем фокус с полей ввода
    if (titleFocusNode.hasFocus) {
      titleFocusNode.unfocus();
    }
    if (requestFocusNode.hasFocus) {
      requestFocusNode.unfocus();
    }
  }

  Future<void> pay() async {
    try {
      isLoading.value = true;
      
      // Проверяем наличие выбранного стилиста
      if (selectedStylist.value == null) {
        throw Exception('Стилист не выбран');
      }
      
      // Загружаем фотографии в Firebase Storage
      List<String> fullBodyImageUrls = await requestService.uploadImages(
        fullBodyImages, 
        'full_body_images'
      );
      
      List<String> portraitImageUrls = await requestService.uploadImages(
        portraitImages, 
        'portrait_images'
      );
      
      // Сохраняем запрос в базу данных
      await requestService.createRequest(
        stylistId: selectedStylist.value!.id,
        stylistName: selectedStylist.value!.name,
        title: titleController.text.trim(),
        request: requestController.text.trim(),
        looksCount: selectedLooksCount.value,
        fullBodyImages: fullBodyImageUrls,
        portraitImages: portraitImageUrls,
      );
      
      // Показываем диалог об успешной оплате
      await showDialog(
        context: Get.context!,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.symmetric(horizontal: 8.sp),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.sp),
            decoration: BoxDecoration(
              color: Palette.red400,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  'assets/icons/notifications/green.png',
                  width: 60.sp,
                  height: 60.sp,
                ),
                SizedBox(height: 16.sp),
                Text(
                  'Услуга оплачена',
                  style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8.sp),
                Text(
                  'Вы успешно оплатили консультацию стилиста. Совсем скоро вы получите обратную связь.',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16.sp),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ButtonStyles.primary,
                    child: Text(
                      'Продолжить',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      
      // Очищаем форму после успешной оплаты
      clearForm();
      
    } catch (e) {
      Get.snackbar(
        'Ошибка', 
        'Не удалось обработать платеж. Попробуйте еще раз.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Palette.error,
        colorText: Palette.white100,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  double getAverageRating(StylistModel stylist) {
    if (stylist.reviews.isEmpty) return 0.0;
    
    int totalRating = stylist.reviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / stylist.reviews.length;
  }
  
  void clearStylistSelection() {
    selectedStylist.value = null;
    selectedStylistText.value = 'Выберите стилиста';
    _updateRequestReady();
  }
}
