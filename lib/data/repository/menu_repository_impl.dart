import '../../domain/entities/menu_response.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasource/menu_remote_datasource.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuRemoteDataSource _dataSource;

  MenuRepositoryImpl(this._dataSource);

  @override
  Future<MenuResponse> getMenu(String tableId) async {
    final model = await _dataSource.getMenu(tableId);
    return model.toEntity();
  }
}
