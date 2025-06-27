import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/stylist_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/review_model.dart';

class StylistService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<StylistModel>> getAllStylists() async {
    try {
      print('🔍 Fetching stylists from Firebase...');
      final QuerySnapshot snapshot = await _firestore.collection('stylists').get();
      
      print('📊 Found ${snapshot.docs.length} documents in stylists collection');
      
      List<StylistModel> stylists = [];
      
      for (var doc in snapshot.docs) {
        print('📄 Processing document: ${doc.id}');
        final data = doc.data() as Map<String, dynamic>;
        print('📋 Document data: $data');
        
        // Получаем отзывы для стилиста из подколлекции
        List<ReviewModel> reviews = [];
        final reviewsSnapshot = await _firestore
            .collection('stylists')
            .doc(doc.id)
            .collection('reviews')
            .get();
            
        print('⭐ Found ${reviewsSnapshot.docs.length} reviews');
        
        for (var reviewDoc in reviewsSnapshot.docs) {
          final reviewData = reviewDoc.data();
          // Обрабатываем Timestamp для createdAt
          String createdAtString = '';
          if (reviewData['createdAt'] != null) {
            if (reviewData['createdAt'] is Timestamp) {
              final timestamp = reviewData['createdAt'] as Timestamp;
              createdAtString = timestamp.toDate().toString();
            } else {
              createdAtString = reviewData['createdAt'].toString();
            }
          }
          
          reviews.add(ReviewModel(
            id: reviewDoc.id,
            name: reviewData['name'] ?? '',
            comment: reviewData['comment'] ?? '',
            rating: reviewData['rating'] ?? 0,
            createdAt: createdAtString,
          ));
        }
        
        final stylist = StylistModel(
          id: doc.id,
          name: data['name'] ?? '',
          image: data['image'] ?? '',
          shortDescription: data['shortDescription'] ?? '',
          description: data['description'] ?? '',
          reviews: reviews,
          consultationsCount: data['consultationsCount'] ?? data['consultionsCount'] ?? 0,
        );
        
        print('✅ Created stylist: ${stylist.name} (${stylist.shortDescription})');
        stylists.add(stylist);
      }
      
      print('🎉 Successfully loaded ${stylists.length} stylists');
      return stylists;
    } catch (e) {
      print('❌ Error fetching stylists: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  Future<StylistModel?> getStylistById(String stylistId) async {
    try {
      final DocumentSnapshot doc = await _firestore.collection('stylists').doc(stylistId).get();
      
      if (!doc.exists) return null;
      
      final data = doc.data() as Map<String, dynamic>;
      
      // Получаем отзывы для стилиста из подколлекции
      List<ReviewModel> reviews = [];
      final reviewsSnapshot = await _firestore
          .collection('stylists')
          .doc(stylistId)
          .collection('reviews')
          .get();
          
      print('⭐ Found ${reviewsSnapshot.docs.length} reviews');
      
      for (var reviewDoc in reviewsSnapshot.docs) {
        final reviewData = reviewDoc.data();
        // Обрабатываем Timestamp для createdAt
        String createdAtString = '';
        if (reviewData['createdAt'] != null) {
          if (reviewData['createdAt'] is Timestamp) {
            final timestamp = reviewData['createdAt'] as Timestamp;
            createdAtString = timestamp.toDate().toString();
          } else {
            createdAtString = reviewData['createdAt'].toString();
          }
        }
        
        reviews.add(ReviewModel(
          id: reviewDoc.id,
          name: reviewData['name'] ?? '',
          comment: reviewData['comment'] ?? '',
          rating: reviewData['rating'] ?? 0,
          createdAt: createdAtString,
        ));
      }
      
      return StylistModel(
        id: doc.id,
        name: data['name'] ?? '',
        image: data['image'] ?? '',
        shortDescription: data['shortDescription'] ?? '',
        description: data['description'] ?? '',
        reviews: reviews,
        consultationsCount: data['consultationsCount'] ?? data['consultionsCount'] ?? 0,
      );
    } catch (e) {
      print('Error fetching stylist: $e');
      return null;
    }
  }

  double calculateAverageRating(List<ReviewModel> reviews) {
    if (reviews.isEmpty) return 0.0;
    
    int totalRating = reviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / reviews.length;
  }
} 