class StarData {
  final String id;
  final String name;
  final double brightness;
  final DateTime timestamp;
  final List<double> lightCurve;
  final String? analysis;
  final bool hasTransit;

  StarData({
    required this.id,
    required this.name,
    required this.brightness,
    required this.timestamp,
    required this.lightCurve,
    this.analysis,
    this.hasTransit = false,
  });

  StarData copyWith({
    String? id,
    String? name,
    double? brightness,
    DateTime? timestamp,
    List<double>? lightCurve,
    String? analysis,
    bool? hasTransit,
  }) {
    return StarData(
      id: id ?? this.id,
      name: name ?? this.name,
      brightness: brightness ?? this.brightness,
      timestamp: timestamp ?? this.timestamp,
      lightCurve: lightCurve ?? this.lightCurve,
      analysis: analysis ?? this.analysis,
      hasTransit: hasTransit ?? this.hasTransit,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brightness': brightness,
      'timestamp': timestamp.toIso8601String(),
      'lightCurve': lightCurve,
      'analysis': analysis,
      'hasTransit': hasTransit,
    };
  }

  factory StarData.fromJson(Map<String, dynamic> json) {
    return StarData(
      id: json['id'],
      name: json['name'],
      brightness: json['brightness'].toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      lightCurve: List<double>.from(json['lightCurve']),
      analysis: json['analysis'],
      hasTransit: json['hasTransit'] ?? false,
    );
  }
}