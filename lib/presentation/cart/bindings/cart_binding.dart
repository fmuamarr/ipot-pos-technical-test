import 'package:get/get.dart';

import '../../../domain/usecase/submit_order_usecase.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../cart/controllers/cart_view_controller.dart';

class CartBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CartViewController>(
      () => CartViewController(
        Get.find<SubmitOrderUseCase>(),
        Get.find<CartController>(),
      ),
    );
  }
}
