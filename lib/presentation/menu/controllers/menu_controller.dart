import 'package:get/get.dart';

import '../../../domain/entities/menu_item.dart';
import '../../../domain/entities/menu_response.dart';
import '../../../domain/usecase/get_menu_usecase.dart';
import '../../cart/controllers/cart_controller.dart';

enum MenuLoadState { idle, loading, success, error }

class MenuController extends GetxController with GetTickerProviderStateMixin {
  final GetMenuUseCase _getMenuUseCase;
  final CartController cart;

  MenuController(this._getMenuUseCase, this.cart);

  final Rx<MenuLoadState> loadState = MenuLoadState.idle.obs;
  final Rx<MenuResponse?> menuResponse = Rx<MenuResponse?>(null);
  final RxString errorMessage = ''.obs;
  final RxString searchQuery = ''.obs;
  final RxInt selectedCategoryIndex = 0.obs;

  List<MenuItem> get filteredItems {
    final response = menuResponse.value;
    if (response == null) return [];

    final categories = response.categories;
    final categoryId = selectedCategoryIndex.value == 0
        ? null
        : categories[selectedCategoryIndex.value - 1].id;

    return response.items.where((item) {
      final matchesCategory =
          categoryId == null || item.categoryId == categoryId;
      final query = searchQuery.value.trim().toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          item.name.toLowerCase().contains(query) ||
          item.description.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  String get restaurantName => menuResponse.value?.restaurant.name ?? '';

  @override
  void onInit() {
    super.onInit();
    final tableId = Get.arguments as String? ?? 'T001';
    loadMenu(tableId);
  }

  Future<void> loadMenu(String tableId) async {
    loadState.value = MenuLoadState.loading;
    try {
      final result = await _getMenuUseCase(tableId);
      menuResponse.value = result;
      loadState.value = MenuLoadState.success;
    } catch (e) {
      errorMessage.value = 'Failed to load menu. Please try again.';
      loadState.value = MenuLoadState.error;
    }
  }

  void retry() {
    final tableId = Get.arguments as String? ?? 'T001';
    loadMenu(tableId);
  }

  void selectCategory(int index) => selectedCategoryIndex.value = index;
  void onSearchChanged(String value) => searchQuery.value = value;
}
