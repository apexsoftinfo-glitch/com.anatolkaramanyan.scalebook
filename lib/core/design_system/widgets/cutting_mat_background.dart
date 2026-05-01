import 'package:flutter/material.dart';

class CuttingMatBackground extends StatelessWidget {
  final Widget child;

  const CuttingMatBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base technical color
        Positioned.fill(
          child: Container(
            color: const Color(0xFF001F3F), // Deep Navy Blue
          ),
        ),
        // The Programmatic Technical Mat
        Positioned.fill(
          child: CustomPaint(
            painter: _TechnicalMatPainter(),
          ),
        ),
        // Depth gradient
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.5,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.5),
                ],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}

class _TechnicalMatPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 0.5;

    final boldGridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1.0;

    final accentPaint = Paint()
      ..color = const Color(0xFF00AEEF).withValues(alpha: 0.2) // Accent Sky Blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const double step = 25.0;
    const double boldStep = 100.0;

    // 1. Draw Grid
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        (x % boldStep == 0) ? boldGridPaint : gridPaint,
      );
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        (y % boldStep == 0) ? boldGridPaint : gridPaint,
      );
    }

    // 2. Technical Markings (Circles/Protractor)
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 150, accentPaint);
    canvas.drawCircle(Offset(size.width / 2, size.height / 2), 250, gridPaint);
    
    // Corner Markings (Angles)
    _drawAngleMarkings(canvas, Offset(size.width, 0), accentPaint);
    _drawAngleMarkings(canvas, Offset(0, size.height), accentPaint);

    // 3. Scale Rulers at edges
    _drawRuler(canvas, size, true); // Bottom
    _drawRuler(canvas, size, false); // Right
    
    // 4. "Technical" Text
    const textStyle = TextStyle(
      color: Colors.white12,
      fontSize: 10,
      fontWeight: FontWeight.bold,
      letterSpacing: 2,
    );
    
    _drawText(canvas, "1/24 SCALE WORKBENCH", const Offset(20, 40), textStyle);
    _drawText(canvas, "SCALEBOOK PRECISION SYSTEM", Offset(20, size.height - 60), textStyle);
    _drawText(canvas, "MODEL: GENERIC_MAT_V2", Offset(size.width - 150, size.height - 60), textStyle);
  }

  void _drawAngleMarkings(Canvas canvas, Offset origin, Paint paint) {
    canvas.drawCircle(origin, 100, paint);
    canvas.drawCircle(origin, 105, paint);
  }

  void _drawRuler(Canvas canvas, Size size, bool horizontal) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.15)
      ..strokeWidth = 1.0;
      
    if (horizontal) {
      for (double x = 0; x < size.width; x += 10) {
        double height = (x % 50 == 0) ? 15 : 5;
        canvas.drawLine(Offset(x, size.height), Offset(x, size.height - height), paint);
      }
    } else {
      for (double y = 0; y < size.height; y += 10) {
        double width = (y % 50 == 0) ? 15 : 5;
        canvas.drawLine(Offset(size.width, y), Offset(size.width - width, y), paint);
      }
    }
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
