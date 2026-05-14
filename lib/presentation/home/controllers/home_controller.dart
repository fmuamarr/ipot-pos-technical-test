import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../app/infrastructure/routes/app_pages.dart';
import '../../cart/controllers/cart_controller.dart';

class HomeController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  final RxBool isProcessing = false.obs;
  final RxString errorMessage = ''.obs;

  static const String _qrScheme = 'ipot://table/';

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }

  void onDetect(BarcodeCapture capture) {
    if (isProcessing.value) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null) continue;

      if (raw.startsWith(_qrScheme)) {
        final tableId = raw.substring(_qrScheme.length).trim();
        if (tableId.isNotEmpty) {
          _navigateToMenu(tableId);
          return;
        }
      }
    }

    errorMessage.value = 'Invalid QR code. Please scan a valid table QR.';
    Future.delayed(const Duration(seconds: 3), () {
      errorMessage.value = '';
    });
  }

  void enterDemoMode() => _navigateToMenu('T001');

  void _navigateToMenu(String tableId) {
    isProcessing.value = true;
    final cart = Get.find<CartController>();
    cart.tableId.value = tableId;
    cart.clearCart();
    Get.toNamed(Routes.MENU, arguments: tableId);
    Future.delayed(const Duration(seconds: 1), () {
      isProcessing.value = false;
    });
  }
}
