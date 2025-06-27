import 'package:get/get.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/models/request_model.dart';
import 'package:doloooki/mobile/features/stylist_feature/data/services/request_service.dart';

class StylistController extends GetxController {
  final RequestService _requestService = RequestService();
  final RxList<RequestModel> userRequests = <RequestModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserRequests();
  }

  void loadUserRequests() {
    isLoading.value = true;
    _requestService.getUserRequests().listen((requests) {
      userRequests.value = requests;
      isLoading.value = false;
    });
  }

  String getStatusColor(String status) {
    switch (status) {
      case 'В процессе':
        return 'warning';
      case 'Завершена':
        return 'success';
      case 'Отменена':
        return 'error';
      default:
        return 'warning';
    }
  }

  String formatDate(String dateString) {
    try {
      DateTime date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
    } catch (e) {
      return dateString;
    }
  }
} 