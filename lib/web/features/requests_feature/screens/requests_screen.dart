import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/responsive_utils.dart';
import 'package:doloooki/utils/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doloooki/web/features/requests_feature/controllers/request_cotnroller.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/request_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/message_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doloooki/web/core/presentation/left_navigation/controllers/left_navigation_controller.dart';
import 'package:doloooki/web/features/users_feature/controllers/users_controller.dart';

class RequestsScreen extends StatelessWidget {
  const RequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestController());
    
    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.all(20.adaptiveSpacing),
      child: Row(
        children: [
          // Левая панель - список консультаций
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                color: Palette.red600,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок
                  Container(
                    padding: EdgeInsets.all(20.adaptiveSpacing),
                    decoration: BoxDecoration(
                      color: Palette.red500,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Консультации',
                          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () => controller.refreshRequests(),
                          icon: Icon(Icons.refresh, color: Palette.white100),
                        ),
                      ],
                    ),
                  ),
                  
                  // Список консультаций
                  Expanded(
                    child: Obx(() {
                      if (controller.isLoading.value) {
                        return const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }
                      
                      if (controller.requests.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                'assets/icons/left_navigation/consultations.svg',
                                width: 60.adaptiveIcon,
                                height: 60.adaptiveIcon,
                                color: Palette.grey350,
                              ),
                              SizedBox(height: 16.adaptiveSpacing),
                              Text(
                                'Консультаций пока нет',
                                style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 8.adaptiveSpacing),
                              Text(
                                'Новые консультации появятся здесь',
                                style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return ListView.separated(
                        padding: EdgeInsets.all(16.adaptiveSpacing),
                        itemCount: controller.requests.length,
                        separatorBuilder: (context, index) => SizedBox(height: 12.adaptiveSpacing),
                        itemBuilder: (context, index) {
                          final request = controller.requests[index];
                          return _buildRequestCard(request, controller);
                        },
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          
          SizedBox(width: 20.adaptiveSpacing),
          
          // Правая панель - чат
          Expanded(
            flex: 2,
            child: Obx(() {
              final currentRequest = controller.currentRequest.value;
              
              if (currentRequest == null) {
                return Container(
                  decoration: BoxDecoration(
                    color: Palette.red600,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          size: 80.adaptiveIcon,
                          color: Palette.grey350,
                        ),
                        SizedBox(height: 16.adaptiveSpacing),
                        Text(
                          'Выберите консультацию',
                          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
                        ),
                        SizedBox(height: 8.adaptiveSpacing),
                        Text(
                          'Выберите консультацию из списка\nчтобы начать переписку',
                          style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }
              
              return _buildChatPanel(currentRequest, controller);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestCard(RequestModel request, RequestController controller) {
    return Obx(() {
      final isSelected = controller.currentRequest.value?.id == request.id;
      
      return GestureDetector(
        onTap: () => controller.loadMessages(request),
        child: Container(
          padding: EdgeInsets.all(16.adaptiveSpacing),
          decoration: BoxDecoration(
            color: isSelected ? Palette.red400 : Palette.red500,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Palette.grey350, 
              width: 2,
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: controller.getUserImage(request.userId).isNotEmpty
                  ? Image.network(
                      controller.getUserImage(request.userId),
                      width: 120.adaptiveIcon,
                      height: 120.adaptiveIcon,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 40.adaptiveIcon,
                        height: 40.adaptiveIcon,
                        decoration: BoxDecoration(
                          color: Palette.grey350,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(Icons.person, color: Palette.white100, size: 20.adaptiveIcon),
                      ),
                    )
                  : Container(
                      width: 40.adaptiveIcon,
                      height: 40.adaptiveIcon,
                      decoration: BoxDecoration(
                        color: Palette.grey350,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Icon(Icons.person, color: Palette.white100, size: 20.adaptiveIcon),
                    ),
              ),
              
              SizedBox(width: 20.adaptiveSpacing),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Имя пользователя и статус
                    Row(
                      children: [
                        // Имя пользователя
                        Expanded(
                          child: Text(
                            controller.getUserName(request.userId),
                            style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        SizedBox(width: 8.adaptiveSpacing),
                        
                        // Статус
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.adaptiveSpacing, vertical: 4.adaptiveSpacing),
                          decoration: BoxDecoration(
                            color: controller.getStatusColor(request.status).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            request.status,
                            style: TextStyles.labelSmall.copyWith(
                              color: controller.getStatusColor(request.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    SizedBox(height: 8.adaptiveSpacing),
                    
                    // Заголовок запроса
                    Text(
                      request.title,
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey200),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    SizedBox(height: 8.adaptiveSpacing),
                    
                    // Дата и количество образов
                    Row(
                      children: [
                        Text(
                          controller.formatRequestDate(request.createdAt),
                          style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                        ),
                        Text(
                          ' • ${request.looksCount} образа',
                          style: TextStyles.bodySmall.copyWith(color: Palette.grey350),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildChatPanel(RequestModel request, RequestController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Palette.red600,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          // Заголовок чата
          Container(
            padding: EdgeInsets.all(20.adaptiveSpacing),
            decoration: BoxDecoration(
              color: Palette.red500,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      request.title,
                      style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                    ),
                    Text(
                      'Клиент • ${request.looksCount} образа',
                      style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                    ),
                  ],
                ),
                const Spacer(),
                if (request.status == 'В процессе')
                  ElevatedButton(
                    onPressed: () => controller.finishConsultation(request.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Palette.red100,
                      foregroundColor: Palette.white100,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Завершить',
                      style: TextStyles.buttonSmall.copyWith(color: Palette.white100),
                    ),
                  ),
              ],
            ),
          ),
          
          // Сообщения
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              reverse: true,
              padding: EdgeInsets.all(16.adaptiveSpacing),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[controller.messages.length - 1 - index];
                
                if (message.type == 'request') {
                  return _buildRequestMessage(message, request, controller);
                } else if (message.type == 'text') {
                  return _buildTextMessage(message, request, controller);
                } else if (message.type == 'image') {
                  return _buildImageMessage(message, request, controller);
                }
                
                return const SizedBox.shrink();
              },
            )),
          ),
          
          // Панель ввода сообщения
          if (request.status == 'В процессе')
            _buildMessageInput(controller)
          else
            Container(
              padding: EdgeInsets.all(16.adaptiveSpacing),
              decoration: BoxDecoration(
                color: Palette.red600,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, color: Palette.grey350, size: 20.adaptiveIcon),
                  SizedBox(width: 8.adaptiveSpacing),
                  Text(
                    'Консультация завершена',
                    style: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildRequestMessage(MessageModel message, RequestModel request, RequestController controller) {
    final metadata = message.metadata ?? {};
    final fullBodyImages = List<String>.from(metadata['fullBodyImages'] ?? request.fullBodyImages);
    final portraitImages = List<String>.from(metadata['portraitImages'] ?? request.portraitImages);
    final allImages = [...fullBodyImages, ...portraitImages];
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.adaptiveSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Метка "Request"
          
          SizedBox(height: 12.adaptiveSpacing),
          
          // Основная карточка с информацией
          Container(
            padding: EdgeInsets.all(16.adaptiveSpacing),
            decoration: BoxDecoration(
              color: Palette.red500,
              borderRadius: BorderRadius.circular(16),
             
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  'Запрос от Пользователя',
                  style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                ),
                
                SizedBox(height: 12.adaptiveSpacing),
                
                // Описание запроса
                Text(
                  metadata['description'] ?? request.request,
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey200),
                ),
                
                SizedBox(height: 16.adaptiveSpacing),
                
                // Фотографии клиента
                if (allImages.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allImages.asMap().entries.map((entry) {
                        final imageUrl = entry.value;
                        return Container(
                          width: 300.adaptiveContainer,
                          height: 400.adaptiveContainer,
                          margin: EdgeInsets.only(right: 8.adaptiveSpacing),
                          decoration: BoxDecoration(
                            color: Palette.red600,
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  
                  SizedBox(height: 12.adaptiveSpacing),
                ],
                
                // Количество образов
                Text(
                  'Количество образов: ${metadata['looksCount'] ?? request.looksCount}',
                  style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextMessage(MessageModel message, RequestModel request, RequestController controller) {
    final user = FirebaseAuth.instance.currentUser;
    final isFromStylist = user != null && message.senderId == user.uid;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.adaptiveSpacing),
      child: Row(
        mainAxisAlignment: isFromStylist ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Flexible(
            child: Container(
              constraints: BoxConstraints(maxWidth: MediaQuery.of(Get.context!).size.width * 0.4),
              padding: EdgeInsets.symmetric(horizontal: 16.adaptiveSpacing, vertical: 12.adaptiveSpacing),
              decoration: BoxDecoration(
                color: isFromStylist ? Palette.red200 : Palette.red500,
                borderRadius: BorderRadius.circular(16),
                
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                  ),
                  SizedBox(height: 4.adaptiveSpacing),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      controller.formatMessageTime(message.createdAt),
                      style: TextStyles.labelSmall.copyWith(
                        color: isFromStylist ? Palette.grey200 : Palette.grey350,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageMessage(MessageModel message, RequestModel request, RequestController controller) {
    final user = FirebaseAuth.instance.currentUser;
    final isFromStylist = user != null && message.senderId == user.uid;
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.adaptiveSpacing),
      child: Row(
        mainAxisAlignment: isFromStylist ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: isFromStylist ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: 350.adaptiveContainer,
                  height: 450.adaptiveContainer,
                  color: Palette.red600,
                  child: message.content.isNotEmpty
                    ? Image.network(
                        message.content,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          Container(
                            color: Palette.red400,
                            child: Icon(Icons.broken_image, color: Palette.grey350, size: 40.adaptiveIcon),
                          ),
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              color: Palette.white100,
                              value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                            ),
                          );
                        },
                      )
                    : Icon(Icons.image, color: Palette.grey350, size: 40.adaptiveIcon),
                ),
              ),
              SizedBox(height: 4.adaptiveSpacing),
              Text(
                controller.formatMessageTime(message.createdAt),
                style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(RequestController controller) {
    return Container(
      padding: EdgeInsets.all(16.adaptiveSpacing),
      decoration: BoxDecoration(
        color: Palette.red600,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Кнопка "Создать образ"
          Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 40.adaptiveSpacing, left: 100.adaptiveSpacing, right: 100.adaptiveSpacing),
            child: ElevatedButton.icon(
              onPressed: () {
                final currentRequest = controller.currentRequest.value;
                if (currentRequest != null) {
                  try {
                    // Получаем контроллеры навигации
                    final leftNavController = Get.find<LeftNavigationController>();
                    final usersController = Get.find<UsersController>();
                    
                    // Переключаемся на вкладку пользователей (индекс 0)
                    leftNavController.changeIndex(0);
                    
                    // Выбираем конкретного пользователя для просмотра
                    usersController.selectUserForInfo(currentRequest.userId);
                    
                    print('🎨 Переход к созданию образа для пользователя: ${currentRequest.userId}');
                  } catch (e) {
                    print('❌ Ошибка при навигации: $e');
                    // Если контроллеры не найдены, создаем их
                    final leftNavController = Get.put(LeftNavigationController());
                    final usersController = Get.put(UsersController());
                    
                    leftNavController.changeIndex(0);
                    usersController.selectUserForInfo(currentRequest.userId);
                  }
                }
              },
              icon: Icon(Icons.palette, color: Palette.white100, size: 20.adaptiveIcon),
              label: Text(
                'Создать образ',
                style: TextStyles.buttonMedium.copyWith(color: Palette.white100),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Palette.red100,
                foregroundColor: Palette.white100,
                padding: EdgeInsets.symmetric(
                  horizontal: 20.adaptiveSpacing,
                  vertical: 12.adaptiveSpacing,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          
          // Панель ввода сообщения
          Row(
            children: [
              IconButton(onPressed: (){
                controller.pickImageFromFiles();
              }, icon: Icon(Icons.attach_file, color: Palette.grey350)),
              
              SizedBox(width: 12.adaptiveSpacing),
              
              // Поле ввода текста
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Palette.red400,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TextField(
                    controller: controller.messageController,
                    style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    decoration: InputDecoration(
                      hintText: 'Написать сообщение...',
                      hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.adaptiveSpacing, vertical: 12.adaptiveSpacing),
                    ),
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
              ),
              
              SizedBox(width: 12.adaptiveSpacing),
              
              // Кнопка отправки
              Obx(() => IconButton(
                onPressed: controller.isSending.value ? null : controller.sendMessage,
                icon: controller.isSending.value
                    ? SizedBox(
                        width: 20.adaptiveIcon,
                        height: 20.adaptiveIcon,
                        child: CircularProgressIndicator(
                          color: Palette.white100,
                          strokeWidth: 2,
                        ),
                      )
                    : Icon(Icons.send, color: Palette.red100),
              )),
            ],
          ),
        ],
      ),
    );
  }
}