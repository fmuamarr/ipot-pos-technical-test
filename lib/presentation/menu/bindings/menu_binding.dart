import 'package:get/get.dart';

import '../../../domain/usecase/get_menu_usecase.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/menu_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MenuController>(
      () => MenuController(
        Get.find<GetMenuUseCase>(),
        Get.find<CartController>(),
      ),
    );
  }
}
