class SavedResult {
  final String id;
  final DateTime timestamp;
  final String prediction;
  final double confidence;
  final String planetType;
  final String message;
  final Map<String, dynamic> starInfo;
  final Map<String, double> planetData;

  SavedResult({
    required this.id,
    required this.timestamp,
    required this.prediction,
    required this.confidence,
    required this.planetType,
    required this.message,
    required this.starInfo,
    required this.planetData,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'prediction': prediction,
      'confidence': confidence,
      'planetType': planetType,
      'message': message,
      'starInfo': starInfo,
      'planetData': planetData,
    };
  }

  factory SavedResult.fromJson(Map<String, dynamic> json) {
    return SavedResult(
      id: json['id'],
      timestamp: DateTime.parse(json['timestamp']),
      prediction: json['prediction'],
      confidence: json['confidence'].toDouble(),
      planetType: json['planetType'],
      message: json['message'],
      starInfo: Map<String, dynamic>.from(json['starInfo']),
      planetData: Map<String, double>.from(json['planetData']),
    );
  }
}

