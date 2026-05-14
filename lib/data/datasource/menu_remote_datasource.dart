import 'package:dio/dio.dart';

import '../model/menu_response_model.dart';
import '../network/api_client.dart';
import 'mock_data.dart';

abstract class MenuRemoteDataSource {
  Future<MenuResponseModel> getMenu(String tableId);
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio _dio;

  MenuRemoteDataSourceImpl({Dio? dio}) : _dio = dio ?? ApiClient.instance.dio;

  @override
  Future<MenuResponseModel> getMenu(String tableId) async {
    try {
      final response = await _dio.get(
        '/api/v1/menu',
        queryParameters: {'table_id': tableId},
      );
      return MenuResponseModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (_) {
      // Fall back to mock data when API is unreachable
      await Future.delayed(const Duration(milliseconds: 800));
      final mockData = Map<String, dynamic>.from(kMockMenuResponse);
      mockData['restaurant'] = {
        ...kMockMenuResponse['restaurant'] as Map<String, dynamic>,
        'table_id': tableId,
      };
      return MenuResponseModel.fromJson(mockData);
    }
  }
}
