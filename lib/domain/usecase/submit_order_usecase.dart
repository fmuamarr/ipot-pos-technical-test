import '../entities/cart_item.dart';
import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class SubmitOrderUseCase {
  final OrderRepository _repository;

  SubmitOrderUseCase(this._repository);

  Future<OrderEntity> call({
    required String tableId,
    required List<CartItem> items,
    String? customerNote,
  }) => _repository.submitOrder(
    tableId: tableId,
    items: items,
    customerNote: customerNote,
  );
}
