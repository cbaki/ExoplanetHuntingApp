import 'package:flutter/material.dart';

class LightCurvePainter extends CustomPainter {
  final double period;
  final double depth;
  final Color curveColor;
  final Color gridColor;

  LightCurvePainter({
    required this.period,
    required this.depth,
    this.curveColor = Colors.cyan,
    this.gridColor = Colors.grey,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = curveColor
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final gridPaint = Paint()
      // ignore: deprecated_member_use
      ..color = gridColor.withOpacity(0.3)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Grid çizgileri
    _drawGrid(canvas, size, gridPaint);
    
    // Işık eğrisi
    _drawLightCurve(canvas, size, paint);
  }

  void _drawGrid(Canvas canvas, Size size, Paint paint) {
    // Yatay grid çizgileri
    for (int i = 0; i <= 4; i++) {
      final y = (size.height / 4) * i;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }

    // Dikey grid çizgileri
    for (int i = 0; i <= 8; i++) {
      final x = (size.width / 8) * i;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
  }

  void _drawLightCurve(Canvas canvas, Size size, Paint paint) {
    final path = Path();
    final points = <Offset>[];

    // Işık eğrisi verilerini hesapla
    for (int i = 0; i <= 100; i++) {
      final x = (size.width / 100) * i;
      final time = (i / 100.0) * period * 2; // 2 periyot göster
      
      // Transit simülasyonu
      double brightness = 1.0;
      final transitWidth = 0.1 * period; // Transit genişliği
      
      if ((time % period).abs() < transitWidth) {
        // Transit sırasında parlaklık azalır
        final transitProgress = ((time % period).abs() / transitWidth);
        brightness = 1.0 - (depth / 10000.0) * (1.0 - transitProgress);
      }
      
      final y = size.height - (brightness * size.height);
      points.add(Offset(x, y));
    }

    // Eğriyi çiz
    if (points.isNotEmpty) {
      path.moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
    }

    canvas.drawPath(path, paint);

    // Transit bölgesini vurgula
    _highlightTransit(canvas, size);
  }

  void _highlightTransit(Canvas canvas, Size size) {
    final transitPaint = Paint()
      // ignore: deprecated_member_use
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final transitWidth = 0.1 * period;
    final transitX = (size.width / (period * 2)) * period;
    final transitRect = Rect.fromLTWH(
      transitX - (transitWidth * size.width / (period * 2)) / 2,
      0,
      transitWidth * size.width / (period * 2),
      size.height,
    );

    canvas.drawRect(transitRect, transitPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate is LightCurvePainter &&
        (oldDelegate.period != period || oldDelegate.depth != depth);
  }
}
