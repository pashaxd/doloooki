import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/recomendations_feature/data/models/popular_model.dart';

class RecomendationsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<PopularModel>> getPopularModels() async {
    try {
      // Загружаем все документы из коллекции recPatterns
      final querySnapshot = await _firestore
          .collection('recPatterns')
          .get();

      if (querySnapshot.docs.isEmpty) {
        print('No pattern documents found in recPatterns');
        return [];
      }

      List<PopularModel> popularModels = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          if (data != null) {
            final popularModel = PopularModel.fromMap(data, documentId: doc.id);
            popularModels.add(popularModel);
          }
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          continue;
        }
      }

      print('✅ Loaded ${popularModels.length} pattern recommendations from recPatterns');
      return popularModels;
    } catch (e) {
      print('Error fetching popular models: $e');
      return [];
    }
  }

  Stream<List<PopularModel>> getPopularModelsStream() {
    return _firestore
        .collection('recPatterns')
        .snapshots()
        .map((querySnapshot) {
      if (querySnapshot.docs.isEmpty) {
        return <PopularModel>[];
      }

      List<PopularModel> popularModels = [];
      
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          if (data != null) {
            final popularModel = PopularModel.fromMap(data, documentId: doc.id);
            popularModels.add(popularModel);
          }
        } catch (e) {
          print('Error parsing document ${doc.id}: $e');
          continue;
        }
      }

      print('🔄 Stream updated: ${popularModels.length} pattern recommendations from recPatterns');
      return popularModels;
    });
  }
} 