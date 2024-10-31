class TranscriptModel {
  final String content;
  final String quarter;
  final String year;
  final String ticker;

  TranscriptModel({
    required this.content,
    required this.quarter,
    required this.year,
    required this.ticker,
  });

  factory TranscriptModel.fromJson(Map<String, dynamic> json) {
    return TranscriptModel(
      content: json['transcript'] ?? 'No transcript available',
      quarter: json['quarter']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      ticker: json['ticker'] ?? '',
    );
  }
}