enum AiReportSource { direct, fallback }

class AiReport {
  const AiReport({
    required this.id,
    required this.summary,
    required this.changePoints,
    required this.recommendations,
    required this.generatedAt,
    required this.source,
  });

  final String id;
  final String summary;
  final List<String> changePoints;
  final List<String> recommendations;
  final DateTime generatedAt;
  final AiReportSource source;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'summary': summary,
      'changePoints': changePoints,
      'recommendations': recommendations,
      'generatedAt': generatedAt.toIso8601String(),
      'source': source.name,
    };
  }

  factory AiReport.fromJson(Map<String, dynamic> json) {
    return AiReport(
      id: json['id'] as String,
      summary: json['summary'] as String,
      changePoints: List<String>.from(json['changePoints'] as List<dynamic>),
      recommendations: List<String>.from(json['recommendations'] as List<dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      source: AiReportSource.values.byName(json['source'] as String),
    );
  }
}
