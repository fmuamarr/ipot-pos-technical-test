import 'package:dio/dio.dart';

import '../../domain/entities/cart_item.dart';
import '../model/order_request_model.dart';
import '../model/order_response_model.dart';
import '../network/api_client.dart';
import 'mock_data.dart';

abstract class OrderRemoteDataSource {
  Future<OrderResponseModel> submitOrder(OrderRequest request);
  Future<OrderResponseModel> getOrderStatus(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio _dio;

  OrderRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  @override
  Future<OrderResponseModel> submitOrder(OrderRequest request) async {
    try {
      final response = await _dio.post(
        '/api/v1/orders',
        data: request.toJson(),
      );
      return OrderResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (_) {
      await Future.delayed(const Duration(milliseconds: 1200));
      return OrderResponseModel.fromJson(
        buildMockOrderResponse(request.tableId),
      );
    }
  }

  @override
  Future<OrderResponseModel> getOrderStatus(String orderId) async {
    try {
      final response = await _dio.get('/api/v1/orders/$orderId');
      return OrderResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (_) {
      await Future.delayed(const Duration(milliseconds: 500));
      return OrderResponseModel.fromJson(buildMockOrderStatus(orderId));
    }
  }
}

OrderRequest buildOrderRequest({
  required String tableId,
  required List<CartItem> items,
  String? customerNote,
}) {
  return OrderRequest(
    tableId: tableId,
    items: items.map(OrderItemRequest.fromCartItem).toList(),
    customerNote: customerNote,
  );
}
