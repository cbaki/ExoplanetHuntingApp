import 'package:flutter/material.dart';
import '../widgets/space_background.dart';
import '../widgets/light_curve_chart.dart';
import '../theme/app_theme.dart';

class LightCurveScreen extends StatelessWidget {
  final List<Map<String, dynamic>> lightCurveData;

  const LightCurveScreen({
    super.key,
    required this.lightCurveData,
  });

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Işık Eğrisi Analizi',
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
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Başlık
              const Text(
                '📈 Işık Eğrisi Analizi',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Gezegen geçişi sırasında yıldızın parlaklık değişimini gösterir',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textGray,
                ),
              ),
              const SizedBox(height: 20),

              // Ana grafik
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                ),
                child: LightCurveChart(
                  lightCurveData: lightCurveData,
                  title: 'Gezegen Geçiş Işık Eğrisi',
                ),
              ),

              const SizedBox(height: 20),

              // Basit grafik alternatifi
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppTheme.secondaryDark.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                ),
                child: SimpleLightCurveChart(
                  data: _extractBrightnessData(),
                  title: 'Basit Işık Eğrisi',
                ),
              ),

              const SizedBox(height: 20),

              // Analiz bilgileri
              _buildAnalysisInfo(),
            ],
          ),
        ),
      ),
    );
  }

  List<double> _extractBrightnessData() {
    if (lightCurveData.isEmpty) return [];
    
    return lightCurveData
        .map<double>((data) => (data['brightness'] ?? 0.0).toDouble())
        .toList();
  }

  Widget _buildAnalysisInfo() {
    if (lightCurveData.isEmpty) {
      return const SizedBox.shrink();
    }

    // Transit bölgesini tespit et
    final brightnessValues = _extractBrightnessData();
    final minBrightness = brightnessValues.reduce((a, b) => a < b ? a : b);
    final maxBrightness = brightnessValues.reduce((a, b) => a > b ? a : b);
    final transitDepth = maxBrightness - minBrightness;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🔍 Analiz Sonuçları',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 12),
          _buildInfoRow('Maksimum Parlaklık', '${maxBrightness.toStringAsFixed(3)}'),
          _buildInfoRow('Minimum Parlaklık', '${minBrightness.toStringAsFixed(3)}'),
          _buildInfoRow('Transit Derinliği', '${transitDepth.toStringAsFixed(3)}'),
          _buildInfoRow('Veri Noktası Sayısı', '${lightCurveData.length}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textGray,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
        ],
      ),
    );
  }
}
