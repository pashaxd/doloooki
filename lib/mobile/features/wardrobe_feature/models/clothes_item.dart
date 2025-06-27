class ClothesItem {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> tags; // теги: летняя, повседневная и т.д.
  final String category; // категория: верхняя одежда, юбки, сумки и т.д.

  ClothesItem({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.tags,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'tags': tags,
      'category': category,
    };
  }

  factory ClothesItem.fromMap(Map<String, dynamic> map) {
    return ClothesItem(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tags: List<String>.from(map['tags'] ?? []),
      category: map['category'] ?? '',
    );
  }
}