import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BackgroundRemovalService {
  static const String _apiUrl = 'https://api.pixian.ai/api/v2/remove-background';
  static const String _apiId = 'pxz3tapmwavcmsc'; // Замените на ваш API ID
  static const String _apiSecret = 'h1h94j9jssdd0n0sm5i39ln6cu7rdt297nd4qsk4gg6v9mknsd8g'; // Замените на ваш API Secret
  
  /// Удаляет фон с изображения используя API pixian.ai
  /// 
  /// [imageFile] - файл изображения для обработки
  /// [isTest] - тестовый режим (бесплатно с водяным знаком)
  /// 
  /// Возвращает [Uint8List] с обработанным изображением или null в случае ошибки
  static Future<Uint8List?> removeBackground(File imageFile, {bool isTest = true}) async {
    try {
      print('🚀 Starting background removal with pixian.ai API...');
      
      // Проверяем размер файла
      final fileSizeBytes = await imageFile.length();
      final fileSizeMB = fileSizeBytes / (1024 * 1024);
      print('📁 Image file size: ${fileSizeMB.toStringAsFixed(2)} MB');
      
      if (fileSizeMB > 30) { // pixian.ai поддерживает до 30MB
        print('❌ File too large: ${fileSizeMB.toStringAsFixed(2)} MB (max 30 MB)');
        return null;
      }
      
      // Читаем файл как байты
      final imageBytes = await imageFile.readAsBytes();
      print('📷 Image bytes length: ${imageBytes.length}');
      
      // Создаем multipart запрос
      final request = http.MultipartRequest('POST', Uri.parse(_apiUrl));
      
      // Добавляем HTTP Basic Auth
      final credentials = base64Encode(utf8.encode('$_apiId:$_apiSecret'));
      request.headers['Authorization'] = 'Basic $credentials';
      
      print('🔑 Using API ID: $_apiId');
      print('🌐 API URL: $_apiUrl');
      print('🧪 Test mode: $isTest');
      
      // Добавляем изображение
      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'image.jpg',
        ),
      );
      
      // Добавляем параметры API
      request.fields['test'] = isTest.toString();
      request.fields['max_pixels'] = '5000000'; // 5 мегапикселей
      request.fields['output.format'] = 'png'; // PNG для прозрачного фона
      
      print('📤 Sending request to pixian.ai API...');
      print('📋 Parameters: test=$isTest, max_pixels=5000000 (5MP), output.format=png');
      
      // Отправляем запрос с таймаутом
      final streamedResponse = await request.send().timeout(
        Duration(seconds: 180), // pixian.ai рекомендует 180 секунд
        onTimeout: () {
          throw Exception('Request timeout after 180 seconds');
        },
      );
      
      final response = await http.Response.fromStream(streamedResponse);
      
      print('📥 Response status: ${response.statusCode}');
      print('📋 Response headers: ${response.headers}');
      
      if (response.statusCode == 200) {
        // pixian.ai возвращает изображение напрямую
        final contentType = response.headers['content-type'] ?? '';
        print('📄 Content-Type: $contentType');
        
        // Проверяем дополнительные заголовки от pixian.ai
        if (response.headers.containsKey('x-credits-charged')) {
          print('💰 Credits charged: ${response.headers['x-credits-charged']}');
        }
        if (response.headers.containsKey('x-credits-calculated')) {
          print('🧮 Credits calculated: ${response.headers['x-credits-calculated']}');
        }
        if (response.headers.containsKey('x-result-size')) {
          print('📏 Result size: ${response.headers['x-result-size']}');
        }
        
        if (contentType.startsWith('image/')) {
          print('✅ Success! Image processed, size: ${response.bodyBytes.length} bytes');
          return response.bodyBytes;
        } else {
          print('❌ Unexpected content type: $contentType');
          print('📄 Response body: ${response.body}');
          return null;
        }
      } else {
        print('❌ API Error: ${response.statusCode}');
        print('📄 Response body: ${response.body}');
        
        // Пытаемся распарсить JSON ошибку от pixian.ai
        try {
          final errorJson = json.decode(response.body);
          if (errorJson['error'] != null) {
            final error = errorJson['error'];
            print('📋 Error details:');
            print('   Status: ${error['status']}');
            print('   Code: ${error['code']}');
            print('   Message: ${error['message']}');
          }
        } catch (e) {
          print('📄 Raw error response: ${response.body}');
        }
        
        return null;
      }
    } catch (e) {
      print('💥 Background removal error: $e');
      print('📍 Error type: ${e.runtimeType}');
      return null;
    }
  }
  
  /// Проверяет статус аккаунта pixian.ai
  static Future<Map<String, dynamic>?> checkAccountStatus() async {
    try {
      print('🔍 Checking pixian.ai account status...');
      
      final credentials = base64Encode(utf8.encode('$_apiId:$_apiSecret'));
      
      final response = await http.get(
        Uri.parse('https://api.pixian.ai/api/v2/account'),
        headers: {
          'Authorization': 'Basic $credentials',
        },
      ).timeout(Duration(seconds: 10));
      
      print('📊 Account status response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final accountData = json.decode(response.body);
        print('📋 Account info:');
        print('   Credit Pack: ${accountData['creditPack']}');
        print('   State: ${accountData['state']}');
        print('   Credits: ${accountData['credits']}');
        print('   Use Before: ${accountData['useBefore']}');
        
        return accountData;
      } else {
        print('❌ Account status check failed: ${response.statusCode}');
        print('📄 Response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('❌ Account status check failed: $e');
      return null;
    }
  }
  
  /// Тестовый метод для проверки подключения к pixian.ai API
  static Future<void> testApiConnection() async {
    try {
      print('🧪 Testing pixian.ai API connection...');
      print('🔑 Using API ID: $_apiId');
      print('🌐 API URL: $_apiUrl');
      
      // Проверяем статус аккаунта
      final accountStatus = await checkAccountStatus();
      
      if (accountStatus != null) {
        print('✅ API connection successful!');
        print('🎯 Ready to process images');
        print('💡 Use test=true for free processing with watermark');
        print('💰 Use test=false for production quality (requires credits)');
      } else {
        print('❌ API connection failed - check credentials');
      }
      
    } catch (e) {
      print('💥 Test connection failed: $e');
    }
  }
} 