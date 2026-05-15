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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        centerTitle: true,
        title: const Text(
          'Order Status',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFD5001E),
                  ),
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
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFD5001E)),
          );
        }
        return _buildContent(order);
      }),
    );
  }

  Widget _buildContent(OrderEntity order) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            children: [
              _buildOrderInfoCard(order),
              const SizedBox(height: 12),
              _buildProgressCard(),
              const SizedBox(height: 12),
              Obx(() {
                final msg = controller.errorMessage.value;
                if (msg.isEmpty) return const SizedBox.shrink();
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF9C4),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    msg,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF7A6600),
                      fontSize: 13,
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
        Obx(() {
          if (controller.order.value?.status == OrderStatus.served) {
            return _buildDoneButton();
          }
          return const SizedBox.shrink();
        }),
      ],
    );
  }

  Widget _buildOrderInfoCard(OrderEntity order) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _infoRow('Order ID', order.id),
          const SizedBox(height: 10),
          _infoRow('Table', 'Table-${order.tableId}'),
          if (order.estimatedTime != null) ...[
            const SizedBox(height: 10),
            _infoRow('Est. time', order.estimatedTime!),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
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

  Widget _buildProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Progress',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color(0xFF121212),
            ),
          ),
          const SizedBox(height: 20),
          Obx(() => _buildStepper()),
        ],
      ),
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
                    height: 44,
                    color: isDone
                        ? const Color(0xFF099C54)
                        : Colors.grey.shade200,
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status.displayName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isCurrent
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrent
                            ? const Color(0xFFD5001E)
                            : isDone
                            ? const Color(0xFF121212)
                            : Colors.grey,
                      ),
                    ),
                    if (isCurrent)
                      const Text(
                        'Current status',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildDoneButton() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: SizedBox(
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
              'Start New Order',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusDot extends StatefulWidget {
  final bool isDone;
  final bool isCurrent;

  const _StatusDot({required this.isDone, required this.isCurrent});

  @override
  State<_StatusDot> createState() => _StatusDotState();
}

class _StatusDotState extends State<_StatusDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.35), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.35, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));

    if (widget.isCurrent) _pulse.repeat();
  }

  @override
  void didUpdateWidget(_StatusDot old) {
    super.didUpdateWidget(old);
    if (widget.isCurrent && !_pulse.isAnimating) {
      _pulse.repeat();
    } else if (!widget.isCurrent && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isDone) {
      return Container(
        width: 26,
        height: 26,
        decoration: const BoxDecoration(
          color: Color(0xFF099C54),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 15),
      );
    }
    if (widget.isCurrent) {
      return AnimatedBuilder(
        animation: _scale,
        builder: (_, child) =>
            Transform.scale(scale: _scale.value, child: child),
        child: Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            color: const Color(0xFFD5001E),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD5001E).withOpacity(0.45),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: const Icon(
            Icons.radio_button_checked,
            color: Colors.white,
            size: 15,
          ),
        ),
      );
    }
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300, width: 2),
      ),
    );
  }
}
