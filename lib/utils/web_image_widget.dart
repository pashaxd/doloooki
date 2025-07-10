import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:math' as math;

class WebImageWidget extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? debugName;
  final bool isCircular;

  const WebImageWidget({
    Key? key,
    required this.imageUrl,
    required this.width,
    required this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.debugName,
    this.isCircular = false,
  }) : super(key: key);

  // Автоматическая замена URL старого проекта на новый
  String _fixFirebaseUrl(String originalUrl) {
    // Исправляем URL если это старый проект
    if (originalUrl.contains('dolooki-fb888.firebasestorage.app')) {
      originalUrl = originalUrl.replaceAll(
        'dolooki-fb888.firebasestorage.app',
        'dolooki-2c346.firebasestorage.app'
      );
      print('🔧 Fixed image URL from fb888 to 2c346');
    }
    
    // Также для старого домена googleapis.com
    if (originalUrl.contains('firebasestorage.googleapis.com/v0/b/dolooki-fb888.firebasestorage.app')) {
      originalUrl = originalUrl.replaceAll(
        'firebasestorage.googleapis.com/v0/b/dolooki-fb888.firebasestorage.app',
        'firebasestorage.googleapis.com/v0/b/dolooki-2c346.firebasestorage.app'
      );
      print('🔧 Fixed googleapis URL from fb888 to 2c346');
    }
    
    return originalUrl;
  }

  Future<String> _getFirebaseUrl(String originalUrl) async {
    try {
      // Сначала исправляем URL
      final fixedUrl = _fixFirebaseUrl(originalUrl);
      
      // Если это Firebase Storage URL, попробуем получить свежий download URL
      if (fixedUrl.contains('firebasestorage.googleapis.com')) {
        final uri = Uri.parse(fixedUrl);
        final pathSegments = uri.pathSegments;
        
        // Извлекаем путь файла из URL
        if (pathSegments.length >= 3 && pathSegments[1] == 'o') {
          final filePath = Uri.decodeComponent(pathSegments[2]);
          print('🔄 Getting fresh download URL for: $filePath');
          
          final ref = FirebaseStorage.instance.ref(filePath);
          final newUrl = await ref.getDownloadURL();
          
          print('✅ Got fresh download URL: $newUrl');
          return newUrl;
        }
      }
      
      // Если не удалось извлечь путь, возвращаем исправленный URL
      return fixedUrl;
    } catch (e) {
      print('❌ Error getting Firebase URL: $e');
      return _fixFirebaseUrl(originalUrl); // Возвращаем хотя бы исправленный URL
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🔄 Loading image: ${debugName ?? "unknown"}');

    // Для круглых изображений используем квадратные размеры
    final displayWidth = isCircular ? math.min(width, height) : width;
    final displayHeight = isCircular ? math.min(width, height) : height;

    if (kIsWeb) {
      return FutureBuilder<String>(
        future: _getFirebaseUrl(imageUrl),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return placeholder ?? _buildDefaultPlaceholder();
          }

          if (snapshot.hasError || !snapshot.hasData) {
            print('❌ Failed to get URL for ${debugName ?? "unknown"}: ${snapshot.error}');
            return errorWidget ?? _buildDefaultError();
          }

          final finalUrl = snapshot.data!;
          print('🌐 Final URL for ${debugName ?? "unknown"}: $finalUrl');

          Widget imageWidget = Image.network(
            finalUrl,
            width: displayWidth,
            height: displayHeight,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) {
                print('✅ Web image loaded: ${debugName ?? "unknown"}');
                return child;
              }
              return placeholder ?? _buildDefaultPlaceholder();
            },
            errorBuilder: (context, error, stackTrace) {
              print('❌ Web image failed: ${debugName ?? "unknown"} - $error');
              return errorWidget ?? _buildDefaultError();
            },
          );

          // Если нужно круглое изображение, оборачиваем в ClipOval
          if (isCircular) {
            return ClipOval(
              child: SizedBox(
                width: displayWidth,
                height: displayHeight,
                child: imageWidget,
              ),
            );
          }

          return imageWidget;
        },
      );
    } else {
      // Для мобильных используем CachedNetworkImage с исправленным URL
      final fixedUrl = _fixFirebaseUrl(imageUrl);
      print('📱 Mobile image URL fixed: ${debugName ?? "unknown"} -> $fixedUrl');
      
      Widget imageWidget = CachedNetworkImage(
        imageUrl: imageUrl,
        width: displayWidth,
        height: displayHeight,
        fit: BoxFit.cover,
        placeholder: (context, url) => placeholder ?? _buildDefaultPlaceholder(),
        errorWidget: (context, url, error) {
          print('❌ Mobile image failed: ${debugName ?? "unknown"} - $error');
          return errorWidget ?? _buildDefaultError();
        },
      );

      // Если нужно круглое изображение, оборачиваем в ClipOval
      if (isCircular) {
        return ClipOval(
          child: SizedBox(
            width: displayWidth,
            height: displayHeight,
            child: imageWidget,
          ),
        );
      }

      return imageWidget;
    }
  }

  Widget _buildDefaultPlaceholder() {
    final displayWidth = isCircular ? math.min(width, height) : width;
    final displayHeight = isCircular ? math.min(width, height) : height;
    
    Widget placeholder = Container(
      width: displayWidth,
      height: displayHeight,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );

    if (isCircular) {
      return ClipOval(child: placeholder);
    }
    
    return placeholder;
  }

  Widget _buildDefaultError() {
    final displayWidth = isCircular ? math.min(width, height) : width;
    final displayHeight = isCircular ? math.min(width, height) : height;
    
    Widget errorWidget = Container(
      width: displayWidth,
      height: displayHeight,
      color: Colors.grey[400],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );

    if (isCircular) {
      return ClipOval(child: errorWidget);
    }
    
    return errorWidget;
  }
} 