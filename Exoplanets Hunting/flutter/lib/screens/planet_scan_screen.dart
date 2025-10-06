import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/planet_api_service.dart';
import '../services/storage_service.dart';
import '../models/saved_result.dart';
import '../widgets/space_background.dart';
import '../theme/app_theme.dart';
import 'saved_results_screen.dart';
import 'comparison_screen.dart';
import 'light_curve_screen.dart';
import 'discovery_story_screen.dart';

class PlanetScanScreen extends StatefulWidget {
  const PlanetScanScreen({super.key});

  @override
  State<PlanetScanScreen> createState() => _PlanetScanScreenState();
}

class _PlanetScanScreenState extends State<PlanetScanScreen> {
  bool _isLoading = false;
  PlanetPredictionResponse? _lastResult;
  bool _showDetails = false;
  Map<String, dynamic> starInfo = {};
  Map<String, dynamic> derivedFeatures = {};
  Map<String, dynamic> simulationData = {};
  Map<String, dynamic> comparisonData = {};

  // Multiple sample datasets for different planets
  final List<Map<String, double>> _planetDatasets = [
    {
      'period': 15.2,
      'duration': 3.1,
      'depth': 1800.0,
      'ror': 0.04,
      'prad': 1.5,
      'srad': 0.9,
      'srho': 1.3,
      'kepmag': 11.8,
      'model_snr': 20.5,
      'insol': 850.0,
      'teq': 1550.0,
    },
    {
      'period': 8.5,
      'duration': 2.8,
      'depth': 1200.0,
      'ror': 0.03,
      'prad': 1.2,
      'srad': 0.8,
      'srho': 1.1,
      'kepmag': 12.5,
      'model_snr': 18.2,
      'insol': 920.0,
      'teq': 1420.0,
    },
    {
      'period': 22.1,
      'duration': 4.2,
      'depth': 2100.0,
      'ror': 0.05,
      'prad': 1.8,
      'srad': 1.1,
      'srho': 1.4,
      'kepmag': 10.9,
      'model_snr': 25.1,
      'insol': 780.0,
      'teq': 1680.0,
    },
    {
      'period': 6.3,
      'duration': 1.9,
      'depth': 850.0,
      'ror': 0.025,
      'prad': 0.9,
      'srad': 0.7,
      'srho': 1.0,
      'kepmag': 13.2,
      'model_snr': 15.8,
      'insol': 1100.0,
      'teq': 1250.0,
    },
    {
      'period': 35.7,
      'duration': 5.8,
      'depth': 3200.0,
      'ror': 0.08,
      'prad': 2.3,
      'srad': 1.3,
      'srho': 1.6,
      'kepmag': 9.8,
      'model_snr': 32.4,
      'insol': 650.0,
      'teq': 1850.0,
    },
  ];

  Map<String, double> _currentData = {};

  @override
  void initState() {
    super.initState();
    _selectRandomDataset();
  }

  void _selectRandomDataset() {
    final random = DateTime.now().millisecondsSinceEpoch % _planetDatasets.length;
    setState(() {
      _currentData = _planetDatasets[random];
    });
  }

  List<Map<String, dynamic>> _generateLightCurveData() {
    final List<Map<String, dynamic>> data = [];
    final period = _currentData['period'] ?? 10.0;
    final depth = _currentData['depth'] ?? 1000.0;
    
    for (int i = 0; i < 100; i++) {
      final time = (i / 100.0) * period * 2;
      double brightness = 1.0;
      
      // Transit simülasyonu
      if ((time % period).abs() < 0.1 * period) {
        final transitProgress = ((time % period).abs() / (0.1 * period));
        brightness = 1.0 - (depth / 10000.0) * (1.0 - transitProgress);
      }
      
      data.add({
        'time': time,
        'brightness': brightness,
      });
    }
    
    return data;
  }

