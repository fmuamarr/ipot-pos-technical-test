import '../../domain/entities/order_entity.dart';

class OrderResponseModel {
  final String id;
  final String tableId;
  final String status;
  final String? estimatedTime;
  final DateTime? createdAt;

  const OrderResponseModel({
    required this.id,
    required this.tableId,
    required this.status,
    this.estimatedTime,
    this.createdAt,
  });

  factory OrderResponseModel.fromJson(Map<String, dynamic> json) {
    return OrderResponseModel(
      id: json['id']?.toString() ?? '',
      tableId: json['table_id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'unknown',
      estimatedTime: json['estimated_time']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  OrderEntity toEntity() => OrderEntity(
    id: id,
    tableId: tableId,
    status: OrderStatusExtension.fromString(status),
    estimatedTime: estimatedTime,
    createdAt: createdAt,
  );
}
