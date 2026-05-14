import 'package:get/get.dart';

import '../../../presentation/cart/bindings/cart_binding.dart';
import '../../../presentation/cart/views/cart_view.dart';
import '../../../presentation/home/bindings/home_binding.dart';
import '../../../presentation/home/views/home_view.dart';
import '../../../presentation/menu/bindings/menu_binding.dart';
import '../../../presentation/menu/views/menu_view.dart';
import '../../../presentation/order_confirmation/views/order_confirmation_view.dart';
import '../../../presentation/order_tracking/bindings/order_tracking_binding.dart';
import '../../../presentation/order_tracking/views/order_tracking_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.MENU,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_CONFIRMATION,
      page: () => const OrderConfirmationView(),
    ),
    GetPage(
      name: _Paths.ORDER_TRACKING,
      page: () => const OrderTrackingView(),
      binding: OrderTrackingBinding(),
    ),
  ];
}
