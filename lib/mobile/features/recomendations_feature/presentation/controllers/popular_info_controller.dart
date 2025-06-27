import 'package:get/get.dart';
import 'package:doloooki/mobile/features/patterns_feature/models/pattern_item.dart';

class PopularInfoController extends GetxController {
  final RxList<PatternItem> allPatterns = <PatternItem>[].obs;
  final RxList<PatternItem> filteredPatterns = <PatternItem>[].obs;
  final RxString selectedCategory = 'Все'.obs;
  final RxBool isLoading = false.obs;

  // Список категорий
  final List<String> categories = ['Все', 'Woman', 'Man', 'Kids', 'Casual', 'Formal'];

  @override
  void onInit() {
    super.onInit();
    // Слушаем изменения выбранной категории
    ever(selectedCategory, (_) => filterPatterns());
  }

  void setPatterns(List<PatternItem> patterns) {
    allPatterns.value = patterns;
    filterPatterns();
  }

  void selectCategory(String category) {
    selectedCategory.value = category;
    update(); // Обновляем UI через GetBuilder
  }

  void filterPatterns() {
    print('Filtering by category: ${selectedCategory.value}');
    print('All patterns count: ${allPatterns.length}');
    
    if (selectedCategory.value == 'Все') {
      filteredPatterns.value = allPatterns;
    } else {
      // Фильтруем по категории
      filteredPatterns.value = allPatterns.where((pattern) {
        print('Pattern: ${pattern.name}, Category: ${pattern.category}');
        return pattern.category == selectedCategory.value;
      }).toList();
    }
    
    print('Filtered patterns count: ${filteredPatterns.length}');
    update(); // Обновляем UI через GetBuilder
  }
} 