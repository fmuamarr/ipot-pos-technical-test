import 'package:get/get.dart';

import '../../../domain/usecase/submit_order_usecase.dart';
import '../../cart/controllers/cart_controller.dart';

enum OrderSubmitState { idle, loading, success, error }

class CartViewController extends GetxController {
  final SubmitOrderUseCase _submitOrderUseCase;
  final CartController cart;

  CartViewController(this._submitOrderUseCase, this.cart);

  final Rx<OrderSubmitState> submitState = OrderSubmitState.idle.obs;
  final RxString customerNote = ''.obs;
  final RxString errorMessage = ''.obs;

  Future<void> submitOrder() async {
    if (cart.isEmpty) return;

    submitState.value = OrderSubmitState.loading;
    try {
      final order = await _submitOrderUseCase(
        tableId: cart.tableId.value,
        items: cart.items.toList(),
        customerNote: customerNote.value.trim().isEmpty
            ? null
            : customerNote.value.trim(),
      );
      final itemSnapshot = cart.items
          .map(
            (i) => {
              'name': i.menuItem.name,
              'qty': i.quantity,
              'price': i.totalPrice,
            },
          )
          .toList();
      final subtotal = cart.subtotal;
      cart.clearCart();
      submitState.value = OrderSubmitState.success;
      Get.offNamed(
        '/order-confirmation',
        arguments: {'order': order, 'items': itemSnapshot, 'total': subtotal},
      );
    } catch (e) {
      errorMessage.value = 'Failed to submit order. Please try again.';
      submitState.value = OrderSubmitState.error;
    }
  }

  void updateNote(String value) => customerNote.value = value;
}
