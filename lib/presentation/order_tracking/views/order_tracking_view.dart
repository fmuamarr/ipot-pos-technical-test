import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/infrastructure/routes/app_pages.dart';
import '../../../domain/entities/order_entity.dart';
import '../controllers/order_tracking_controller.dart';

class OrderTrackingView extends GetView<OrderTrackingController> {
  const OrderTrackingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F4F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        title: const Text(
          'Order Status',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final order = controller.order.value;
        if (order == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return _buildContent(context, order);
      }),
    );
  }

  Widget _buildContent(BuildContext context, OrderEntity order) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Order ID card
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Order ID',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  order.id,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Table',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  order.tableId,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                if (order.estimatedTime != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Color(0xFFFF6B35),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Est. ${order.estimatedTime}',
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Status stepper
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Progress',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 20),
                Obx(() => _buildStepper()),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Error message
        Obx(() {
          if (controller.errorMessage.value.isNotEmpty) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.orange, fontSize: 13),
              ),
            );
          }
          return const SizedBox.shrink();
        }),

        // Served state: go home button
        Obx(() {
          if (controller.order.value?.status == OrderStatus.served) {
            return ElevatedButton(
              onPressed: () => Get.offAllNamed(Routes.HOME),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF6B35),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Start New Order',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildStepper() {
    final stepIndex = controller.currentStepIndex;
    final statuses = controller.statusFlow;

    return Column(
      children: statuses.asMap().entries.map((entry) {
        final idx = entry.key;
        final status = entry.value;
        final isDone = idx < stepIndex;
        final isCurrent = idx == stepIndex;
        final isLast = idx == statuses.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _StatusDot(isDone: isDone, isCurrent: isCurrent),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isDone
                        ? const Color(0xFF4CAF50)
                        : Colors.grey.shade300,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrent
                            ? const Color(0xFFFF6B35)
                            : isDone
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                    if (isCurrent)
                      const Text(
                        'Current status',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _StatusDot extends StatelessWidget {
  final bool isDone;
  final bool isCurrent;

  const _StatusDot({required this.isDone, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    if (isDone) {
      return Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFF4CAF50),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 14),
      );
    }
    if (isCurrent) {
      return Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFFF6B35),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6B35).withOpacity(0.4),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.radio_button_checked,
          color: Colors.white,
          size: 14,
        ),
      );
    }
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
    );
  }
}
