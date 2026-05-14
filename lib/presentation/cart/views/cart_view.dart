import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/cart_item.dart';
import '../controllers/cart_controller.dart';
import '../controllers/cart_view_controller.dart';

class CartView extends GetView<CartViewController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: Obx(
          () => Text(
            'Cart (${controller.cart.totalItemCount} items)',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          Obx(() {
            if (controller.cart.isEmpty) return const SizedBox.shrink();
            return TextButton(
              onPressed: () {
                Get.dialog(
                  AlertDialog(
                    title: const Text('Clear Cart'),
                    content: const Text('Remove all items from cart?'),
                    actions: [
                      TextButton(
                        onPressed: Get.back,
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.cart.clearCart();
                          Get.back();
                        },
                        child: const Text(
                          'Clear',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );
              },
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.cart.isEmpty) {
          return _buildEmptyCart();
        }
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                children: [
                  // Cart items
                  ...controller.cart.items.map(
                    (item) => _CartItemTile(item: item, cart: controller.cart),
                  ),
                  const SizedBox(height: 16),

                  // Customer note
                  _buildNoteField(),
                  const SizedBox(height: 16),

                  // Order summary
                  _buildOrderSummary(),
                ],
              ),
            ),

            // Submit button
            _buildSubmitButton(context),
          ],
        );
      }),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your cart is empty',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: Get.back,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
            ),
            child: const Text(
              'Browse Menu',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoteField() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Special Instructions',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 8),
            TextField(
              onChanged: controller.updateNote,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. No MSG please, extra napkins…',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order Summary',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            ...controller.cart.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${item.quantity}× ${item.menuItem.name}',
                        style: const TextStyle(fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      controller.cart.formatPrice(item.totalPrice),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Obx(
                  () => Text(
                    controller.cart.formatPrice(controller.cart.subtotal),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              if (controller.submitState.value == OrderSubmitState.error) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
            SizedBox(
              width: double.infinity,
              child: Obx(() {
                final isLoading =
                    controller.submitState.value == OrderSubmitState.loading;
                return ElevatedButton(
                  onPressed: isLoading ? null : controller.submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF6B35),
                    disabledBackgroundColor: Colors.grey.shade300,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Place Order',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  final CartItem item;
  final CartController cart;

  const _CartItemTile({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.menuItem.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  if (item.customizations.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    ...item.customizations.map(
                      (c) => Text(
                        '+ ${c.option.name}',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    cart.formatPrice(item.totalPrice),
                    style: const TextStyle(
                      color: Color(0xFFFF6B35),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            _QuantityControl(item: item, cart: cart),
          ],
        ),
      ),
    );
  }
}

class _QuantityControl extends StatelessWidget {
  final CartItem item;
  final CartController cart;

  const _QuantityControl({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _SmallButton(
          icon: item.quantity == 1 ? Icons.delete_outline : Icons.remove,
          color: item.quantity == 1
              ? Colors.red.shade100
              : Colors.grey.shade200,
          iconColor: item.quantity == 1 ? Colors.red : Colors.black87,
          onTap: () => cart.decrementItem(item.cartItemId),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            '${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        _SmallButton(
          icon: Icons.add,
          color: const Color(0xFFFF6B35).withOpacity(0.15),
          iconColor: const Color(0xFFFF6B35),
          onTap: () => cart.incrementItem(item.cartItemId),
        ),
      ],
    );
  }
}

class _SmallButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _SmallButton({
    required this.icon,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        child: Icon(icon, size: 18, color: iconColor),
      ),
    );
  }
}
