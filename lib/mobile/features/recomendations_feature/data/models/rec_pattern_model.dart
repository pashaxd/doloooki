class RecPatternModel {
  final String imageUrl;
  final String name;
  final String description;
  final String category;
    final List<Map<String, dynamic>> usedItems;
  RecPatternModel(this.usedItems, {required this.imageUrl, required this.name, required this.description, required this.category});
}