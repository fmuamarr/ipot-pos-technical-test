import '../../domain/entities/cart_item.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasource/order_remote_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource _dataSource;

  OrderRepositoryImpl(this._dataSource);

  @override
  Future<OrderEntity> submitOrder({
    required String tableId,
    required List<CartItem> items,
    String? customerNote,
  }) async {
    final request = buildOrderRequest(
      tableId: tableId,
      items: items,
      customerNote: customerNote,
    );
    final model = await _dataSource.submitOrder(request);
    return model.toEntity();
  }

  @override
  Future<OrderEntity> getOrderStatus(String orderId) async {
    final model = await _dataSource.getOrderStatus(orderId);
    return model.toEntity();
  }
}
