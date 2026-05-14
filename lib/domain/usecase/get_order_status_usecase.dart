import '../entities/order_entity.dart';
import '../repositories/order_repository.dart';

class GetOrderStatusUseCase {
  final OrderRepository _repository;

  GetOrderStatusUseCase(this._repository);

  Future<OrderEntity> call(String orderId) =>
      _repository.getOrderStatus(orderId);
}
