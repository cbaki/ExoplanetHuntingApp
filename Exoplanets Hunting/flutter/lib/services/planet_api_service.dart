import 'dart:convert';
import 'package:http/http.dart' as http;

class PlanetApiService {
  static const String baseUrl = 'http://172.20.10.2:5000';
  static const String predictEndpoint = '/api/predict';
  static const String comparisonEndpoint = '/api/planet/comparison';
  static const String lightCurveEndpoint = '/api/simulation/light_curve';

  static Future<PlanetPredictionResponse> predictPlanet({
    required double period,
    required double duration,
    required double depth,
    required double ror,
    required double prad,
    required double srad,
    required double srho,
    required double kepmag,
    required double modelSnr,
    required double insol,
    required double teq,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$predictEndpoint');
      
      final requestBody = {
        'period': period,
        'duration': duration,
        'depth': depth,
        'ror': ror,
        'prad': prad,
        'srad': srad,
        'srho': srho,
        'kepmag': kepmag,
        'model_snr': modelSnr,
        'insol': insol,
        'teq': teq,
      };

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Gezegen tipi tahminini ekle
        data['planet_type'] = getPlanetType(requestBody);
        return PlanetPredictionResponse.fromJson(data);
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Dünya ile karşılaştırma
  static Future<Map<String, dynamic>> compareWithEarth(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$comparisonEndpoint');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Comparison API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Comparison network error: $e');
    }
  }

  // Işık eğrisi simülasyonu
  static Future<Map<String, dynamic>> getLightCurveSimulation(Map<String, dynamic> data) async {
    try {
      final url = Uri.parse('$baseUrl$lightCurveEndpoint');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Light curve API failed with status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Light curve network error: $e');
    }
  }
}

class PlanetPredictionResponse {
  final bool success;
  final String prediction;
  final double confidence;
  final String message;
  final String planetType;

  PlanetPredictionResponse({
    required this.success,
    required this.prediction,
    required this.confidence,
    required this.message,
    required this.planetType,
  });

  factory PlanetPredictionResponse.fromJson(Map<String, dynamic> json) {
    return PlanetPredictionResponse(
      success: json['success'] ?? false,
      prediction: json['prediction'] ?? '',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      message: json['message'] ?? '',
      planetType: json['planet_type'] ?? '',
    );
  }
}

// Gezegen tipi tahmini fonksiyonu (Python kodundan Dart'a çevrildi)
String getPlanetType(Map<String, double> data) {
  final prad = data['prad'] ?? 0.0;
  final teq = data['teq'] ?? 0.0;
  
  // Önce sıcaklığa göre kontrol et
  if (teq < 273) {
    return "Buz Gezegeni";
  } else if (teq >= 273 && teq <= 373) {
    return "Yaşanabilir Bölge";
  }
  
  // Sonra yarıçapa göre kontrol et
  if (prad < 1.5) {
    return "Kayalık Gezegen";
  } else if (prad < 6) {
    return "Mini-Neptün";
  } else {
    return "Gaz Devi";
  }
}
