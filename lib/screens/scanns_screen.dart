
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:recruteur/screens/verification.dart';

import 'package:recruteur/theme/app_theme.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with TickerProviderStateMixin {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
  );

  bool _isProcessing = false;
  bool _isTorchOn = false;

  // Animated scan line
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnimation;

  // Pulse on corners when QR detected
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanLineAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanLineController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scanLineController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_isProcessing) return;

    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw == null || raw.isEmpty) continue;

      setState(() => _isProcessing = true);
      _scanLineController.stop();
      _pulseController.forward().then((_) => _pulseController.reverse());

      // Extract UUID from URL or use raw value directly
      final diplomaId = _extractDiplomaId(raw);

      Future.delayed(const Duration(milliseconds: 300), () {
        if (!mounted) return;
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (_, a, _) =>
                VerificationScreen(diplomaId: diplomaId),
            transitionsBuilder: (_, anim, _, child) => FadeTransition(
              opacity: anim,
              child: child,
            ),
            transitionDuration: const Duration(milliseconds: 400),
          ),
        ).then((_) {
          if (mounted) {
            setState(() => _isProcessing = false);
            _scanLineController.repeat(reverse: true);
          }
        });
      });
      break;
    }
  }

  /// Extract UUID from a URL like https://.../?id=UUID or use raw as UUID
  String _extractDiplomaId(String raw) {
    try {
      final uri = Uri.tryParse(raw);
      if (uri != null) {
        // Try query param ?id= or ?diploma_id=
        final id = uri.queryParameters['id'] ??
            uri.queryParameters['diploma_id'];
        if (id != null && id.isNotEmpty) return id;
        // Try last path segment
        final segments = uri.pathSegments.where((s) => s.isNotEmpty).toList();
        if (segments.isNotEmpty) {
          final last = segments.last;
          // Rough UUID check
          if (last.length == 36 && last.contains('-')) return last;
        }
      }
    } catch (_) {}
    return raw; // fallback: raw value is the UUID
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Scanner un document",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isTorchOn ? Icons.flash_on : Icons.flash_off,
              color: _isTorchOn ? AppColors.accentGold : Colors.white,
            ),
            onPressed: () {
              _controller.toggleTorch();
              setState(() => _isTorchOn = !_isTorchOn);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera feed (full screen)
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),

          // Overlay
          _DocumentOverlay(
            scanLineAnimation: _scanLineAnimation,
            pulseAnimation: _pulseAnimation,
            isProcessing: _isProcessing,
          ),

          // Bottom hint + controls
          _BottomBar(
            isProcessing: _isProcessing,
            onGalleryTap: () {
              // Image picker could be wired here
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Document-shaped overlay with animated scan line
// ---------------------------------------------------------------------------
class _DocumentOverlay extends StatelessWidget {
  final Animation<double> scanLineAnimation;
  final Animation<double> pulseAnimation;
  final bool isProcessing;

  const _DocumentOverlay({
    required this.scanLineAnimation,
    required this.pulseAnimation,
    required this.isProcessing,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // A4 ratio ≈ 1:1.414  — document frame
    const hPadding = 32.0;
    final frameW = size.width - hPadding * 2;
    final frameH = frameW * 1.414;

    // Keep frame vertically centred but slightly above center
    final topOffset = (size.height - frameH) / 2 - 20;

    return Stack(
      children: [
        // Dark vignette around the frame
        CustomPaint(
          size: size,
          painter: _VignettePainter(
            frameRect: Rect.fromLTWH(hPadding, topOffset, frameW, frameH),
            radius: 12,
          ),
        ),

        // Animated scan line (only while not processing)
        if (!isProcessing)
          AnimatedBuilder(
            animation: scanLineAnimation,
            builder: (_, __) {
              final y = topOffset + 12 + (frameH - 24) * scanLineAnimation.value;
              return Positioned(
                top: y,
                left: hPadding + 12,
                right: hPadding + 12,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accentGold.withOpacity(0.4),
                        AppColors.accentGold,
                        AppColors.accentGold.withOpacity(0.4),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accentGold.withOpacity(0.6),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

        // Subtle frame border
        Positioned(
          left: hPadding,
          top: topOffset,
          width: frameW,
          height: frameH,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Corner brackets with pulse
        AnimatedBuilder(
          animation: pulseAnimation,
          builder: (_, __) {
            return Positioned(
              left: hPadding,
              top: topOffset,
              width: frameW,
              height: frameH,
              child: Transform.scale(
                scale: pulseAnimation.value,
                child: CustomPaint(
                  painter: _CornerPainter(
                    color: isProcessing
                        ? AppColors.accentGold
                        : AppColors.primaryGreen,
                    cornerLength: 40,
                    strokeWidth: 4,
                    radius: 12,
                  ),
                ),
              ),
            );
          },
        ),

        // Top instruction
        Positioned(
          top: topOffset - 70,
          left: 0,
          right: 0,
          child: Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.document_scanner, color: AppColors.accentGold, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        "Cadrer le document entier",
                        style: AppTheme.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Processing overlay
        if (isProcessing)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(
                        color: AppColors.accentGold,
                        strokeWidth: 4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      "QR Code identifié",
                      style: AppTheme.heading2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Vérification sécurisée en cours...",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom controls bar
// ---------------------------------------------------------------------------
class _BottomBar extends StatelessWidget {
  final bool isProcessing;
  final VoidCallback onGalleryTap;

  const _BottomBar({required this.isProcessing, required this.onGalleryTap});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          // Shutter-style visual button (decorative)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.photo_library_outlined,
                    color: Colors.white70, size: 30),
                onPressed: isProcessing ? null : onGalleryTap,
                tooltip: "Galerie",
              ),
              // Center shutter circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            "Scan automatique activé",
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painters
// ---------------------------------------------------------------------------

/// Darkens everything outside the document frame
class _VignettePainter extends CustomPainter {
  final Rect frameRect;
  final double radius;

  _VignettePainter({required this.frameRect, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(
          RRect.fromRectAndRadius(frameRect, Radius.circular(radius)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      path,
      Paint()..color = Colors.black.withOpacity(0.62),
    );
  }

  @override
  bool shouldRepaint(_VignettePainter old) =>
      old.frameRect != frameRect;
}

/// Draws corner brackets only (no full border)
class _CornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;
  final double radius;

  _CornerPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final corners = [
      // top-left
      [Offset(0, cornerLength), Offset(0, radius),
        Offset(radius, 0), Offset(cornerLength, 0)],
      // top-right
      [Offset(size.width - cornerLength, 0), Offset(size.width - radius, 0),
        Offset(size.width, radius), Offset(size.width, cornerLength)],
      // bottom-left
      [Offset(0, size.height - cornerLength), Offset(0, size.height - radius),
        Offset(radius, size.height), Offset(cornerLength, size.height)],
      // bottom-right
      [Offset(size.width - cornerLength, size.height),
        Offset(size.width - radius, size.height),
        Offset(size.width, size.height - radius),
        Offset(size.width, size.height - cornerLength)],
    ];

    for (final pts in corners) {
      final path = Path()
        ..moveTo(pts[0].dx, pts[0].dy)
        ..lineTo(pts[1].dx, pts[1].dy)
        ..quadraticBezierTo(
            pts[1].dx + (pts[2].dx - pts[1].dx) * 0.5,
            pts[1].dy + (pts[2].dy - pts[1].dy) * 0.5,
            pts[2].dx,
            pts[2].dy)
        ..lineTo(pts[3].dx, pts[3].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}