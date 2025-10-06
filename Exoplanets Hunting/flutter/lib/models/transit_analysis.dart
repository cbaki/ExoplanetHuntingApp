class TransitAnalysis {
  final String id;
  final String starId;
  final DateTime detectedAt;
  final double depth;
  final double duration;
  final double period;
  final String objectType;
  final double confidence;
  final String? notes;

  TransitAnalysis({
    required this.id,
    required this.starId,
    required this.detectedAt,
    required this.depth,
    required this.duration,
    required this.period,
    required this.objectType,
    required this.confidence,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'starId': starId,
      'detectedAt': detectedAt.toIso8601String(),
      'depth': depth,
      'duration': duration,
      'period': period,
      'objectType': objectType,
      'confidence': confidence,
      'notes': notes,
    };
  }

  factory TransitAnalysis.fromJson(Map<String, dynamic> json) {
    return TransitAnalysis(
      id: json['id'],
      starId: json['starId'],
      detectedAt: DateTime.parse(json['detectedAt']),
      depth: json['depth'].toDouble(),
      duration: json['duration'].toDouble(),
      period: json['period'].toDouble(),
      objectType: json['objectType'],
      confidence: json['confidence'].toDouble(),
      notes: json['notes'],
    );
  }
}