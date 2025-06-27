import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';

class ColorsModel {
  final String id;
  final String name;
  final String description;
  final List<String> colors;
  final List<String> combinations;
  
  ColorsModel({
    required this.id,
    required this.name, 
    required this.description, 
    required this.colors,
    required this.combinations,
  });

  factory ColorsModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    try {
      print('🔍 Parsing ColorsModel from map: ${map.keys}');
      
      // Безопасное извлечение colors
      List<String> colorsList = [];
      final colorsData = map['colors'];
      
      print('🎨 Colors data type: ${colorsData.runtimeType}');
      print('🎨 Colors data: $colorsData');
      
      if (colorsData != null) {
        if (colorsData is List) {
          // Если colors это список
          for (var item in colorsData) {
            try {
              colorsList.add(item.toString());
            } catch (e) {
              print('❌ Error parsing color item: $e');
              continue;
            }
          }
        } else if (colorsData is Map) {
          // Если colors это Map
          print('🎨 Colors is a Map, converting to list...');
          colorsData.forEach((key, value) {
            try {
              colorsList.add(value.toString());
            } catch (e) {
              print('❌ Error parsing color item $key: $e');
            }
          });
        } else {
          print('⚠️ Unexpected colors data type: ${colorsData.runtimeType}');
        }
      }
      
      // Безопасное извлечение combinations
      List<String> combinationsList = [];
      final combinationsData = map['combinations'];
      
      print('🔗 Combinations data type: ${combinationsData.runtimeType}');
      print('🔗 Combinations data: $combinationsData');
      
      if (combinationsData != null) {
        if (combinationsData is List) {
          // Если combinations это список
          for (var item in combinationsData) {
            try {
              combinationsList.add(item.toString());
            } catch (e) {
              print('❌ Error parsing combination item: $e');
              continue;
            }
          }
        } else if (combinationsData is Map) {
          // Если combinations это Map
          print('🔗 Combinations is a Map, converting to list...');
          combinationsData.forEach((key, value) {
            try {
              combinationsList.add(value.toString());
            } catch (e) {
              print('❌ Error parsing combination item $key: $e');
            }
          });
        } else {
          print('⚠️ Unexpected combinations data type: ${combinationsData.runtimeType}');
        }
      }
      
      final result = ColorsModel(
        id: documentId ?? map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        colors: colorsList,
        combinations: combinationsList,
      );
      
      print('✅ Successfully parsed ColorsModel: ${result.name} with ${result.colors.length} colors');
      return result;
    } catch (e) {
      print('❌ Error in ColorsModel.fromMap: $e');
      print('📋 Map data: $map');
      
      // Возвращаем пустую модель в случае ошибки
      return ColorsModel(
        id: documentId ?? '',
        name: map['name']?.toString() ?? 'Unknown',
        description: map['description']?.toString() ?? '',
        colors: [],
        combinations: [],
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'colors': colors.map((color) => color).toList(),
      'combinations': combinations.map((combination) => combination).toList(),
    };
  }
}