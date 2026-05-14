import 'dart:async';

import 'package:get/get.dart';

import '../../../domain/entities/order_entity.dart';
import '../../../domain/usecase/get_order_status_usecase.dart';

class OrderTrackingController extends GetxController {
  final GetOrderStatusUseCase _getOrderStatusUseCase;

  OrderTrackingController(this._getOrderStatusUseCase);

  final Rx<OrderEntity?> order = Rx<OrderEntity?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Timer? _pollingTimer;

  static const _pollInterval = Duration(seconds: 10);

  final List<OrderStatus> _statusFlow = const [
    OrderStatus.pending,
    OrderStatus.confirmed,
    OrderStatus.preparing,
    OrderStatus.ready,
    OrderStatus.served,
  ];

  @override
  void onInit() {
    super.onInit();
    final initialOrder = Get.arguments as OrderEntity?;
    if (initialOrder != null) {
      order.value = initialOrder;
      _startPolling(initialOrder.id);
    }
  }

  @override
  void onClose() {
    _pollingTimer?.cancel();
    super.onClose();
  }

  void _startPolling(String orderId) {
    _pollingTimer = Timer.periodic(_pollInterval, (_) => _fetchStatus(orderId));
  }

  Future<void> _fetchStatus(String orderId) async {
    if (order.value?.status == OrderStatus.served) {
      _pollingTimer?.cancel();
      return;
    }
    try {
      isLoading.value = true;
      final updated = await _getOrderStatusUseCase(orderId);
      order.value = updated;
      errorMessage.value = '';
    } catch (_) {
      errorMessage.value = 'Could not refresh status.';
    } finally {
      isLoading.value = false;
    }
  }

  int get currentStepIndex {
    final current = order.value?.status ?? OrderStatus.pending;
    final idx = _statusFlow.indexOf(current);
    return idx < 0 ? 0 : idx;
  }

  List<OrderStatus> get statusFlow => _statusFlow;
}
