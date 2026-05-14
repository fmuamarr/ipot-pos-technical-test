import 'package:get/get.dart';

import '../../../data/datasource/menu_remote_datasource.dart';
import '../../../data/datasource/order_remote_datasource.dart';
import '../../../data/repository/menu_repository_impl.dart';
import '../../../data/repository/order_repository_impl.dart';
import '../../../domain/repositories/menu_repository.dart';
import '../../../domain/repositories/order_repository.dart';
import '../../../domain/usecase/get_menu_usecase.dart';
import '../../../domain/usecase/get_order_status_usecase.dart';
import '../../../domain/usecase/submit_order_usecase.dart';
import '../../../presentation/cart/controllers/cart_controller.dart';

/// register all app-wide dependencies, called once
class AppBinding extends Bindings {
  @override
  void dependencies() {
    // datasources
    Get.lazyPut<MenuRemoteDataSource>(
      () => MenuRemoteDataSourceImpl(),
      fenix: true,
    );
    Get.lazyPut<OrderRemoteDataSource>(
      () => OrderRemoteDataSourceImpl(),
      fenix: true,
    );

    // repositories
    Get.lazyPut<MenuRepository>(
      () => MenuRepositoryImpl(Get.find()),
      fenix: true,
    );
    Get.lazyPut<OrderRepository>(
      () => OrderRepositoryImpl(Get.find()),
      fenix: true,
    );

    // use cases
    Get.lazyPut(() => GetMenuUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => SubmitOrderUseCase(Get.find()), fenix: true);
    Get.lazyPut(() => GetOrderStatusUseCase(Get.find()), fenix: true);

    // global cart controller — permanent
    Get.put(CartController(), permanent: true);
  }
}
