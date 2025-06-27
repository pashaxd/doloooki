class ReviewModel {
  final String id;
  final String name;
  final String comment;
  final int rating;
  final String createdAt;

  ReviewModel({
    required this.id,
    required this.name,
    required this.comment,
    required this.rating,
    required this.createdAt,
  });
}