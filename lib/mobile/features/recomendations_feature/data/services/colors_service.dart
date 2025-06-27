import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/colors_model.dart';

class ColorsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<ColorsModel>> getColorsModels() async {
    try {
      // Загружаем все документы из коллекции recColors
      final querySnapshot = await _firestore
          .collection('recColors')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No color documents found in recColors');
        return [];
      }

      List<ColorsModel> colorsModels = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          if (data != null) {
            final colorsModel = ColorsModel.fromMap(data, documentId: doc.id);
            colorsModels.add(colorsModel);
          }
        } catch (e) {
          print('Error parsing color document ${doc.id}: $e');
          continue;
        }
      }

      print('✅ Loaded ${colorsModels.length} color recommendations from recColors');
      return colorsModels;
    } catch (e) {
      print('Error fetching colors models: $e');
      return [];
    }
  }

  Stream<List<ColorsModel>> getColorsModelsStream() {
    return _firestore
        .collection('recColors')
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        return <ColorsModel>[];
      }

      List<ColorsModel> colorsModels = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          if (data != null) {
            final colorsModel = ColorsModel.fromMap(data, documentId: doc.id);
            colorsModels.add(colorsModel);
          }
        } catch (e) {
          print('Error parsing color document ${doc.id}: $e');
          continue;
        }
      }

      print('🔄 Stream updated: ${colorsModels.length} color recommendations from recColors');
      return colorsModels;
    });
  }
} 