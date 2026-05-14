import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../app/infrastructure/routes/app_pages.dart';
import '../../../domain/entities/customization_group.dart';
import '../../../domain/entities/customization_option.dart';
import '../../../domain/entities/menu_item.dart';
import '../../../domain/entities/selected_customization.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/menu_controller.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: _buildAppBar(context),
      body: Obx(
        () => switch (controller.loadState.value) {
          MenuLoadState.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MenuLoadState.error => _buildError(),
          MenuLoadState.success || MenuLoadState.idle => _buildContent(context),
        },
      ),
      floatingActionButton: _buildCartFab(),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.qr_code_scanner, color: Colors.black87),
        tooltip: 'Scan another table',
        onPressed: () => Get.back(),
      ),
      title: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              controller.restaurantName,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(
              () => Text(
                'Table ${controller.cart.tableId.value}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            controller.errorMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: controller.retry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final categories = controller.menuResponse.value?.categories ?? [];

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            onChanged: controller.onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search menu…',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        // Category tabs
        if (categories.isNotEmpty)
          SizedBox(
            height: 44,
            child: Obx(() {
              // Read the observable at the top of the Obx callback so GetX
              // can track it during the synchronous build pass (itemBuilder
              // is lazy and would otherwise be called outside the tracking scope).
              final selectedIndex = controller.selectedCategoryIndex.value;
              return ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isAll = index == 0;
                  final isSelected = selectedIndex == index;
                  final label = isAll ? 'All' : categories[index - 1].name;
                  return _CategoryChip(
                    label: label,
                    isSelected: isSelected,
                    onTap: () => controller.selectCategory(index),
                  );
                },
              );
            }),
          ),

        // Menu items list
        Expanded(
          child: Obx(() {
            final items = controller.filteredItems;
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'No items found',
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
              itemCount: items.length,
              itemBuilder: (context, index) =>
                  _MenuItemCard(item: items[index], cart: controller.cart),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCartFab() {
    return Obx(() {
      final count = controller.cart.totalItemCount;
      if (count == 0) return const SizedBox.shrink();
      return FloatingActionButton.extended(
        onPressed: () => Get.toNamed(Routes.CART),
        backgroundColor: const Color(0xFFFF6B35),
        icon: const Icon(Icons.shopping_cart, color: Colors.white),
        label: Text(
          '$count item${count != 1 ? 's' : ''} · ${controller.cart.formatPrice(controller.cart.subtotal)}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    });
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF6B35) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuItem item;
  final CartController cart;

  const _MenuItemCard({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _showItemDetail(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image placeholder
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cart.formatPrice(item.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF6B35),
                          ),
                        ),
                        if (item.customizationGroups.isEmpty)
                          _QuickAddButton(item: item, cart: cart)
                        else
                          _CustomizeButton(
                            onTap: () => _showItemDetail(context),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: const Color(0xFFF0EDE8),
      child: const Icon(Icons.restaurant, color: Colors.grey, size: 32),
    );
  }

  void _showItemDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemDetailSheet(item: item, cart: cart),
    );
  }
}

class _QuickAddButton extends StatelessWidget {
  final MenuItem item;
  final CartController cart;

  const _QuickAddButton({required this.item, required this.cart});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        cart.addItem(item);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${item.name} added to cart'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text('Add', style: TextStyle(color: Colors.white, fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _CustomizeButton extends StatelessWidget {
  final VoidCallback onTap;

  const _CustomizeButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFFF6B35)),
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: const Text(
          'Customize',
          style: TextStyle(color: Color(0xFFFF6B35), fontSize: 13),
        ),
      ),
    );
  }
}

// ─── Item Detail Bottom Sheet ───────────────────────────────────────────────

class _ItemDetailSheet extends StatefulWidget {
  final MenuItem item;
  final CartController cart;

  const _ItemDetailSheet({required this.item, required this.cart});

  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  int _quantity = 1;
  // groupId → selected option ids
  final Map<int, Set<int>> _selectedOptions = {};

  @override
  void initState() {
    super.initState();
    for (final group in widget.item.customizationGroups) {
      _selectedOptions[group.id] = {};
    }
  }

  bool get _canAddToCart {
    for (final group in widget.item.customizationGroups) {
      if (group.required && (_selectedOptions[group.id]?.isEmpty ?? true)) {
        return false;
      }
    }
    return true;
  }

  double get _totalPrice {
    double base = widget.item.price;
    for (final group in widget.item.customizationGroups) {
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

  List<SelectedCustomization> get _buildCustomizations {
    final result = <SelectedCustomization>[];
    for (final group in widget.item.customizationGroups) {
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
            // Handle
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: scroll,
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                children: [
                  // Item header
                  Text(
                    widget.item.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.item.description,
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.cart.formatPrice(widget.item.price),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF6B35),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Customization groups
                  ...widget.item.customizationGroups.map(
                    (group) => _buildGroupSection(group),
                  ),

                  const SizedBox(height: 16),

                  // Quantity control
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _QuantityButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      _QuantityButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Add to cart button
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _canAddToCart
                        ? () {
                            widget.cart.addItem(
                              widget.item,
                              customizations: _buildCustomizations,
                              quantity: _quantity,
                            );
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${widget.item.name} added to cart',
                                ),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF6B35),
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _canAddToCart
                          ? 'Add to Cart · ${widget.cart.formatPrice(_totalPrice)}'
                          : 'Select required options',
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

  Widget _buildGroupSection(CustomizationGroup group) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              group.name,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            if (group.required)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B35).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Required',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFFF6B35),
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
              'Choose up to ${group.maxSelections}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
        const SizedBox(height: 10),
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
              activeColor: const Color(0xFFFF6B35),
              onChanged: (_) => _toggleOption(group, option),
            )
          : Checkbox(
              value: isSelected,
              activeColor: const Color(0xFFFF6B35),
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

class _QuantityButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QuantityButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
