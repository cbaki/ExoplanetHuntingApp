import 'package:flutter/material.dart';
import '../widgets/space_background.dart';
import '../theme/app_theme.dart';

class DiscoveryStoryScreen extends StatelessWidget {
  final Map<String, dynamic> planetData;
  final Map<String, dynamic> starInfo;
  final double confidence;
  final String planetType;

  const DiscoveryStoryScreen({
    super.key,
    required this.planetData,
    required this.starInfo,
    required this.confidence,
    required this.planetType,
  });

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Keşif Hikayesi',
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
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: AppTheme.textWhite),
              onPressed: () => _shareStory(context),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Ana başlık
              _buildMainTitle(),
              const SizedBox(height: 24),

              // Gezegen parametreleri kartları
              _buildParameterCards(),
              const SizedBox(height: 24),

              // Bilimsel önem
              _buildScientificImportance(),
              const SizedBox(height: 24),

              // Motivasyonel mesaj
              _buildMotivationalMessage(),
              const SizedBox(height: 24),

              // Keşif detayları
              _buildDiscoveryDetails(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.accentBlue.withOpacity(0.8),
            AppTheme.accentPurple.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentBlue.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🎉 YENİ GEZEGEN KEŞFİ!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Güven Skoru: ${(confidence * 100).toStringAsFixed(1)}%',
            style: const TextStyle(
              fontSize: 18,
              color: AppTheme.textWhite,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParameterCards() {
    final period = planetData['period'] ?? 365.0;
    final prad = planetData['prad'] ?? 1.0;
    final teq = planetData['teq'] ?? 288.0;

    return Column(
      children: [
        _buildParameterCard(
          '📏 BOYUT',
          'Bu gezegen Dünya\'dan ${prad.toStringAsFixed(1)} kat ${prad > 1 ? 'büyük' : 'küçük'}!',
          _getSizeDescription(prad),
          Colors.blue,
        ),
        const SizedBox(height: 16),
        _buildParameterCard(
          '🕐 YÖRÜNGE',
          'Yıldızı etrafında ${period.toStringAsFixed(0)} günde dönüyor!',
          _getOrbitDescription(period),
          Colors.green,
        ),
        const SizedBox(height: 16),
        _buildParameterCard(
          '🌡️ SICAKLIK',
          'Yüzey sıcaklığı: ${teq.toStringAsFixed(0)} Kelvin',
          _getTemperatureDescription(teq),
          Colors.orange,
        ),
        const SizedBox(height: 16),
        _buildParameterCard(
          '⭐ YILDIZ',
          '${starInfo['type'] ?? 'Bilinmeyen tip'} yıldızın yörüngesinde',
          _getStarDescription(),
          Colors.amber,
        ),
      ],
    );
  }

  Widget _buildParameterCard(String title, String mainText, String description, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mainText,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textWhite,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScientificImportance() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.cyan.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.science, color: Colors.cyan, size: 24),
              SizedBox(width: 8),
              Text(
                '🔬 BİLİMSEL ÖNEM',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyan,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getScientificImportance(),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textWhite,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.pink.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            '🌟 SEN BİR GEZEGEN KAŞİFİSİN!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            _getMotivationalMessage(),
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textWhite,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDiscoveryDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.secondaryDark.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.accentBlue.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.accentBlue, size: 24),
              SizedBox(width: 8),
              Text(
                '📊 KEŞİF DETAYLARI',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.accentBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDetailRow('Gezegen Tipi', planetType),
          _buildDetailRow('Keşif Tarihi', DateTime.now().toString().split(' ')[0]),
          _buildDetailRow('Güven Seviyesi', _getConfidenceLevel(confidence)),
          _buildDetailRow('Yıldız Kütlesi', starInfo['mass'] ?? 'Bilinmiyor'),
          _buildDetailRow('Yıldız Yaşı', starInfo['age'] ?? 'Bilinmiyor'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
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

  // Helper methods
  String _getSizeDescription(double prad) {
    if (prad < 0.8) return 'Küçük kayalık gezegen - Merkür benzeri';
    if (prad < 1.25) return 'Dünya benzeri boyut - Yaşam potansiyeli yüksek';
    if (prad < 2.0) return 'Süper-Dünya - Büyük kütle, güçlü yerçekimi';
    if (prad < 4.0) return 'Mini-Neptün - Gaz ve buz karışımı';
    return 'Gaz Devi - Jüpiter benzeri büyük gezegen';
  }

  String _getOrbitDescription(double period) {
    if (period < 10) return 'Çok yakın yörünge - Aşırı sıcak';
    if (period < 50) return 'Kısa yörünge - Sıcak iklim';
    if (period < 200) return 'Orta yörünge - Ilıman iklim';
    if (period < 1000) return 'Uzun yörünge - Soğuk iklim';
    return 'Çok uzun yörünge - Aşırı soğuk';
  }

  String _getTemperatureDescription(double teq) {
    if (teq < 200) return 'Aşırı soğuk - Buz dünyası';
    if (teq < 273) return 'Çok soğuk - Donmuş yüzey';
    if (teq < 350) return 'Ilıman - Su sıvı halde';
    if (teq < 500) return 'Sıcak - Buhar atmosferi';
    return 'Aşırı sıcak - Eriyen yüzey';
  }

  String _getStarDescription() {
    final starType = starInfo['type'] ?? 'Bilinmeyen';
    final brightness = starInfo['brightness'] ?? 'Bilinmiyor';
    return '$starType yıldız, parlaklık: $brightness';
  }

  String _getScientificImportance() {
    final prad = planetData['prad'] ?? 1.0;
    final teq = planetData['teq'] ?? 288.0;
    final period = planetData['period'] ?? 365.0;
    
    if (prad > 0.8 && prad < 2.0 && teq > 250 && teq < 400 && period > 50 && period < 500) {
      return 'Bu gezegen yaşam araştırmaları için yüksek potansiyele sahip! Dünya benzeri boyut, uygun sıcaklık aralığı ve stabil yörünge özellikleri gösteriyor.';
    } else if (prad > 1.5 && prad < 4.0) {
      return 'Süper-Dünya kategorisinde yer alan bu gezegen, atmosfer ve jeoloji araştırmaları için önemli bir hedef.';
    } else if (teq > 200 && teq < 300) {
      return 'Soğuk iklim özellikleri gösteren bu gezegen, buz dünyaları ve kriyovolkanizma araştırmaları için değerli.';
    } else {
      return 'Bu gezegen, farklı gezegen oluşum süreçlerini anlamak için önemli veriler sağlayabilir.';
    }
  }

  String _getMotivationalMessage() {
    final confidence = this.confidence;
    if (confidence > 0.8) {
      return 'Mükemmel bir keşif! Yüksek güven skoru ile yeni bir dünya keşfettin. Bu başarı astronomi tarihine geçecek!';
    } else if (confidence > 0.6) {
      return 'Harika bir keşif! Güçlü verilerle yeni bir gezegen tespit ettin. Daha fazla gözlem ile doğrulanabilir.';
    } else {
      return 'İlginç bir bulgu! Bu gezegen daha fazla araştırma gerektiriyor. Her keşif bilimsel ilerlemenin bir parçası!';
    }
  }

  String _getConfidenceLevel(double confidence) {
    if (confidence > 0.8) return 'Çok Yüksek';
    if (confidence > 0.6) return 'Yüksek';
    if (confidence > 0.4) return 'Orta';
    return 'Düşük';
  }

  void _shareStory(BuildContext context) {
    // Paylaşım fonksiyonu burada implement edilebilir
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Keşif hikayesi paylaşıldı!'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
