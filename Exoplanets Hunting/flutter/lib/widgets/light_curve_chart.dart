import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class LightCurveChart extends StatelessWidget {
  final List<Map<String, dynamic>> lightCurveData;
  final String title;

  const LightCurveChart({
    super.key,
    required this.lightCurveData,
    this.title = 'Işık Eğrisi',
  });

  @override
  Widget build(BuildContext context) {
    if (lightCurveData.isEmpty) {
      return const Center(
        child: Text(
          'Işık eğrisi verisi bulunamadı',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Veriyi charts_flutter formatına dönüştür
    // final series = _createSeries();

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 0.1,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.3),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 0.1,
                      getTitlesWidget: (value, meta) {
                        return Text(
                          value.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        );
                      },
                      reservedSize: 42,
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                ),
                minX: 0,
                maxX: lightCurveData.length.toDouble(),
                minY: 0,
                maxY: 1.2,
                lineBarsData: [
                  LineChartBarData(
                    spots: _getSpots(),
                    isCurved: true,
                    color: Colors.blue,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.blue.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<FlSpot> _getSpots() {
    if (lightCurveData.isEmpty) return [];
    
    return lightCurveData.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      return FlSpot(
        index.toDouble(),
        (data['brightness'] ?? 0.0).toDouble(),
      );
    }).toList();
  }
}

// Basit ışık eğrisi widget'ı (flutter_sparkline kullanarak)
class SimpleLightCurveChart extends StatelessWidget {
  final List<double> data;
  final String title;

  const SimpleLightCurveChart({
    super.key,
    required this.data,
    this.title = 'Işık Eğrisi',
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(
        child: Text(
          'Işık eğrisi verisi bulunamadı',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: LightCurvePainter(data),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }
}

class LightCurvePainter extends CustomPainter {
  final List<double> data;

  LightCurvePainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final path = Path();
    final fillPath = Path();

    final minValue = data.reduce((a, b) => a < b ? a : b);
    final maxValue = data.reduce((a, b) => a > b ? a : b);
    final range = maxValue - minValue;

    if (range == 0) return;

    final stepX = size.width / (data.length - 1);

    // Fill path başlangıcı
    fillPath.moveTo(0, size.height);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalizedValue = (data[i] - minValue) / range;
      final y = size.height - (normalizedValue * size.height);

      if (i == 0) {
        path.moveTo(x, y);
        fillPath.lineTo(x, y);
      } else {
        path.lineTo(x, y);
        fillPath.lineTo(x, y);
      }
    }

    // Fill path sonu
    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill area
    canvas.drawPath(fillPath, fillPaint);

    // Line
    canvas.drawPath(path, paint);

    // Transit bölgesini vurgula
    _highlightTransitRegion(canvas, size);
  }

  void _highlightTransitRegion(Canvas canvas, Size size) {
    // Transit bölgesini tespit et (parlaklık düşüşü)
    final transitRegions = <int>[];
    
    for (int i = 1; i < data.length - 1; i++) {
      if (data[i] < data[i - 1] && data[i] < data[i + 1]) {
        transitRegions.add(i);
      }
    }

    if (transitRegions.isNotEmpty) {
      final paint = Paint()
        ..color = Colors.red.withOpacity(0.3)
        ..style = PaintingStyle.fill;

      for (final region in transitRegions) {
        final x = (region / (data.length - 1)) * size.width;
        final rect = Rect.fromCenter(
          center: Offset(x, size.height / 2),
          width: 20,
          height: size.height,
        );
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}