import 'package:cloud_firestore/cloud_firestore.dart';

class PatternItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final Timestamp createdAt;
  final String userId;
  final List<Map<String, dynamic>> usedItems;
  final String category;

  PatternItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.createdAt,
    required this.userId,
    this.usedItems = const [],
    this.category = 'Woman',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'createdAt': createdAt,
      'userId': userId,
      'usedItems': usedItems,
      'category': category,
    };
  }

  factory PatternItem.fromMap(Map<String, dynamic> map) {
    try {
      print('🔍 Parsing PatternItem from map: ${map.keys}');
      
      // Безопасное извлечение usedItems
      List<Map<String, dynamic>> usedItemsList = [];
      final usedItemsData = map['usedItems'];
      
      print('👔 UsedItems data type: ${usedItemsData.runtimeType}');
      print('👔 UsedItems data: $usedItemsData');
      
      if (usedItemsData != null) {
        if (usedItemsData is List) {
          // Если usedItems это список
          for (var item in usedItemsData) {
            try {
              if (item is Map<String, dynamic>) {
                usedItemsList.add(item);
              } else if (item is Map) {
                // Конвертируем другие типы Map в Map<String, dynamic>
                usedItemsList.add(Map<String, dynamic>.from(item));
              } else {
                print('⚠️ UsedItem is not a Map: ${item.runtimeType}');
              }
            } catch (e) {
              print('❌ Error parsing usedItem: $e');
              continue;
            }
          }
        } else if (usedItemsData is Map) {
          // Если usedItems это Map (возможно LinkedMap)
          print('👔 UsedItems is a Map, converting to list...');
          usedItemsData.forEach((key, value) {
            try {
              if (value is Map<String, dynamic>) {
                usedItemsList.add(value);
              } else if (value is Map) {
                usedItemsList.add(Map<String, dynamic>.from(value));
              } else {
                print('⚠️ UsedItem value is not a Map: ${value.runtimeType}');
              }
            } catch (e) {
              print('❌ Error parsing usedItem $key: $e');
            }
          });
        } else {
          print('⚠️ Unexpected usedItems data type: ${usedItemsData.runtimeType}');
        }
      }
      
      final result = PatternItem(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        imageUrl: map['imageUrl']?.toString() ?? '',
        createdAt: map['createdAt'] ?? Timestamp.now(),
        userId: map['userId']?.toString() ?? '',
        usedItems: usedItemsList,
        category: map['category']?.toString() ?? 'Woman',
      );
      
      print('✅ Successfully parsed PatternItem: ${result.name} with ${result.usedItems.length} used items');
      return result;
    } catch (e) {
      print('❌ Error in PatternItem.fromMap: $e');
      print('📋 Map data: $map');
      
      // Возвращаем пустую модель в случае ошибки
      return PatternItem(
        id: map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? 'Unknown Pattern',
        description: map['description']?.toString() ?? '',
        imageUrl: map['imageUrl']?.toString() ?? '',
        createdAt: map['createdAt'] ?? Timestamp.now(),
        userId: map['userId']?.toString() ?? '',
        usedItems: [],
        category: map['category']?.toString() ?? 'Woman',
      );
    }
  }
} 