import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: controller.scannerController,
            onDetect: controller.onDetect,
          ),

          // Overlay UI
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                const Spacer(),
                _buildScanFrame(),
                const Spacer(),
                _buildBottomSection(context),
              ],
            ),
          ),

          // Processing / error overlay
          Obx(() {
            if (controller.isProcessing.value) {
              return const ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              );
            }
            if (controller.errorMessage.value.isNotEmpty) {
              return Positioned(
                bottom: 180,
                left: 24,
                right: 24,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade800,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    controller.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Column(
        children: [
          const Text(
            'IPOT',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              letterSpacing: 4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scan the table QR code to start ordering',
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanFrame() {
    const frameSize = 260.0;
    return Stack(
      alignment: Alignment.center,
      children: [
        // Dimmed overlay with transparent cutout effect
        Container(
          width: frameSize,
          height: frameSize,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        // Corner accents
        ...[
          Alignment.topLeft,
          Alignment.topRight,
          Alignment.bottomLeft,
          Alignment.bottomRight,
        ].map(
          (alignment) => Align(
            alignment: alignment,
            child: _CornerAccent(alignment: alignment),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          const Text(
            'Point your camera at the table QR code',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: controller.enterDemoMode,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Demo Mode (Table T001)'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerAccent extends StatelessWidget {
  final Alignment alignment;

  const _CornerAccent({required this.alignment});

  @override
  Widget build(BuildContext context) {
    const size = 24.0;
    const thickness = 4.0;
    const color = Color(0xFFFF6B35);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          alignment: alignment,
          color: color,
          thickness: thickness,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Alignment alignment;
  final Color color;
  final double thickness;

  _CornerPainter({
    required this.alignment,
    required this.color,
    required this.thickness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..strokeCap = StrokeCap.square
      ..style = PaintingStyle.stroke;

    final isLeft = alignment.x < 0;
    final isTop = alignment.y < 0;

    final startX = isLeft ? 0.0 : size.width;
    final startY = isTop ? 0.0 : size.height;
    final endX = isLeft ? size.width : 0.0;
    final endY = isTop ? size.height : 0.0;

    canvas.drawLine(Offset(startX, startY), Offset(endX, startY), paint);
    canvas.drawLine(Offset(startX, startY), Offset(startX, endY), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter oldDelegate) => false;
}
