import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageLoader {
  // Автоматическая замена URL старого проекта на новый
  static String fixFirebaseUrl(String imageUrl) {
    // Заменяем старый проект на новый
    if (imageUrl.contains('dolooki-fb888.firebasestorage.app')) {
      final fixedUrl = imageUrl.replaceAll(
        'dolooki-fb888.firebasestorage.app',
        'dolooki-2c346.firebasestorage.app'
      );
      print('🔧 Fixed URL: $imageUrl -> $fixedUrl');
      return fixedUrl;
    }
    
    // Также проверяем старый домен googleapis.com
    if (imageUrl.contains('firebasestorage.googleapis.com/v0/b/dolooki-fb888.firebasestorage.app')) {
      final fixedUrl = imageUrl.replaceAll(
        'firebasestorage.googleapis.com/v0/b/dolooki-fb888.firebasestorage.app',
        'firebasestorage.googleapis.com/v0/b/dolooki-2c346.firebasestorage.app'
      );
      print('🔧 Fixed googleapis URL: $imageUrl -> $fixedUrl');
      return fixedUrl;
    }
    
    return imageUrl;
  }

  static Widget loadImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    String? debugName,
  }) {
    if (imageUrl.isEmpty) {
      return errorWidget ?? _defaultErrorWidget(width, height);
    }

    // Исправляем URL перед загрузкой
    final fixedUrl = fixFirebaseUrl(imageUrl);

    // Debug информация
    if (debugName != null) {
      print('🔄 Loading image: $debugName');
      print('🌐 Final URL for $debugName: $fixedUrl');
    }

    if (kIsWeb) {
      return _loadWebImage(
        imageUrl: fixedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        debugName: debugName,
      );
    } else {
      return _loadMobileImage(
        imageUrl: fixedUrl,
        width: width,
        height: height,
        fit: fit,
        placeholder: placeholder,
        errorWidget: errorWidget,
        debugName: debugName,
      );
    }
  }

  static Widget _loadWebImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    String? debugName,
  }) {
    return FutureBuilder<String>(
      future: _getDownloadUrl(imageUrl),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _defaultPlaceholder(width, height);
        }

        if (snapshot.hasError || !snapshot.hasData) {
          print('❌ Failed to get download URL for ${debugName ?? 'unknown'}: ${snapshot.error}');
          return errorWidget ?? _defaultErrorWidget(width, height);
        }

        final downloadUrl = snapshot.data!;
        print('✅ Got download URL for ${debugName ?? 'unknown'}: $downloadUrl');

        return Image.network(
          downloadUrl,
          width: width,
          height: height,
          fit: fit,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('✅ Image loaded successfully: ${debugName ?? 'unknown'}');
              return child;
            }
            return placeholder ?? _defaultPlaceholder(width, height);
          },
          errorBuilder: (context, error, stackTrace) {
            print('❌ Image network error for ${debugName ?? 'unknown'}: $error');
            return errorWidget ?? _defaultErrorWidget(width, height);
          },
        );
      },
    );
  }

  static Widget _loadMobileImage({
    required String imageUrl,
    required double width,
    required double height,
    BoxFit fit = BoxFit.cover,
    Widget? placeholder,
    Widget? errorWidget,
    String? debugName,
  }) {
    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _defaultPlaceholder(width, height);
      },
      errorBuilder: (context, error, stackTrace) {
        print('❌ Mobile image error for ${debugName ?? 'unknown'}: $error');
        return errorWidget ?? _defaultErrorWidget(width, height);
      },
    );
  }

  static Future<String> _getDownloadUrl(String imageUrl) async {
    try {
      // Если это уже готовый HTTP URL, используем его
      if (imageUrl.startsWith('http')) {
        // Проверим что это Firebase Storage URL
        if (imageUrl.contains('firebasestorage.googleapis.com') || 
            imageUrl.contains('firebasestorage.app')) {
          
          // Добавляем alt=media если его нет
          if (!imageUrl.contains('alt=media')) {
            final uri = Uri.parse(imageUrl);
            final newQuery = uri.hasQuery ? '${uri.query}&alt=media' : 'alt=media';
            final newUri = uri.replace(query: newQuery);
            return newUri.toString();
          }
          
          return imageUrl;
        }
        return imageUrl;
      }

      // Если это путь в Storage, получаем download URL
      final ref = FirebaseStorage.instance.ref(imageUrl);
      return await ref.getDownloadURL();
    } catch (e) {
      print('❌ Error getting download URL: $e');
      throw e;
    }
  }

  static Widget _defaultPlaceholder(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[300],
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  static Widget _defaultErrorWidget(double width, double height) {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[400],
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
      ),
    );
  }
} 