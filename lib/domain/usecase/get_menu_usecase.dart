import '../entities/menu_response.dart';
import '../repositories/menu_repository.dart';

class GetMenuUseCase {
  final MenuRepository _repository;

  GetMenuUseCase(this._repository);

  Future<MenuResponse> call(String tableId) => _repository.getMenu(tableId);
}
