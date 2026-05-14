import 'package:get/get.dart';

import '../../../domain/usecase/get_order_status_usecase.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OrderTrackingController>(
      () => OrderTrackingController(Get.find<GetOrderStatusUseCase>()),
    );
  }
}
