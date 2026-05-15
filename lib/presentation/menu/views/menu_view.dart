import 'package:flutter/material.dart' hide MenuController;
import 'package:get/get.dart';

import '../../../app/infrastructure/routes/app_pages.dart';
import '../../../domain/entities/customization_group.dart';
import '../../../domain/entities/customization_option.dart';
import '../../../domain/entities/menu_category.dart';
import '../../../domain/entities/menu_item.dart';
import '../../../domain/entities/selected_customization.dart';
import '../../cart/controllers/cart_controller.dart';
import '../controllers/menu_controller.dart';

class MenuView extends GetView<MenuController> {
  const MenuView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(
        () => switch (controller.loadState.value) {
          MenuLoadState.loading => const Center(
            child: CircularProgressIndicator(),
          ),
          MenuLoadState.error => _buildError(),
          MenuLoadState.success || MenuLoadState.idle => _buildSuccess(context),
        },
      ),
      bottomNavigationBar: _buildCartBar(),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    final categories = controller.menuResponse.value?.categories ?? [];
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
        _buildCategoryChips(categories),
        Expanded(child: _buildItemList(context, categories)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: const Color(0xFFD5001E),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 16, 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
                onPressed: () => Get.back(),
              ),
              Expanded(
                child: Obx(
                  () => Text(
                    controller.restaurantName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Obx(
                () => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Table-${controller.cart.tableId.value}',
                    style: const TextStyle(
                      color: Color(0xFFD5001E),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: TextField(
        onChanged: controller.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search menu...',
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
          suffixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF5F5F5),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 0,
            horizontal: 16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips(List<MenuCategory> categories) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.only(bottom: 10),
      child: SizedBox(
        height: 36,
        child: Obx(() {
          final selectedIndex = controller.selectedCategoryIndex.value;
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: categories.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final isSelected = selectedIndex == index;
              final label = index == 0
                  ? 'All Menu'
                  : categories[index - 1].name;
              return _CategoryChip(
                label: label,
                isSelected: isSelected,
                onTap: () => controller.selectCategory(index),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildItemList(BuildContext context, List<MenuCategory> categories) {
    return Obx(() {
      final items = controller.filteredItems;
      if (items.isEmpty) {
        return const Center(
          child: Text('Tidak ada menu', style: TextStyle(color: Colors.grey)),
        );
      }

      final sections = _buildSections(items, categories);

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: sections.length,
        itemBuilder: (context, index) {
          final section = sections[index];
          if (section is String) {
            return _buildSectionHeader(section);
          }
          return _MenuItemCard(
            item: section as MenuItem,
            cart: controller.cart,
          );
        },
      );
    });
  }

  List<Object> _buildSections(
    List<MenuItem> items,
    List<MenuCategory> categories,
  ) {
    final result = <Object>[];
    int? lastCategoryId;
    for (final item in items) {
      if (item.categoryId != lastCategoryId) {
        lastCategoryId = item.categoryId;
        final cat = categories
            .where((c) => c.id == item.categoryId)
            .firstOrNull;
        if (cat != null) result.add(cat.name);
      }
      result.add(item);
    }
    return result;
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF121212),
        ),
      ),
    );
  }

  Widget _buildCartBar() {
    return Obx(() {
      final count = controller.cart.totalItemCount;
      if (count == 0) return const SizedBox.shrink();
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: GestureDetector(
            onTap: () => Get.toNamed(Routes.CART),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFD5001E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  Text(
                    '$count Item',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    controller.cart.formatPrice(controller.cart.subtotal),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(
                    Icons.shopping_cart,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
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
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFD5001E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF121212),
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
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showItemDetail(context),
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
                      item.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF121212),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.description,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          cart.formatPrice(item.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF121212),
                          ),
                        ),
                        _TambahButton(
                          onTap: item.customizationGroups.isEmpty
                              ? () {
                                  cart.addItem(item);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('${item.name} ditambahkan'),
                                      duration: const Duration(seconds: 1),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              : () => _showItemDetail(context),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: item.imageUrl != null
                    ? Image.network(
                        item.imageUrl!,
                        width: 90,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imagePlaceholder(),
                      )
                    : _imagePlaceholder(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 90,
      height: 90,
      color: const Color(0xFFF5F5F5),
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

class _TambahButton extends StatelessWidget {
  final VoidCallback onTap;

  const _TambahButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFD5001E),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Add',
          style: TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

// ─── Item Detail Bottom Sheet ────────────────────────────────────────────────

class _ItemDetailSheet extends StatefulWidget {
  final MenuItem item;
  final CartController cart;

  const _ItemDetailSheet({required this.item, required this.cart});

  @override
  State<_ItemDetailSheet> createState() => _ItemDetailSheetState();
}

class _ItemDetailSheetState extends State<_ItemDetailSheet> {
  int _quantity = 1;
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

                        child: widget.item.imageUrl != null
                            ? Image.network(
                                widget.item.imageUrl!,
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
                          widget.item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF121212),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.item.description,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          widget.cart.formatPrice(widget.item.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF121212),
                          ),
                        ),
                        if (widget.item.customizationGroups.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          ...widget.item.customizationGroups.map(
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
                            _QuantityButton(
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
                            _QuantityButton(
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
                      backgroundColor: const Color(0xFFD5001E),
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
          color: const Color(0xFFD5001E),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}