  Future<void> _scanForPlanet() async {
    // Select a new random dataset for each scan
    _selectRandomDataset();
    
    setState(() {
      _isLoading = true;
      _lastResult = null;
    });

    try {
      final result = await PlanetApiService.predictPlanet(
        period: _currentData['period']!,
        duration: _currentData['duration']!,
        depth: _currentData['depth']!,
        ror: _currentData['ror']!,
        prad: _currentData['prad']!,
        srad: _currentData['srad']!,
        srho: _currentData['srho']!,
        kepmag: _currentData['kepmag']!,
        modelSnr: _currentData['model_snr']!,
        insol: _currentData['insol']!,
        teq: _currentData['teq']!,
      );

      setState(() {
        _lastResult = result;
        _isLoading = false;
        _showDetails = true;
        // Yıldız bilgisini simüle et (gerçek API'den gelecek)
        starInfo = {
          'type': 'G-tipi Ana Dizi Yıldızı',
          'mass': '1.2 Güneş Kütlesi',
          'age': '4.5 Milyar Yıl',
          'brightness': '${_currentData['kepmag']?.toStringAsFixed(1) ?? 'N/A'} Kadir',
          'radius': '1.1 Güneş Yarıçapı',
          'temperature': '${_currentData['teq']?.toStringAsFixed(0) ?? 'N/A'} K',
        };
        
        // Derived features simülasyonu
        derivedFeatures = {
          'in_habitable_zone': _currentData['teq']! > 250 && _currentData['teq']! < 400,
          'habitable_zone_inner': 0.8,
          'habitable_zone_outer': 1.5,
          'stellar_luminosity': 0.85,
          'estimated_density': 2.0,
          'orbital_velocity': 45.2,
          'semi_major_axis': 0.12,
        };
        
        // Simulation data simülasyonu
        simulationData = {
          'light_curve': _generateLightCurveData(),
        };
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SpaceBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text(
            'Gezegen Tarayıcı',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textWhite,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: AppTheme.textWhite),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SavedResultsScreen(),
                  ),
                );
              },
              tooltip: 'Kaydedilen Sonuçlar',
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Title and description
                const Text(
                  'Gezegen Tespit Sistemi',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Yıldız verilerini analiz ederek gezegen varlığını tespit edin',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Large scan button
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    gradient: LinearGradient(
                      colors: _isLoading 
                          ? [Colors.grey[600]!, Colors.grey[700]!]
                          : [Colors.blue[600]!, Colors.blue[800]!],
                    ),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _isLoading ? null : _scanForPlanet,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isLoading) ...[
                            const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Analiz ediliyor...',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ] else ...[
                            const Icon(
                              Icons.radar,
                              size: 64,
                              color: Colors.white,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'GEZEGEN TARA',
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tespit başlat',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                // Results display
                if (_lastResult != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getResultColor(_lastResult!.prediction),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _getResultIcon(_lastResult!.prediction),
                              color: _getResultColor(_lastResult!.prediction),
                              size: 32,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _getResultTitle(_lastResult!.prediction),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _lastResult!.message,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Güven Skoru:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              '${(_lastResult!.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: _getConfidenceColor(_lastResult!.confidence),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Gezegen Tipi:',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getPlanetTypeColor(_lastResult!.planetType),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _lastResult!.planetType,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: _lastResult!.confidence,
                          backgroundColor: Colors.grey[700],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getConfidenceColor(_lastResult!.confidence),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Yaşanabilir bölge banner'ı
                        if (derivedFeatures['in_habitable_zone'] == true) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.2),
                              border: Border.all(color: Colors.green),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.eco, color: Colors.green),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "🟢 YAŞANABİLİR BÖLGE! Bu gezegen yaşam için uygun sıcaklık aralığında.",
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                        
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _saveResult();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.star),
                                label: const Text("SONUCU KAYDET"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _shareResult();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.share),
                                label: const Text("PAYLAŞ"),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Yeni özellik butonları
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _compareWithEarth,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.purple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.compare),
                                label: const Text("DÜNYA İLE KARŞILAŞTIR"),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _showLightCurve,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                                icon: const Icon(Icons.show_chart),
                                label: const Text("IŞIK EĞRİSİNİ GÖSTER"),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 12),
                        
                        // Keşif hikayesi butonu
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showDiscoveryStory,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.auto_stories, size: 24),
                            label: const Text(
                              "KEŞİF HİKAYESİNİ GÖR",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Yıldız bilgisi widget'ı
                if (_showDetails && starInfo.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 8),
                              const Text(
                                "⭐ Yıldız Bilgisi",
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildStarInfoRow("Tür", starInfo['type'] ?? "Bilinmiyor"),
                          _buildStarInfoRow("Kütle", starInfo['mass'] ?? "Bilinmiyor"),
                          _buildStarInfoRow("Yaş", starInfo['age'] ?? "Bilinmiyor"),
                          _buildStarInfoRow("Parlaklık", starInfo['brightness'] ?? "Bilinmiyor"),
                          _buildStarInfoRow("Yarıçap", starInfo['radius'] ?? "Bilinmiyor"),
                          _buildStarInfoRow("Sıcaklık", starInfo['temperature'] ?? "Bilinmiyor"),
                        ],
                      ),
                    ),
                  ),
                ],

                // Derived features bilgileri
                if (_showDetails && derivedFeatures.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.grey[900],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.analytics, color: Colors.cyan),
                              const SizedBox(width: 8),
                              const Text(
                                "🔬 Detaylı Analiz",
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildStarInfoRow("Yıldız Aydınlatma Gücü", "${derivedFeatures['stellar_luminosity']?.toStringAsFixed(2) ?? 'N/A'} L☉"),
                          _buildStarInfoRow("Tahmini Yoğunluk", "${derivedFeatures['estimated_density']?.toStringAsFixed(1) ?? 'N/A'} g/cm³"),
                          _buildStarInfoRow("Yörünge Hızı", "${derivedFeatures['orbital_velocity']?.toStringAsFixed(1) ?? 'N/A'} km/s"),
                          _buildStarInfoRow("Yarı-Büyük Eksen", "${derivedFeatures['semi_major_axis']?.toStringAsFixed(2) ?? 'N/A'} AU"),
                          if (derivedFeatures['in_habitable_zone'] == true) ...[
                            _buildStarInfoRow("Yaşanabilir Bölge İç", "${derivedFeatures['habitable_zone_inner']?.toStringAsFixed(2) ?? 'N/A'} AU"),
                            _buildStarInfoRow("Yaşanabilir Bölge Dış", "${derivedFeatures['habitable_zone_outer']?.toStringAsFixed(2) ?? 'N/A'} AU"),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 48),

                // Current data info
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mevcut Veri Parametreleri:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Periyot: ${_currentData['period']?.toStringAsFixed(1) ?? 'N/A'} gün | '
                        'Süre: ${_currentData['duration']?.toStringAsFixed(1) ?? 'N/A'} saat | '
                        'Derinlik: ${_currentData['depth']?.toStringAsFixed(0) ?? 'N/A'} ppm',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sıcaklık: ${_currentData['teq']?.toStringAsFixed(0) ?? 'N/A'}K | '
                        'SNR: ${_currentData['model_snr']?.toStringAsFixed(1) ?? 'N/A'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getResultColor(String prediction) {
    switch (prediction.toUpperCase()) {
      case 'CONFIRMED_PLANET':
        return Colors.green;
      case 'CANDIDATE':
        return Colors.orange;
      case 'FALSE_POSITIVE':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getResultIcon(String prediction) {
    switch (prediction.toUpperCase()) {
      case 'CONFIRMED_PLANET':
        return Icons.public;
      case 'CANDIDATE':
        return Icons.visibility;
      case 'FALSE_POSITIVE':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  String _getResultTitle(String prediction) {
    switch (prediction.toUpperCase()) {
      case 'CONFIRMED_PLANET':
        return 'Gezegen Tespit Edildi!';
      case 'CANDIDATE':
        return 'Aday Gezegen';
      case 'FALSE_POSITIVE':
        return 'Yanlış Pozitif';
      default:
        return 'Bilinmeyen Sonuç';
    }
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.7) return Colors.green;
    if (confidence >= 0.4) return Colors.orange;
    return Colors.red;
  }

  void _saveResult() async {
    if (_lastResult == null) return;
    
    try {
      final savedResult = SavedResult(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        timestamp: DateTime.now(),
        prediction: _lastResult!.prediction,
        confidence: _lastResult!.confidence,
        planetType: _lastResult!.planetType,
        message: _lastResult!.message,
        starInfo: starInfo,
        planetData: _currentData,
      );
      
      await StorageService.saveResult(savedResult);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("✅ Sonuç kaydedildi!"),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("❌ Kaydetme hatası: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _shareResult() async {
    try {
      String shareText = """
🪐 GEZEGEN KEŞİF SONUCU 🪐

✅ Gezegen Tespit Edildi!
Güven Skoru: %${(_lastResult!.confidence * 100).toStringAsFixed(1)}
Gezegen Tipi: ${_lastResult!.planetType}

⭐ Yıldız Bilgisi:
• Tür: ${starInfo['type'] ?? "Bilinmiyor"}
• Kütle: ${starInfo['mass'] ?? "Bilinmiyor"} 
• Yaş: ${starInfo['age'] ?? "Bilinmiyor"}

📊 Gezegen Verileri:
• Yörünge: ${_currentData['period']} gün
• Sıcaklık: ${_currentData['teq']} K
• Yarıçap: ${_currentData['prad']} Dünya

Keşif: Gezegen Avcısı Uygulaması 🌌
      """;
      
      await Share.share(
        shareText,
        subject: 'Gezegen Keşif Sonucu',
      );
      
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("❌ Paylaşım hatası: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildStarInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[400],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dünya ile karşılaştırma
  Future<void> _compareWithEarth() async {
    try {
      setState(() => _isLoading = true);
      
      // Simülasyon verisi oluştur (API yerine)
      final simulatedComparison = _generateSimulatedComparison();
      
      setState(() {
        comparisonData = simulatedComparison;
        _isLoading = false;
      });
      
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ComparisonScreen(comparisonData: simulatedComparison),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Karşılaştırma hatası: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Simülasyon karşılaştırma verisi oluştur
  Map<String, dynamic> _generateSimulatedComparison() {
    final prad = _currentData['prad'] ?? 1.0;
    final period = _currentData['period'] ?? 365.0;
    final teq = _currentData['teq'] ?? 288.0;
    final srad = _currentData['srad'] ?? 1.0;
    
    final result = {
      'size_comparison': '${(prad).toStringAsFixed(1)}x Dünya ${_getSizeCategory(prad)}',
      'orbit_comparison': '${(period / 365.0).toStringAsFixed(2)}x Dünya yılı',
      'temperature_comparison': '${(teq / 288.0).toStringAsFixed(1)}x Dünya sıcaklığı',
      'mass_comparison': '${(prad * 1.2).toStringAsFixed(1)}x Dünya kütlesi',
      'detailed_comparison': {
        'Yarıçap Oranı': '${prad.toStringAsFixed(2)} Dünya yarıçapı',
        'Yörünge Periyodu': '${period.toStringAsFixed(1)} gün',
        'Yüzey Sıcaklığı': '${teq.toStringAsFixed(0)} K',
        'Yıldız Yarıçapı': '${srad.toStringAsFixed(2)} Güneş yarıçapı',
        'Gravitasyonel İvme': '${(prad * 9.8).toStringAsFixed(1)} m/s²',
        'Kaçış Hızı': '${(prad * 11.2).toStringAsFixed(1)} km/s',
      },
      'summary': _generateComparisonSummary(prad, period, teq),
    };
    
    return result;
  }

  String _getSizeCategory(double prad) {
    if (prad < 1.25) return '(Dünya-benzeri)';
    if (prad < 2.0) return '(Süper-Dünya)';
    if (prad < 4.0) return '(Mini-Neptün)';
    return '(Gaz Devi)';
  }

  String _generateComparisonSummary(double prad, double period, double teq) {
    final sizeCategory = _getSizeCategory(prad);
    final tempCategory = teq > 400 ? 'Çok sıcak' : teq < 200 ? 'Çok soğuk' : 'Uygun sıcaklık';
    final orbitCategory = period < 10 ? 'Çok yakın yörünge' : period > 1000 ? 'Çok uzak yörünge' : 'Normal yörünge';
    
    return 'Bu gezegen $sizeCategory kategorisinde yer alıyor. $tempCategory ve $orbitCategory özelliklerine sahip. ${teq > 250 && teq < 400 ? 'Yaşanabilir bölge potansiyeli var.' : 'Yaşanabilir bölge dışında.'}';
  }

  // Işık eğrisini göster
  void _showLightCurve() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LightCurveScreen(
          lightCurveData: simulationData['light_curve'] ?? [],
        ),
      ),
    );
  }

  // Keşif hikayesini göster
  void _showDiscoveryStory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DiscoveryStoryScreen(
          planetData: _currentData,
          starInfo: starInfo,
          confidence: _lastResult?.confidence ?? 0.0,
          planetType: _lastResult?.planetType ?? 'Bilinmiyor',
        ),
      ),
    );
  }

  // Gezegen tipi rengi
  Color _getPlanetTypeColor(String planetType) {
    switch (planetType.toLowerCase()) {
      case 'kayalık gezegen':
        return Colors.brown;
      case 'mini-neptün':
        return Colors.blue;
      case 'gaz devi':
        return Colors.orange;
      case 'buz gezegeni':
        return Colors.cyan;
      case 'yaşanabilir bölge':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
