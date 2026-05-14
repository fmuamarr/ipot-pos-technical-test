import '../entities/menu_response.dart';

abstract class MenuRepository {
  Future<MenuResponse> getMenu(String tableId);
}
