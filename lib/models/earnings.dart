// lib/models/earnings.dart
class Earnings {
  final String priceDate;
  final String ticker;
  final double? actualEps; // Make these nullable
  final double? estimatedEps;
  final double? actualRevenue;
  final double? estimatedRevenue;

  Earnings({
    required this.priceDate,
    required this.ticker,
    this.actualEps, // Nullable
    this.estimatedEps, // Nullable
    this.actualRevenue, // Nullable
    this.estimatedRevenue, // Nullable
  });

  // Factory method to create an Earnings object from JSON
  factory Earnings.fromJson(Map<String, dynamic> json) {
    return Earnings(
      priceDate: json['pricedate'],
      ticker: json['ticker'],
      actualEps: json['actual_eps'] != null ? json['actual_eps'].toDouble() : null,
      estimatedEps: json['estimated_eps'] != null ? json['estimated_eps'].toDouble() : null,
      actualRevenue: json['actual_revenue'] != null ? json['actual_revenue'].toDouble() : null,
      estimatedRevenue: json['estimated_revenue'] != null ? json['estimated_revenue'].toDouble() : null,
    );
  }

  // Method to convert Earnings object to JSON
  Map<String, dynamic> toJson() {
    return {
      'pricedate': priceDate,
      'ticker': ticker,
      'actual_eps': actualEps,
      'estimated_eps': estimatedEps,
      'actual_revenue': actualRevenue,
      'estimated_revenue': estimatedRevenue,
    };
  }
}