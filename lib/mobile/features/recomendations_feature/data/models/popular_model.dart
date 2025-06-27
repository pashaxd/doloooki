import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';

class PopularModel {
  final String id;
  final String name;
  final String description;
  final List<PatternItem> patterns;
  
  PopularModel({
    required this.id,
    required this.name, 
    required this.description, 
    required this.patterns,
  });

  factory PopularModel.fromMap(Map<String, dynamic> map, {String? documentId}) {
    try {
      print('🔍 Parsing PopularModel from map: ${map.keys}');
      
      // Безопасное извлечение patterns
      List<PatternItem> patternsList = [];
      final patternsData = map['patterns'];
      
      print('📋 Patterns data type: ${patternsData.runtimeType}');
      print('📋 Patterns data: $patternsData');
      
      if (patternsData != null) {
        if (patternsData is List) {
          // Если patterns это список
          for (var item in patternsData) {
            try {
              if (item is Map<String, dynamic>) {
                patternsList.add(PatternItem.fromMap(item));
              } else {
                print('⚠️ Pattern item is not a Map: ${item.runtimeType}');
              }
            } catch (e) {
              print('❌ Error parsing pattern item: $e');
              continue;
            }
          }
        } else if (patternsData is Map) {
          // Если patterns это Map (возможно, с ключами как индексы)
          print('📋 Patterns is a Map, converting to list...');
          patternsData.forEach((key, value) {
            try {
              if (value is Map<String, dynamic>) {
                patternsList.add(PatternItem.fromMap(value));
              }
            } catch (e) {
              print('❌ Error parsing pattern item $key: $e');
            }
          });
        } else {
          print('⚠️ Unexpected patterns data type: ${patternsData.runtimeType}');
        }
      }
      
      final result = PopularModel(
        id: documentId ?? map['id']?.toString() ?? '',
        name: map['name']?.toString() ?? '',
        description: map['description']?.toString() ?? '',
        patterns: patternsList,
      );
      
      print('✅ Successfully parsed PopularModel: ${result.name} with ${result.patterns.length} patterns');
      return result;
    } catch (e) {
      print('❌ Error in PopularModel.fromMap: $e');
      print('📋 Map data: $map');
      
      // Возвращаем пустую модель в случае ошибки
      return PopularModel(
        id: documentId ?? '',
        name: map['name']?.toString() ?? 'Unknown',
        description: map['description']?.toString() ?? '',
        patterns: [],
      );
    }
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'patterns': patterns.map((pattern) => pattern.toMap()).toList(),
    };
  }
}