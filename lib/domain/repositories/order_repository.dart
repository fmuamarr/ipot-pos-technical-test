import '../entities/cart_item.dart';
import '../entities/order_entity.dart';

abstract class OrderRepository {
  Future<OrderEntity> submitOrder({
    required String tableId,
    required List<CartItem> items,
    String? customerNote,
  });

  Future<OrderEntity> getOrderStatus(String orderId);
}
