import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../../../app/infrastructure/routes/app_pages.dart';
import '../../../domain/entities/order_entity.dart';

class OrderConfirmationView extends StatelessWidget {
  const OrderConfirmationView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final order = args?['order'] as OrderEntity?;
    final items = (args?['items'] as List?)?.cast<Map<String, dynamic>>() ?? [];
    final total = (args?['total'] as double?) ?? 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                children: [
                  _buildSuccessAnimation(),
                  const SizedBox(height: 8),
                  const Text(
                    'Order Placed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF121212),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Total ${_formatPrice(total)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  if (order != null) ...[
                    _buildOrderIdRow(order.id),
                    const SizedBox(height: 12),
                    _buildDetailsCard(order),
                    const SizedBox(height: 12),
                    _buildItemsCard(items, total),
                  ],
                ],
              ),
            ),
            _buildBottomButtons(order),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccessAnimation() {
    return SizedBox(
      height: 160,
      child: Lottie.asset(
        'assets/animation/success.json',
        repeat: true,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildOrderIdRow(String orderId) {
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
            'Order ID',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: Color(0xFF121212),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFD5001E),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              orderId,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(OrderEntity order) {
    final date = order.createdAt != null
        ? '${order.createdAt!.day.toString().padLeft(2, '0')}/'
              '${order.createdAt!.month.toString().padLeft(2, '0')}/'
              '${order.createdAt!.year}'
        : '-';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _detailRow('Order ID', order.id),
          const SizedBox(height: 10),
          _detailRow('Date', date),
          const SizedBox(height: 10),
          _detailRow('Table', 'Table-${order.tableId}'),
          if (order.estimatedTime != null) ...[
            const SizedBox(height: 10),
            _detailRow('Est. time', order.estimatedTime!),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF121212),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildItemsCard(List<Map<String, dynamic>> items, double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...items.map((item) {
            final name = item['name'] as String? ?? '';
            final qty = item['qty'] as int? ?? 1;
            final price = item['price'] as double? ?? 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${qty}x $name',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF121212),
                      ),
                    ),
                  ),
                  Text(
                    _formatPrice(price),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF121212),
                    ),
                  ),
                ],
              ),
            );
          }),
          _subtotalRow('Discount', '-'),
          _subtotalRow('Other fees', '-'),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Payment',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF121212),
                ),
              ),
              Text(
                _formatPrice(total),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF121212),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _subtotalRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text(value, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(OrderEntity? order) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (order != null) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    Get.toNamed(Routes.ORDER_TRACKING, arguments: order),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFFD5001E),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: const BorderSide(color: Color(0xFFD5001E)),
                  ),
                ),
                child: const Text(
                  'Track Order',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.HOME),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD5001E),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Back to Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double amount) => '\$${amount.toStringAsFixed(2)}';
}
