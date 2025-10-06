import 'package:flutter/material.dart';
import 'dart:math' as math;

class SpaceBackground extends StatefulWidget {
  final Widget child;
  final bool showStars;
  final bool showNebula;
  final bool animated;

  const SpaceBackground({
    super.key,
    required this.child,
    this.showStars = true,
    this.showNebula = true,
    this.animated = true,
  });

  @override
  State<SpaceBackground> createState() => _SpaceBackgroundState();
}

class _SpaceBackgroundState extends State<SpaceBackground>
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _nebulaController;
  late Animation<double> _starAnimation;
  late Animation<double> _nebulaAnimation;

  final List<Star> _stars = [];
  final math.Random _random = math.Random();

  @override
  void initState() {
    super.initState();
    
    _starController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );
    
    _nebulaController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );

    _starAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.linear,
    ));

    _nebulaAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _nebulaController,
      curve: Curves.easeInOut,
    ));

    _generateStars();
    
    if (widget.animated) {
      _starController.repeat();
      _nebulaController.repeat(reverse: true);
    }
  }

  void _generateStars() {
    _stars.clear();
    for (int i = 0; i < 150; i++) {
      _stars.add(Star(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: _random.nextDouble() * 3 + 1,
        opacity: _random.nextDouble() * 0.8 + 0.2,
        speed: _random.nextDouble() * 0.5 + 0.1,
      ));
    }
  }

  @override
  void dispose() {
    _starController.dispose();
    _nebulaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0F0F23),
          ],
          stops: [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Nebula background
          if (widget.showNebula)
            AnimatedBuilder(
              animation: _nebulaAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: NebulaPainter(_nebulaAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

          // Animated stars
          if (widget.showStars)
            AnimatedBuilder(
              animation: _starAnimation,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarFieldPainter(_stars, _starAnimation.value),
                  size: Size.infinite,
                );
              },
            ),

          // Content
          widget.child,
        ],
      ),
    );
  }
}

class Star {
  double x;
  double y;
  double size;
  double opacity;
  double speed;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
  });
}

class StarFieldPainter extends CustomPainter {
  final List<Star> stars;
  final double animationValue;

  StarFieldPainter(this.stars, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      final animatedX = (star.x + animationValue * star.speed) % 1.0;
      final animatedY = (star.y + animationValue * star.speed * 0.5) % 1.0;
      
      final x = animatedX * size.width;
      final y = animatedY * size.height;
      
      // Twinkling effect
      final twinkle = (math.sin(animationValue * math.pi * 2 + star.x * 10) + 1) / 2;
      final currentOpacity = star.opacity * (0.5 + twinkle * 0.5);
      
      // ignore: deprecated_member_use
      paint.color = Colors.white.withOpacity(currentOpacity);
      canvas.drawCircle(
        Offset(x, y),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class NebulaPainter extends CustomPainter {
  final double animationValue;

  NebulaPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Create nebula effect with multiple overlapping circles
    final nebulaColors = [
      // ignore: deprecated_member_use
      const Color(0xFF1A1A2E).withOpacity(0.3),
      // ignore: deprecated_member_use
      const Color(0xFF16213E).withOpacity(0.4),
      // ignore: deprecated_member_use
      const Color(0xFF0F0F23).withOpacity(0.5),
      // ignore: deprecated_member_use
      const Color(0xFF4A148C).withOpacity(0.2),
      // ignore: deprecated_member_use
      const Color(0xFF1A237E).withOpacity(0.3),
    ];

    for (int i = 0; i < 5; i++) {
      final centerX = size.width * (0.2 + i * 0.2);
      final centerY = size.height * (0.3 + i * 0.15);
      final radius = size.width * (0.3 + i * 0.1);
      
      // Animate the nebula
      final animatedRadius = radius * (0.8 + 0.4 * math.sin(animationValue * math.pi * 2 + i));
      
      paint.color = nebulaColors[i];
      canvas.drawCircle(
        Offset(centerX, centerY),
        animatedRadius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
