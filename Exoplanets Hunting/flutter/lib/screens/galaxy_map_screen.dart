import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../widgets/space_background.dart';
import '../theme/app_theme.dart';
import '../services/storage_service.dart';

class GalaxyMapScreen extends StatefulWidget {
  const GalaxyMapScreen({super.key});

  @override
  State<GalaxyMapScreen> createState() => _GalaxyMapScreenState();
}

class _GalaxyMapScreenState extends State<GalaxyMapScreen>
    with TickerProviderStateMixin {
  late AnimationController _galaxyController;
  late AnimationController _starController;
  late AnimationController _planetController;
  
  late Animation<double> _galaxyRotation;
  late Animation<double> _starTwinkle;
  late Animation<double> _planetGlow;
  
  List<Map<String, dynamic>> discoveredPlanets = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadDiscoveredPlanets();
  }

  void _initializeAnimations() {
    // Galaksi dönüş animasyonu
    _galaxyController = AnimationController(
      duration: const Duration(seconds: 30),
      vsync: this,
    );
    _galaxyRotation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _galaxyController,
      curve: Curves.linear,
    ));

    // Yıldız titreme animasyonu
    _starController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _starTwinkle = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _starController,
      curve: Curves.easeInOut,
    ));

    // Gezegen parlaması animasyonu
    _planetController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );
    _planetGlow = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _planetController,
      curve: Curves.easeInOut,
    ));

    // Animasyonları başlat
    _galaxyController.repeat();
    _starController.repeat(reverse: true);
    _planetController.repeat(reverse: true);
  }

  Future<void> _loadDiscoveredPlanets() async {
    try {
      final results = await StorageService.getSavedResults();
      setState(() {
        discoveredPlanets = results.map((result) => {
          'name': 'KEP-${result.id.substring(result.id.length - 3)}',
          'confidence': result.confidence,
          'prad': result.planetData['prad'] ?? 1.0,
          'period': result.planetData['period'] ?? 365.0,
          'teq': result.planetData['teq'] ?? 288.0,
          'planetType': result.planetType,
          'timestamp': result.timestamp,
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _galaxyController.dispose();
    _starController.dispose();
    _planetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Galaksi Haritası',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Stack(
                children: [
                  // Galaksi arka planı
                  _buildGalaxyBackground(),
                  
                  // Yıldız arka planı
                  _buildStarField(),
                  
                  // Gezegen işaretleri
                  _buildPlanetMarkers(),
                  
                  // Açıklama paneli
                  _buildInfoPanel(),
                ],
              ),
      ),
    );
  }

  Widget _buildGalaxyBackground() {
    return AnimatedBuilder(
      animation: _galaxyRotation,
      builder: (context, child) {
        return CustomPaint(
          painter: GalaxyPainter(_galaxyRotation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildStarField() {
    return AnimatedBuilder(
      animation: _starTwinkle,
      builder: (context, child) {
        return CustomPaint(
          painter: StarFieldPainter(_starTwinkle.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildPlanetMarkers() {
    return AnimatedBuilder(
      animation: _planetGlow,
      builder: (context, child) {
        return CustomPaint(
          painter: PlanetMarkersPainter(
            discoveredPlanets,
            _planetGlow.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildInfoPanel() {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.secondaryDark.withOpacity(0.9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.explore, color: AppTheme.accentBlue, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Keşif İstatistikleri',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Toplam', '${discoveredPlanets.length}', Colors.blue),
                _buildStatItem('Yüksek Güven', '${_getHighConfidenceCount()}', Colors.green),
                _buildStatItem('Orta Güven', '${_getMediumConfidenceCount()}', Colors.orange),
                _buildStatItem('Düşük Güven', '${_getLowConfidenceCount()}', Colors.red),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Gezegenlere dokunarak detayları görüntüleyebilirsiniz',
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.textGray,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textGray,
          ),
        ),
      ],
    );
  }

  int _getHighConfidenceCount() {
    return discoveredPlanets.where((p) => p['confidence'] > 0.7).length;
  }

  int _getMediumConfidenceCount() {
    return discoveredPlanets.where((p) => p['confidence'] >= 0.5 && p['confidence'] <= 0.7).length;
  }

  int _getLowConfidenceCount() {
    return discoveredPlanets.where((p) => p['confidence'] < 0.5).length;
  }

}

// Galaksi çizim sınıfı
class GalaxyPainter extends CustomPainter {
  final double rotation;

  GalaxyPainter(this.rotation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    // Galaksi spiral çizimi
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withOpacity(0.8),
          Colors.blue.withOpacity(0.6),
          Colors.purple.withOpacity(0.4),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 0.7, 1.0],
      ).createShader(Rect.fromCircle(center: center, radius: radius));

    // Spiral kollar
    for (int arm = 0; arm < 4; arm++) {
      final armAngle = (arm * math.pi / 2) + rotation;
      _drawSpiralArm(canvas, center, radius, armAngle, paint);
    }
  }

  void _drawSpiralArm(Canvas canvas, Offset center, double radius, double startAngle, Paint paint) {
    final path = Path();
    bool isFirst = true;
    
    for (double r = 0; r < radius; r += 2) {
      final angle = startAngle + (r / radius) * 4 * math.pi;
      final x = center.dx + r * math.cos(angle);
      final y = center.dy + r * math.sin(angle);
      
      if (isFirst) {
        path.moveTo(x, y);
        isFirst = false;
      } else {
        path.lineTo(x, y);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Yıldız alanı çizim sınıfı
class StarFieldPainter extends CustomPainter {
  final double twinkle;

  StarFieldPainter(this.twinkle);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white;
    final random = math.Random(42); // Sabit seed için

    for (int i = 0; i < 200; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final opacity = (0.3 + twinkle * 0.7) * random.nextDouble();
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2 + 0.5, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Gezegen işaretleri çizim sınıfı
class PlanetMarkersPainter extends CustomPainter {
  final List<Map<String, dynamic>> planets;
  final double glow;

  PlanetMarkersPainter(this.planets, this.glow);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 50;

    for (int i = 0; i < planets.length; i++) {
      final planet = planets[i];
      final angle = (i * 2 * math.pi / planets.length) + (glow * 0.1);
      final distance = radius * (0.3 + (i % 3) * 0.2);
      
      final x = center.dx + distance * math.cos(angle);
      final y = center.dy + distance * math.sin(angle);
      
      final confidence = planet['confidence'] as double;
      final color = _getPlanetColor(confidence);
      
      // Parlayan halka efekti
      final glowPaint = Paint()
        ..color = color.withOpacity(0.3 * glow)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3;
      
      canvas.drawCircle(Offset(x, y), 15, glowPaint);
      
      // Ana gezegen işareti
      final planetPaint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 8, planetPaint);
      
      // İç parlaklık
      final innerPaint = Paint()
        ..color = Colors.white.withOpacity(0.8 * glow)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(Offset(x, y), 4, innerPaint);
    }
  }

  Color _getPlanetColor(double confidence) {
    if (confidence > 0.7) return Colors.green;
    if (confidence >= 0.5) return Colors.orange;
    return Colors.red;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
