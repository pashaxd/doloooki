import 'package:doloooki/utils/button_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/request_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/presentation/controllers/chat_controller.dart';
import 'package:doloooki/utils/palette.dart';
import 'package:doloooki/utils/text_styles.dart';

class ChatScreen extends StatelessWidget {
  final RequestModel request;
  
  const ChatScreen({super.key, required this.request});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());
    controller.initializeChat(request);
    
    return Scaffold(
      backgroundColor: Palette.red600,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Palette.red600,
        title: Text(
          'Стилист ${request.stylistName}',
          style: TextStyles.titleLarge.copyWith(color: Palette.white100),
        ),
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios, color: Palette.white100),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => controller.finishConsultation(),
            style: ButtonStyles.primary,
            child: Text('Завершить', style: TextStyles.bodyMedium.copyWith(color: Palette.white100)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Список сообщений
          Expanded(
            child: Obx(() => ListView.builder(
              controller: controller.scrollController,
              padding: EdgeInsets.all(16.sp),
              itemCount: controller.messages.length,
              itemBuilder: (context, index) {
                final message = controller.messages[index];
                
                if (message.type == 'request') {
                  return _buildRequestCard(message, controller);
                } else if (message.type == 'text') {
                  return _buildTextMessage(message, controller);
                } else if (message.type == 'image') {
                  return _buildImageMessage(message, controller);
                }
                
                return SizedBox.shrink();
              },
            )),
          ),
          request.status == 'Завершена' ? Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.sp),
            child: Container(
              padding: EdgeInsets.all(10.sp),
              width: double.infinity,
              height: 100.sp,
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(12.sp),
                border: Border.all(color: Palette.red200, width: 1),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Консультация завершена', style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                  SizedBox(height: 6.sp),
                  Obx(() => controller.isReviewSubmitted.value ? 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 20.sp),
                        SizedBox(width: 4.sp),
                        Text('Отзыв отправлен', style: TextStyles.bodySmall.copyWith(color: Colors.green)),
                      ],
                    ) : 
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Palette.red100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.sp),
                        ),
                      ),
                      onPressed: () => controller.showReviewBottomSheet(), 
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset('assets/icons/stylist/rate.svg', width: 20.sp, height: 20.sp, color: Palette.white100),
                          SizedBox(width: 4.sp),
                          Text('Оценить консультацию', style: TextStyles.buttonSmall.copyWith(color: Palette.white100)),
                        ],
                      )
                    ),
                  ),
                ],
              ),
            ),
          ) : SizedBox.shrink(),
          SizedBox(height: 10.sp),
          // Поле ввода сообщения
          request.status == 'Завершена' ?   
          Container(
            padding: EdgeInsets.all(8.sp),
            width: double.infinity,
            height: 100.sp,
            decoration: BoxDecoration(
              color: Palette.red600,
              border: Border(top: BorderSide(color: Palette.red400, width: 1)),
            ),
            child: Column(
              spacing: 6.sp,
              children: [
                Text('Консультация завершена', style: TextStyles.titleSmall.copyWith(color: Palette.white100)),
                Text('Чат закрыт. Вы можете просматривать переписку и созданные образы, но новые сообщения отправлять нельзя.', style: TextStyles.bodySmall.copyWith(color: Palette.grey200), textAlign: TextAlign.center,),
                
                // Кнопка оценки, если еще не оценено
               
              ],
            ),
          )
          
          :_buildMessageInput(controller),
          Obx(() => controller.isLoading.value
            ? CircularProgressIndicator()
            : SizedBox.shrink(),)
          
        ],
      ),
    );
  }

  Widget _buildRequestCard(message, ChatController controller) {
    final metadata = message.metadata ?? {};
    final fullBodyImages = List<String>.from(metadata['fullBodyImages'] ?? request.fullBodyImages);
    final portraitImages = List<String>.from(metadata['portraitImages'] ?? request.portraitImages);
    final allImages = [...fullBodyImages, ...portraitImages];
    
    return Container(
      margin: EdgeInsets.only(bottom: 16.sp),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Метка "Request"
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.sp, vertical: 6.sp),
            decoration: BoxDecoration(
              color: Palette.red100,
              borderRadius: BorderRadius.circular(12.sp),
            ),
            child: Text(
              'Request',
              style: TextStyles.labelMedium.copyWith(color: Palette.white100),
            ),
          ),
          
          SizedBox(height: 12.sp),
          
          // Основная карточка с информацией
          Container(
            padding: EdgeInsets.all(16.sp),
            decoration: BoxDecoration(
              color: Palette.red400,
              borderRadius: BorderRadius.circular(16.sp),
              border: Border.all(color: Palette.red100, width: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок
                Text(
                  'Запрос от Пользователя',
                  style: TextStyles.titleMedium.copyWith(color: Palette.white100),
                ),
                
                SizedBox(height: 12.sp),
                
                // Описание запроса
                Text(
                  metadata['description'] ?? request.request,
                  style: TextStyles.bodyMedium.copyWith(color: Palette.grey200),
                ),
                
                SizedBox(height: 16.sp),
                
                // Фотографии клиента
                if (allImages.isNotEmpty) ...[
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: allImages.map((imageUrl) => Container(
                        width: 80.sp,
                        height: 100.sp,
                        margin: EdgeInsets.only(right: 8.sp),
                        decoration: BoxDecoration(
                          color: Palette.red600,
                          borderRadius: BorderRadius.circular(12.sp),
                          image: DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                  
                  SizedBox(height: 12.sp),
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

  Widget _buildTextMessage(message, ChatController controller) {
    final isFromUser = message.senderId != request.stylistId && message.senderId != 'system';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
         
          
          Flexible(
            child: IntrinsicWidth(
              child: Container(
                constraints: BoxConstraints(maxWidth: 0.8.sw),
                padding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                decoration: BoxDecoration(
                  color: isFromUser ? Palette.red200 : Palette.red400,
                  borderRadius: BorderRadius.circular(20.sp),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                    ),
                    SizedBox(height: 4.sp),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        controller.formatMessageTime(message.createdAt),
                        style: TextStyles.labelSmall.copyWith(color: Palette.grey350),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
         
        ],
      ),
    );
  }

  Widget _buildImageMessage(message, ChatController controller) {
    final isFromUser = message.senderId != request.stylistId && message.senderId != 'system';
    
    return Container(
      margin: EdgeInsets.only(bottom: 12.sp),
      child: Row(
        mainAxisAlignment: isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
         
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16.sp),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 200.sp,
                      height: 200.sp,
                      color: Palette.red400,
                      child: message.content.isNotEmpty
                        ? Image.network(
                            message.content,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => 
                              Container(
                                color: Palette.red400,
                                child: Icon(Icons.broken_image, color: Palette.grey350, size: 40.sp),
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
                        : Icon(Icons.image, color: Palette.grey350, size: 40.sp),
                    ),
                   
                         
                  ],
                ),
              ),
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

  Widget _buildMessageInput(ChatController controller) {
    return Container(
      padding: EdgeInsets.all(16.sp),
      decoration: BoxDecoration(
        color: Palette.red600,
        border: Border(top: BorderSide(color: Palette.red400, width: 1)),
      ),
      child: Row(
        children: [
          // Кнопка прикрепления изображения
          GestureDetector(
            onTap: () {
             Get.bottomSheet(
                    Container(
                      height: 200.sp,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Palette.red600,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 10.sp),
                          Container(
                            width: 50.sp,
                            height: 5.sp,
                            decoration: BoxDecoration(
                              color: Palette.grey300,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          SizedBox(height: 20.sp),
                          Text('Загрузка фотографии', style: TextStyles.titleLarge),
                          SizedBox(height: 20.sp),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                  controller.pickImageFromCamera();
                                },
                                child: Container(
                                  width: 150.sp,
                                  height: 100.sp,
                                  decoration: BoxDecoration(
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Palette.red100,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/profile/camera.svg',
                                              width: 20.sp,
                                              height: 20.sp,
                                              colorFilter: ColorFilter.mode(Palette.white100, BlendMode.srcIn),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.sp),
                                        Text('Камера', style: TextStyles.labelMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.back();
                                  controller.pickImageFromGallery();
                                },
                                child: Container(
                                  width: 150.sp,
                                  height: 100.sp,
                                  decoration: BoxDecoration(
                                    color: Palette.red400,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 60,
                                          height: 60,
                                          decoration: BoxDecoration(
                                            color: Palette.red100,
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Center(
                                            child: SvgPicture.asset(
                                              'assets/icons/profile/galery.svg',
                                              width: 20.sp,
                                              height: 20.sp,
                                              colorFilter: ColorFilter.mode(Palette.white100, BlendMode.srcIn),
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 5.sp),
                                        Text('Галерея', style: TextStyles.labelMedium),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    isScrollControlled: true,
                  );
            },
            child: Container(
              width: 20.sp,
              height: 20.sp,
              decoration: BoxDecoration(
                color: Palette.red400,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/stylist/gallery.svg',
                width: 20.sp,
                height: 20.sp,
                  color: Palette.grey350,
              ),
            ),
          ),
          
          SizedBox(width: 12.sp),
          
          // Поле ввода текста
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Palette.red400,
                borderRadius: BorderRadius.circular(25.sp),
              ),
              child: TextField(
                controller: controller.messageController,
                style: TextStyles.bodyMedium.copyWith(color: Palette.white100),
                decoration: InputDecoration(
                  hintText: 'Написать сообщение...',
                  hintStyle: TextStyles.bodyMedium.copyWith(color: Palette.grey350),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.sp, vertical: 12.sp),
                ),
                onSubmitted: (_) => controller.sendMessage(),
              ),
            ),
          ),
          
          SizedBox(width: 12.sp),
          
          // Кнопка отправки
          Obx(() => GestureDetector(
            onTap: controller.isSending.value ? null : controller.sendMessage,
            child: Container(
              width: 20.sp,
              height: 20.sp,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: Container(
                width: 20.sp,
              height: 20.sp,
              decoration: BoxDecoration(
              
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                'assets/icons/stylist/send.svg',
                color: Palette.grey350,
                width: 20.sp,
                height: 20.sp,
              ),
            ),
            ),
          )),
        ],
      ),
    );
  }
}