import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const KungFuSymbolApp());
}

class KungFuSymbolApp extends StatelessWidget {
  const KungFuSymbolApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: KungFuScreen(),
    );
  }
}

class KungFuScreen extends StatefulWidget {
  const KungFuScreen({super.key});

  @override
  State<KungFuScreen> createState() => _KungFuScreenState();
}

class _KungFuScreenState extends State<KungFuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge([_rotationController, _glowController]),
          builder: (context, child) {
            return Transform.rotate(
              angle: _rotationController.value * 2 * pi,
              child: CustomPaint(
                size: const Size(260, 260),
                painter: YinYangPainter(
                  glowValue: _glowController.value,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class YinYangPainter extends CustomPainter {
  final double glowValue;

  YinYangPainter({required this.glowValue});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    // استخدام Rect للقص الدائري بشكل صحيح
    canvas.save();
    canvas.clipPath(
      Path()..addOval(Rect.fromCircle(center: center, radius: radius)),
    );

    final Paint whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(radius, 0, radius, size.height), whitePaint);

    final Paint blackPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    canvas.drawRect(Rect.fromLTWH(0, 0, radius, size.height), blackPaint);

    final double halfRadius = radius / 2;
    
    final Offset topCenter = Offset(radius, radius - halfRadius);
    canvas.drawCircle(topCenter, halfRadius, blackPaint);

    final Offset bottomCenter = Offset(radius, radius + halfRadius);
    canvas.drawCircle(bottomCenter, halfRadius, whitePaint);

    canvas.restore();

    final Paint borderPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, borderPaint);

    final double currentGlowRadius = 8.0 + (glowValue * 6.0);

    final Paint blackGlowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4 * glowValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(topCenter, currentGlowRadius, blackGlowPaint);

    canvas.drawCircle(topCenter, halfRadius * 0.35, blackPaint);

    final Paint whiteGlowPaint = Paint()
      ..color = Colors.white.withOpacity(0.6 * glowValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawCircle(bottomCenter, currentGlowRadius, whiteGlowPaint);

    canvas.drawCircle(bottomCenter, halfRadius * 0.35, whitePaint);
  }

  @override
  bool shouldRepaint(covariant YinYangPainter oldDelegate) {
    return oldDelegate.glowValue != glowValue;
  }
}

