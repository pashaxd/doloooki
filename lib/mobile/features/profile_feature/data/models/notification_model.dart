
class NotificationModel {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String type;

  NotificationModel({required this.id, required this.title, required this.description, required this.createdAt, required this.type});

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      type: json['type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'type': type,
    };
  }
}