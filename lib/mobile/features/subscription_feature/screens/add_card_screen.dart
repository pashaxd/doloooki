import 'package:doloooki/mobile/features/subscription_feature/screens/subscription.dart';
import 'package:doloooki/mobile/features/subscription_feature/services/payment_service.dart';
import 'package:doloooki/utils/button_styles.dart';
import 'package:doloooki/utils/consts.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_fields.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class AddCardScreen extends StatelessWidget {
  AddCardScreen({super.key});

  final PaymentService _paymentService = PaymentService();
  final TextEditingController cardNumberController = TextEditingController();
  final TextEditingController cardholderNameController = TextEditingController();
  final TextEditingController expiryMonthController = TextEditingController();
  final TextEditingController expiryYearController = TextEditingController();
  final TextEditingController cvvController = TextEditingController();
  final RxBool isLoading = false.obs;
  final RxBool isFormValid = false.obs;
  final RxString cardNumberError = ''.obs;
  final RxString cardholderNameError = ''.obs;
  final RxString expiryError = ''.obs;
  final RxString cvvError = ''.obs;

  // Focus states
  final RxBool isCardNumberFocused = false.obs;
  final RxBool isCardholderNameFocused = false.obs;
  final RxBool isExpiryMonthFocused = false.obs;
  final RxBool isExpiryYearFocused = false.obs;
  final RxBool isCvvFocused = false.obs;

  // Flag to control when to show validation errors
  final RxBool shouldShowErrors = false.obs;

  // Добавляем форматтер для маски карты
  String _formatCardNumber(String text) {
    if (text.isEmpty) return text;
    
    // Удаляем все нецифровые символы
    String digitsOnly = text.replaceAll(RegExp(r'[^\d]'), '');
    
    // Ограничиваем до 16 цифр
    if (digitsOnly.length > 16) {
      digitsOnly = digitsOnly.substring(0, 16);
    }
    
    // Форматируем номер карты с пробелами после каждых 4 цифр
    String formatted = '';
    for (int i = 0; i < digitsOnly.length; i++) {
      if (i > 0 && i % 4 == 0) {
        formatted += ' ';
      }
      formatted += digitsOnly[i];
    }
    
    return formatted;
  }

  void validateCardNumber(String value) {
    final digitsOnly = value.replaceAll(RegExp(r'[^\d]'), '');
    if (!shouldShowErrors.value) return;
    
    if (digitsOnly.isEmpty) {
      cardNumberError.value = 'Введите номер карты';
    } else if (digitsOnly.length != 16) {
      cardNumberError.value = 'Номер карты должен содержать 16 цифр';
    } else {
      cardNumberError.value = '';
    }
    updateFormValidity();
  }

  void validateCardholderName(String value) {
    if (!shouldShowErrors.value) return;
    
    if (value.isEmpty) {
      cardholderNameError.value = 'Введите имя владельца';
    } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(value)) {
      cardholderNameError.value = 'Используйте только буквы';
    } else {
      cardholderNameError.value = '';
    }
    updateFormValidity();
  }

  void validateExpiry(String month, String year) {
    if (!shouldShowErrors.value) return;
    
    if (month.isEmpty || year.isEmpty) {
      expiryError.value = 'Введите срок действия';
      return;
    }

    final monthNum = int.tryParse(month);
    final yearNum = int.tryParse(year);
    final currentYear = DateTime.now().year % 100;
    final currentMonth = DateTime.now().month;

    if (monthNum == null || monthNum < 1 || monthNum > 12) {
      expiryError.value = 'Неверный месяц';
    } else if (yearNum == null || yearNum < currentYear || (yearNum == currentYear && monthNum < currentMonth)) {
      expiryError.value = 'Срок действия истек';
    } else {
      expiryError.value = '';
    }
    updateFormValidity();
  }

  void validateCvv(String value) {
    if (!shouldShowErrors.value) return;
    
    if (value.isEmpty) {
      cvvError.value = 'Введите CVV';
    } else if (value.length != 3) {
      cvvError.value = 'CVV должен содержать 3 цифры';
    } else {
      cvvError.value = '';
    }
    updateFormValidity();
  }

  bool validateForm() {
    return cardNumberError.value.isEmpty &&
           cardholderNameError.value.isEmpty &&
           expiryError.value.isEmpty &&
           cvvError.value.isEmpty;
  }

  void updateFormValidity() {
    isFormValid.value = validateForm();
  }

  // Method to validate all fields when button is clicked
  bool validateAllFields() {
    shouldShowErrors.value = true;
    
    // Validate card number
    final digitsOnly = cardNumberController.text.replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.isEmpty) {
      cardNumberError.value = 'Введите номер карты';
    } else if (digitsOnly.length != 16) {
      cardNumberError.value = 'Номер карты должен содержать 16 цифр';
    } else {
      cardNumberError.value = '';
    }

    // Validate cardholder name
    if (cardholderNameController.text.isEmpty) {
      cardholderNameError.value = 'Введите имя владельца';
    } else if (!RegExp(r'^[A-Za-z\s]+$').hasMatch(cardholderNameController.text)) {
      cardholderNameError.value = 'Используйте только буквы';
    } else {
      cardholderNameError.value = '';
    }

    // Validate expiry
    final month = expiryMonthController.text;
    final year = expiryYearController.text;
    if (month.isEmpty || year.isEmpty) {
      expiryError.value = 'Введите срок действия';
    } else {
      final monthNum = int.tryParse(month);
      final yearNum = int.tryParse(year);
      final currentYear = DateTime.now().year % 100;
      final currentMonth = DateTime.now().month;

      if (monthNum == null || monthNum < 1 || monthNum > 12) {
        expiryError.value = 'Неверный месяц';
      } else if (yearNum == null || yearNum < currentYear || (yearNum == currentYear && monthNum < currentMonth)) {
        expiryError.value = 'Срок действия истек';
      } else {
        expiryError.value = '';
      }
    }

    // Validate CVV
    if (cvvController.text.isEmpty) {
      cvvError.value = 'Введите CVV';
    } else if (cvvController.text.length != 3) {
      cvvError.value = 'CVV должен содержать 3 цифры';
    } else {
      cvvError.value = '';
    }

    return cardNumberError.value.isEmpty &&
           cardholderNameError.value.isEmpty &&
           expiryError.value.isEmpty &&
           cvvError.value.isEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Palette.red600,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Palette.red600,
          appBar: AppBar(
            backgroundColor: Palette.red600,
            title: Text('Добавить карту', style: TextStyles.titleLarge),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: Palette.white100),
              onPressed: () => Get.back(),
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Номер карты', style: TextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Obx(() => TextField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                      isCardNumberFocused.value = false;
                    },
                    onTap: () => isCardNumberFocused.value = true,
                    controller: cardNumberController,
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(19), // 16 цифр + 3 пробела
                      TextInputFormatter.withFunction((oldValue, newValue) {
                        return TextEditingValue(
                          text: _formatCardNumber(newValue.text),
                          selection: TextSelection.collapsed(
                            offset: _formatCardNumber(newValue.text).length,
                          ),
                        );
                      }),
                    ],
                    onChanged: (value) {
                      validateCardNumber(value);
                    },
                    decoration: InputDecoration(
                      hintText: '0000 0000 0000 0000',
                      hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                      filled: true,
                      fillColor: Palette.red400,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Palette.white100, width: 1),
                      ),
                      errorText: (shouldShowErrors.value && cardNumberError.value.isNotEmpty) ? cardNumberError.value : null,
                      errorStyle: TextStyles.bodySmall.copyWith(color: Palette.error),
                    ),
                  )),
                  const SizedBox(height: 16),
                  Text('Имя владельца', style: TextStyles.labelMedium),
                  const SizedBox(height: 8),
                  Obx(() => TextField(
                    onTapOutside: (event) {
                      FocusScope.of(context).unfocus();
                      isCardholderNameFocused.value = false;
                    },
                    onTap: () => isCardholderNameFocused.value = true,
                    controller: cardholderNameController,
                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                    textCapitalization: TextCapitalization.words,
                    onChanged: (value) {
                      validateCardholderName(value);
                    },
                    decoration: InputDecoration(
                      hintText: 'IVAN IVANOV',
                      hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                      filled: true,
                      fillColor: Palette.red400,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Palette.white100, width: 1),
                      ),
                      errorText: (shouldShowErrors.value && cardholderNameError.value.isNotEmpty) ? cardholderNameError.value : null,
                      errorStyle: TextStyles.bodySmall.copyWith(color: Palette.error),
                    ),
                  )),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Срок действия', style: TextStyles.labelMedium),
                            const SizedBox(height: 8),
                            Row(
                            
                              children: [
                                Expanded(
                                  child: TextField(
                                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                                    controller: expiryMonthController,
                                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    onChanged: (value) {
                                      validateExpiry(expiryMonthController.text, expiryYearController.text);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'ММ',
                                      hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                      filled: true,
                                      fillColor: Palette.red400,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: TextField(
                                    onTapOutside: (event) => FocusScope.of(context).unfocus(),
                                    controller: expiryYearController,
                                    style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(2),
                                    ],
                                    onChanged: (value) {
                                      validateExpiry(expiryMonthController.text, expiryYearController.text);
                                    },
                                    decoration: InputDecoration(
                                      hintText: 'ГГ',
                                      hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                      filled: true,
                                      fillColor: Palette.red400,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Obx(() => Container(
                                  height: 20,
                                  alignment: Alignment.centerLeft,
                                  padding: const EdgeInsets.only(left: 4, top: 4),
                                  child: (shouldShowErrors.value && expiryError.value.isNotEmpty)
                                      ? Text(
                                          expiryError.value,
                                          style: TextStyles.bodySmall.copyWith(color: Palette.error),
                                        )
                                      : null,
                                )),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CVV', style: TextStyles.labelMedium),
                            const SizedBox(height: 8),
                            TextField(
                              onTapOutside: (event) => FocusScope.of(context).unfocus(),
                              controller: cvvController,
                              style: TextStyles.bodyLarge.copyWith(color: Palette.white100),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                              onChanged: (value) {
                                validateCvv(value);
                              },
                              decoration: InputDecoration(
                                hintText: '123',
                                hintStyle: TextStyles.bodyLarge.copyWith(color: Palette.grey350),
                                filled: true,
                                fillColor: Palette.red400,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                            // Ошибка CVV под полем
                            Obx(() => Container(
                              height: 20,
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.only(left: 4, top: 4),
                              child: (shouldShowErrors.value && cvvError.value.isNotEmpty)
                                  ? Text(
                                      cvvError.value,
                                      style: TextStyles.bodySmall.copyWith(color: Palette.error),
                                    )
                                  : null,
                            )),
                          ],
                        ),
                      ),
                    ],
                  ),
                   SizedBox(height: 20.sp),
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ButtonStyles.primary,
                      onPressed: isLoading.value ? null : () async {
                        // Validate all fields first
                        if (!validateAllFields()) {
                          return; // Stop if validation fails
                        }

                        try {
                          isLoading.value = true;
                          
                          // Проверяем количество карт
                          final cardsCount = await _paymentService.getCardsCount();
                          if (cardsCount > 2) {
                            Get.snackbar(
                              'Ошибка',
                              'Достигнуто максимальное количество карт (2)',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Palette.red400,
                              colorText: Palette.white100,
                            );
                            return;
                          }

                          await _paymentService.addCard(
                            cardNumber: cardNumberController.text,
                            cardholderName: cardholderNameController.text,
                            expiryMonth: expiryMonthController.text,
                            expiryYear: expiryYearController.text,
                            cvv: cvvController.text,
                          );
                          Get.back();
                          Get.snackbar(
                            'Успех',
                            'Карта успешно добавлена',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Palette.red400,
                            colorText: Palette.white100,
                          );
                        } catch (e) {
                          String errorMessage = 'Не удалось добавить карту';
                          if (e.toString().contains('User not authenticated')) {
                            errorMessage = 'Необходимо войти в аккаунт';
                          }
                          Get.snackbar(
                            'Ошибка',
                            errorMessage,
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Palette.red400,
                            colorText: Palette.white100,
                          );
                        } finally {
                          isLoading.value = false;
                        }
                      },
                      child: isLoading.value
                          ? const CircularProgressIndicator(color: Palette.white100)
                          : Text('Добавить карту', style: TextStyles.buttonSmall),
                    ),
                  )),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 