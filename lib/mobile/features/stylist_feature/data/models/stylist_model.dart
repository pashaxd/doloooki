import 'package:doloooki/mobile/features/stylist_feature/data/models/review_model.dart';

class StylistModel {
  final String id;
  final String name;
  final String profileImage;
  final String shortDescription;
  final String description;
  List<ReviewModel> reviews;
  final int consultationsCount;
  

  StylistModel({
    required this.id,
    required this.name,
    required this.profileImage,
    required this.shortDescription,
    required this.description,
    required this.reviews,
    required this.consultationsCount,
  });
}