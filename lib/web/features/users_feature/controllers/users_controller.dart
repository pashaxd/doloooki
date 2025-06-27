import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:doloooki/web/features/users_feature/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:get/get.dart';

class UsersController extends GetxController {
  RxList<UserModel> allUsers = <UserModel>[].obs;
  RxList<UserModel> filteredUsers = <UserModel>[].obs;
  RxInt selectedFilter = 0.obs; // 0 - Все, 1 - Активна, 2 - Отключена
  RxInt currentPage = 1.obs;
  RxBool isLoading = false.obs;
  RxString errorMessage = ''.obs;
  final int usersPerPage = 10;
  final RxInt index = 0.obs;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // ID выбранного пользователя для просмотра информации
  String? selectedUserId;

  @override
  void onInit() {
    super.onInit();
    loadUsers();
  }

  // Метод для выбора пользователя и переключения на экран информации о нем
  void selectUserForInfo(String userId) {
    selectedUserId = userId;
    print('🔍 Выбран пользователь для просмотра: $userId');
    
    // Устанавливаем индекс для показа экрана UserInfo
    index.value = 1;
  }

  // Метод для возврата к списку пользователей
  void goBackToUsersList() {
    index.value = 0;
    selectedUserId = null;
    print('📋 Возврат к списку пользователей');
  }

  Future<void> loadUsers() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      // Проверяем авторизацию
      final user = FirebaseAuth.instance.currentUser;
      print('Current user: ${user?.uid}');
      print('User email: ${user?.email}');
      
      if (user == null) {
        throw Exception('Пользователь не авторизован');
      }
      
      print('Attempting to load users...');
      final QuerySnapshot snapshot = await _firestore.collection('users').get();
      print('Successfully loaded ${snapshot.docs.length} users');
      
      allUsers.value = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final user = UserModel.fromFirestore(doc.id, data);
        
        // Отладочный вывод для проверки данных изображения
        print('User: ${user.fullName}');
        print('Profile image URL: "${user.profileImage}"');
        print('Profile image is empty: ${user.profileImage.isEmpty}');
        print('---');
        
        return user;
      }).toList();
      
      applyFilter();
    } catch (e) {
      errorMessage.value = 'Ошибка загрузки пользователей: $e';
      print('Detailed error loading users: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void setFilter(int filterIndex) {
    selectedFilter.value = filterIndex;
    currentPage.value = 1;
    applyFilter();
  }

  void applyFilter() {
    switch (selectedFilter.value) {
      case 0: // Все
        filteredUsers.value = allUsers;
        break;
      case 1: // Активна - здесь можно добавить логику проверки активной подписки
        filteredUsers.value = allUsers.where((user) => user.hasActiveSubscription).toList();
        break;
      case 2: // Отключена
        filteredUsers.value = allUsers.where((user) => !user.hasActiveSubscription).toList();
        break;
    }
  }

  List<UserModel> getCurrentPageUsers() {
    final startIndex = (currentPage.value - 1) * usersPerPage;
    final endIndex = startIndex + usersPerPage;
    if (startIndex >= filteredUsers.length) return [];
    return filteredUsers.sublist(
      startIndex,
      endIndex > filteredUsers.length ? filteredUsers.length : endIndex,
    );
  }

  int get totalPages => (filteredUsers.length / usersPerPage).ceil();

  void goToPage(int page) {
    if (page >= 1 && page <= totalPages) {
      currentPage.value = page;
    }
  }

  Future<void> refreshUsers() async {
    await loadUsers();
  }
}
