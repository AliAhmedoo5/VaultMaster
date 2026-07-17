import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme.dart';
import '../../../core/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.marginMobile),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppConstants.xl),
              // App Logo / Header
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: const Icon(
                      Icons.lock_person_outlined,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppConstants.sm),
                  Text(
                    'VaultMaster',
                    style: textTheme.headlineMedium?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Animated Custom Vault Illustration (Premium visual design)
              Center(
                child: SizedBox(
                  width: 220,
                  height: 220,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return CustomPaint(
                        painter: _VaultPainter(rotationAngle: _controller.value * 2 * math.pi),
                      );
                    },
                  ),
                ),
              ),
              const Spacer(),
              // High-impact intro typography & branding summary
              Text(
                'A pocket filing cabinet built for security.',
                textAlign: TextAlign.center,
                style: textTheme.displayLarge?.copyWith(
                  fontSize: 26,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: AppConstants.md),
              Text(
                'Clean document scanning, PIN passcode protection, and offline-first encryption. Your confidential documents, exactly where they belong.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontSize: 15,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: AppConstants.xl),
              // Action Buttons
              ElevatedButton(
                onPressed: () => context.go('/login'),
                child: const Text('GET STARTED'),
              ),
              const SizedBox(height: AppConstants.md),
              Center(
                child: Text(
                  'v1.0 • Secure Sync Enabled',
                  style: textTheme.labelSmall?.copyWith(
                    color: AppTheme.outline,
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _VaultPainter extends CustomPainter {
  final double rotationAngle;
  _VaultPainter({required this.rotationAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppTheme.primary
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 1. Draw outer vault body (Square with rounded corners)
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 160, height: 160),
      const Radius.circular(AppTheme.radiusLg * 2),
    );
    canvas.drawRRect(rect, fillPaint);
    
    // Draw outer frame line
    paint.color = AppTheme.primary;
    canvas.drawRRect(rect, paint);

    // Draw secondary frame border for a premium double-layered look
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 140, height: 140),
      const Radius.circular(AppTheme.radiusLg * 1.5),
    );
    paint.color = AppTheme.primary.withAlpha((255 * 0.15).toInt());
    canvas.drawRRect(innerRect, paint);

    // Draw screws on the corner
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.secondary.withAlpha((255 * 0.5).toInt());
    final corners = [
      Offset(center.dx - 65, center.dy - 65),
      Offset(center.dx + 65, center.dy - 65),
      Offset(center.dx - 65, center.dy + 65),
      Offset(center.dx + 65, center.dy + 65),
    ];
    for (var corner in corners) {
      canvas.drawCircle(corner, 3, paint);
    }

    // 2. Draw active digital lock scanner details in center
    paint.style = PaintingStyle.stroke;
    paint.color = AppTheme.primary;
    paint.strokeWidth = 2.5;
    
    // Draw lock wheel background circle
    canvas.drawCircle(center, 40, paint);
    
    // Draw ticking notches
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationAngle);
    
    paint.color = AppTheme.primary;
    for (int i = 0; i < 8; i++) {
      canvas.drawLine(const Offset(0, -40), const Offset(0, -32), paint);
      canvas.rotate(math.pi / 4);
    }
    
    // Lock wheel center handle
    paint.style = PaintingStyle.fill;
    paint.color = AppTheme.primary;
    canvas.drawCircle(Offset.zero, 14, paint);

    paint.style = PaintingStyle.stroke;
    paint.color = Colors.white;
    paint.strokeWidth = 2.0;
    canvas.drawLine(const Offset(-7, 0), const Offset(7, 0), paint);
    canvas.drawLine(const Offset(0, -7), const Offset(0, 7), paint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _VaultPainter oldDelegate) {
    return oldDelegate.rotationAngle != rotationAngle;
  }
}
