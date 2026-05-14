enum OrderStatus { pending, confirmed, preparing, ready, served, unknown }

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready';
      case OrderStatus.served:
        return 'Served';
      case OrderStatus.unknown:
        return 'Unknown';
    }
  }

  static OrderStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'served':
        return OrderStatus.served;
      default:
        return OrderStatus.unknown;
    }
  }
}

class OrderEntity {
  final String id;
  final String tableId;
  final OrderStatus status;
  final String? estimatedTime;
  final DateTime? createdAt;

  const OrderEntity({
    required this.id,
    required this.tableId,
    required this.status,
    this.estimatedTime,
    this.createdAt,
  });
}
