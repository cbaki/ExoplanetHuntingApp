import 'package:flutter/material.dart';
import '../widgets/space_background.dart';
import '../theme/app_theme.dart';

class ComparisonScreen extends StatelessWidget {
  final Map<String, dynamic> comparisonData;

  const ComparisonScreen({
    super.key,
    required this.comparisonData,
  });

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Dünya ile Karşılaştırma',
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
                '📊 Dünya ile Karşılaştırma',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textWhite,
                ),
              ),
              const SizedBox(height: 20),

              // Karşılaştırma kartları
              _buildComparisonCard(
                'Boyut',
                comparisonData['size_comparison'] ?? 'Hesaplanıyor...',
                Icons.straighten,
                Colors.blue,
              ),
              const SizedBox(height: 12),

              _buildComparisonCard(
                'Yörünge',
                comparisonData['orbit_comparison'] ?? 'Hesaplanıyor...',
                Icons.timeline,
                Colors.green,
              ),
              const SizedBox(height: 12),

              _buildComparisonCard(
                'Sıcaklık',
                comparisonData['temperature_comparison'] ?? 'Hesaplanıyor...',
                Icons.thermostat,
                Colors.orange,
              ),
              const SizedBox(height: 12),

              _buildComparisonCard(
                'Kütle',
                comparisonData['mass_comparison'] ?? 'Hesaplanıyor...',
                Icons.scale,
                Colors.purple,
              ),
              const SizedBox(height: 20),

              // Detaylı bilgiler
              if (comparisonData['detailed_comparison'] != null) ...[
                const Text(
                  '🔍 Detaylı Analiz',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 12),
                _buildDetailedInfo(comparisonData['detailed_comparison']),
              ],

              const SizedBox(height: 20),

              // Sonuç özeti
              if (comparisonData['summary'] != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: AppTheme.secondaryDark.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(12),
                    // ignore: deprecated_member_use
                    border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '📋 Özet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textWhite,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comparisonData['summary'],
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppTheme.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComparisonCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textWhite,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedInfo(Map<String, dynamic> detailedData) {
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
        children: detailedData.entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.only(top: 6, right: 8),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentBlue,
                    shape: BoxShape.circle,
                  ),
                ),
                Expanded(
                  child: Text(
                    '${entry.key}: ${entry.value}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textGray,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
