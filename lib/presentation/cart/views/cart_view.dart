import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/entities/cart_item.dart';
import '../../../domain/entities/customization_group.dart';
import '../../../domain/entities/customization_option.dart';
import '../../../domain/entities/selected_customization.dart';
import '../controllers/cart_controller.dart';
import '../controllers/cart_view_controller.dart';

class CartView extends GetView<CartViewController> {
  const CartView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        centerTitle: true,
        title: const Text(
          'Cart',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.cart.isEmpty) return _buildEmptyCart();
        return Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                children: [
                  _buildTableRow(),
                  const SizedBox(height: 10),
                  _buildHintBanner(),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Order Details'),
                  const SizedBox(height: 10),
                  ...controller.cart.items.map(
                    (item) => _CartItemCard(item: item, cart: controller.cart),
                  ),
                  const SizedBox(height: 20),
                  _buildSectionLabel('Notes'),
                  const SizedBox(height: 4),
                  const Text(
                    'Optional',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  _buildNoteField(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            _buildSubmitButton(context),
          ],
        );
      }),
    );
  }

  Widget _buildTableRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Table',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF121212),
            ),
          ),
          Obx(
            () => Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD5001E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Table-${controller.cart.tableId.value}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHintBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9C4),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Make sure the table number above matches where you are sitting.',
        style: TextStyle(color: Color(0xFF7A6600), fontSize: 13),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF121212),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF099C54).withOpacity(0.4)),
      ),
      child: TextField(
        onChanged: controller.updateNote,
        maxLines: 3,
        decoration: const InputDecoration(
          hintText: 'Sweet, salty, or spicy? Let us know…',
          hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
          contentPadding: EdgeInsets.all(14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Obx(() {
          final isLoading =
              controller.submitState.value == OrderSubmitState.loading;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (controller.submitState.value == OrderSubmitState.error)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    controller.errorMessage.value,
                    style: const TextStyle(color: Colors.red, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : controller.submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD5001E),
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
                ),
              ),
            ],
          );
        }),
      ),
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
              backgroundColor: const Color(0xFFD5001E),
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
}

class _CartItemCard extends StatelessWidget {
  final CartItem item;
  final CartController cart;

  const _CartItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
                        color: Color(0xFF121212),
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
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.menuItem.imageUrl != null
                    ? Image.network(
                        item.menuItem.imageUrl!,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Text(
                cart.formatPrice(item.itemUnitPrice),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: Color(0xFF121212),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: () => _showEditSheet(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Edit',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit_outlined,
                        size: 12,
                        color: Colors.grey.shade600,
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              _QuantityControl(item: item, cart: cart),
            ],
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.restaurant, color: Colors.grey, size: 28),
    );
  }

  void _showEditSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditItemSheet(cartItem: item, cart: cart),
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
        GestureDetector(
          onTap: () => cart.decrementItem(item.cartItemId),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD5001E)),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.remove, size: 16, color: Color(0xFFD5001E)),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            '${item.quantity}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
        GestureDetector(
          onTap: () => cart.incrementItem(item.cartItemId),
          child: Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
              color: Color(0xFF099C54),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 16, color: Colors.white),
          ),
        ),
      ],
    );
  }
}

// ─── Edit Item Bottom Sheet ───────────────────────────────────────────────────

class _EditItemSheet extends StatefulWidget {
  final CartItem cartItem;
  final CartController cart;

  const _EditItemSheet({required this.cartItem, required this.cart});

  @override
  State<_EditItemSheet> createState() => _EditItemSheetState();
}

