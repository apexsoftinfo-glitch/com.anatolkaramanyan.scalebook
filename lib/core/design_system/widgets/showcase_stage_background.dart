import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../app_colors.dart';

class ShowcaseStageBackground extends StatefulWidget {
  final Widget child;

  const ShowcaseStageBackground({
    super.key,
    required this.child,
  });

  @override
  State<ShowcaseStageBackground> createState() => _ShowcaseStageBackgroundState();
}

class _ShowcaseStageBackgroundState extends State<ShowcaseStageBackground> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: Stack(
        children: [
          // 1. App Navy Base (Rich Gradient)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.navyBlue.withValues(alpha: 0.9),
                    const Color(0xFF001A33),
                  ],
                ),
              ),
            ),
          ),
          
          // 2. Ambient Navy Glow
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.navyBlue.withValues(alpha: 0.5),
                    Colors.transparent,
                    AppColors.navyBlue.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),

          // 3. Main Sky Blue Spotlight (Radial + Animation)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                // Subtle horizontal shift for the spotlight
                final double xOffset = 0.05 * math.sin(_controller.value * 2 * math.pi);
                
                return Container(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment(xOffset, -0.5),
                      radius: 1.6 * _pulseAnimation.value,
                      colors: [
                        AppColors.skyBlue.withValues(alpha: 0.35 * _pulseAnimation.value),
                        AppColors.navyBlue.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

          // 4. Red Perspective Accent (Subtle line at horizon)
          Positioned(
            top: MediaQuery.of(context).size.height * 0.65,
            left: 0,
            right: 0,
            height: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    AppColors.red.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // 5. Floor Reflector (Less black, more deep navy)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.35,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.navyBlue.withValues(alpha: 0.2),
                    const Color(0xFF000810).withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),

          // 6. Grid & Markings
          Positioned.fill(
            child: CustomPaint(
              painter: _StagePainter(),
            ),
          ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class _StagePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double floorY = 0.65;
    final double startY = size.height * floorY;

    // Floor Grid - Using SkyBlue for a technical look
    final gridPaint = Paint()
      ..color = AppColors.skyBlue.withValues(alpha: 0.1)
      ..strokeWidth = 0.7;

    // Perspective vertical lines
    for (double i = -1.5; i <= 2.5; i += 0.5) {
      canvas.drawLine(
        Offset(size.width * 0.5 + (size.width * (i - 0.5) * 0.15), startY),
        Offset(size.width * i, size.height),
        gridPaint,
      );
    }

    // Horizontal grid lines on the floor
    for (double i = 0; i <= 1.0; i += 0.2) {
      final y = startY + (size.height - startY) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint..color = AppColors.skyBlue.withValues(alpha: 0.1 * (1 - i)),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
