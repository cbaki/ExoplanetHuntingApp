import 'package:flutter/material.dart';
import '../widgets/space_background.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Döndürme animasyonu
    _rotationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Yanıp sönme animasyonu
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Animasyonları başlat
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ana yıldız animasyonu
            AnimatedBuilder(
              animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value * 2 * 3.14159,
                  child: Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Icon(
                      Icons.star,
                      size: 80,
                      // ignore: deprecated_member_use
                      color: Colors.yellow.withOpacity(_pulseAnimation.value),
                    ),
                  ),
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Çevreleyen küçük yıldızlar
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      // Her yıldız farklı zamanda yanıp sönsün
                      final delay = index * 0.2;
                      final animationValue = (_pulseController.value + delay) % 1.0;
                      final opacity = (animationValue < 0.5) 
                          ? animationValue * 2 
                          : (1 - animationValue) * 2;
                      
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 5),
                        child: Icon(
                          Icons.star_outline,
                          size: 20,
                          // ignore: deprecated_member_use
                          color: Colors.white.withOpacity(opacity),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Yükleniyor metni
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Text(
                  'Yükleniyor...',
                  style: TextStyle(
                    fontSize: 24,
                    // ignore: deprecated_member_use
                    color: Colors.white.withOpacity(_pulseAnimation.value * 0.8 + 0.2),
                    fontWeight: FontWeight.w300,
                    letterSpacing: 2,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 20),
            
            // İlerleme çubuğu
            Container(
              width: 200,
              height: 4,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: AnimatedBuilder(
                animation: _rotationController,
                builder: (context, child) {
                  return LinearProgressIndicator(
                    value: null,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      // ignore: deprecated_member_use
                      Colors.yellow.withOpacity(0.7),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