class _EditItemSheetState extends State<_EditItemSheet> {
  late int _quantity;
  final Map<int, Set<int>> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _quantity = widget.cartItem.quantity;
    for (final group in widget.cartItem.menuItem.customizationGroups) {
      _selectedOptions[group.id] = {};
      for (final sc in widget.cartItem.customizations) {
        if (group.options.any((o) => o.id == sc.option.id)) {
          _selectedOptions[group.id]!.add(sc.option.id);
        }
      }
    }
  }

  bool get _canUpdate {
    for (final group in widget.cartItem.menuItem.customizationGroups) {
      if (group.required && (_selectedOptions[group.id]?.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  double get _totalPrice {
    double base = widget.cartItem.menuItem.price;
    for (final group in widget.cartItem.menuItem.customizationGroups) {
      for (final option in group.options) {
        if (_selectedOptions[group.id]?.contains(option.id) ?? false) {
          base += option.priceModifier;
        }
      }
    }
    return base * _quantity;
  }

  void _toggleOption(CustomizationGroup group, CustomizationOption option) {
    setState(() {
      final selected = _selectedOptions[group.id]!;
      if (selected.contains(option.id)) {
        selected.remove(option.id);
      } else {
        if (group.maxSelections == 1) {
          selected.clear();
        } else if (selected.length >= group.maxSelections) {
          return;
        }
        selected.add(option.id);
      }
    });
  }

  List<SelectedCustomization> get _builtCustomizations {
    final result = <SelectedCustomization>[];
    for (final group in widget.cartItem.menuItem.customizationGroups) {
      for (final option in group.options) {
        if (_selectedOptions[group.id]?.contains(option.id) ?? false) {
          result.add(SelectedCustomization(option: option, quantity: 1));
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final menuItem = widget.cartItem.menuItem;
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scroll) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView(
                controller: scroll,
                padding: EdgeInsets.zero,
                children: [
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                        child: menuItem.imageUrl != null
                            ? Image.network(
                                menuItem.imageUrl!,
                                height: 220,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => _imageFallback(),
                              )
                            : _imageFallback(),
                      ),
                      Positioned(
                        top: 10,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          menuItem.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF121212),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          menuItem.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.cart.formatPrice(menuItem.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121212),
                          ),
                        ),
                        if (menuItem.customizationGroups.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          ...menuItem.customizationGroups.map(
                            (group) => _buildGroupSection(group),
                          ),
                        ],
                        const SizedBox(height: 16),
                        const Text(
                          'How many?',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF121212),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _SheetQtyButton(
                              icon: Icons.remove,
                              onTap: () {
                                if (_quantity > 1) setState(() => _quantity--);
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                '$_quantity',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            _SheetQtyButton(
                              icon: Icons.add,
                              onTap: () => setState(() => _quantity++),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canUpdate
                        ? () {
                            widget.cart.updateItem(
                              widget.cartItem.cartItemId,
                              _builtCustomizations,
                              _quantity,
                            );
                            Navigator.pop(context);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD5001E),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      'Update Cart · ${widget.cart.formatPrice(_totalPrice)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      height: 220,
      width: double.infinity,
      color: const Color(0xFFF5F5F5),
      child: const Icon(Icons.restaurant, color: Colors.grey, size: 64),
    );
  }

  Widget _buildGroupSection(CustomizationGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              group.name,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: group.required
                    ? const Color(0xFFD5001E).withOpacity(0.1)
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                group.required ? 'Required' : 'Optional',
                style: TextStyle(
                  fontSize: 11,
                  color: group.required ? const Color(0xFFD5001E) : Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        if (group.maxSelections > 1)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              'Select up to ${group.maxSelections}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 8),
        ...group.options.map((opt) => _buildOptionTile(group, opt)),
        const Divider(height: 24),
      ],
    );
  }

  Widget _buildOptionTile(
    CustomizationGroup group,
    CustomizationOption option,
  ) {
    final isSelected = _selectedOptions[group.id]?.contains(option.id) ?? false;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      leading: group.maxSelections == 1
          ? Radio<int>(
              value: option.id,
              groupValue: _selectedOptions[group.id]?.firstOrNull,
              activeColor: const Color(0xFFD5001E),
              onChanged: (_) => _toggleOption(group, option),
            )
          : Checkbox(
              value: isSelected,
              activeColor: const Color(0xFFD5001E),
              onChanged: (_) => _toggleOption(group, option),
            ),
      title: Text(option.name, style: const TextStyle(fontSize: 14)),
      trailing: option.priceModifier > 0
          ? Text(
              '+${widget.cart.formatPrice(option.priceModifier)}',
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            )
          : null,
    );
  }
}

class _SheetQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _SheetQtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFD5001E),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
