class Discount {
  final double percentage;
  final DateTime expiresAt;

  Discount({
    required this.percentage,
    required this.expiresAt,
  });

  factory Discount.fromJson(Map<String, dynamic> json) {
    return Discount(
      percentage: (json['percentage'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expiresAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'percentage': percentage,
      'expiresAt': expiresAt.toIso8601String(),
    };
  }

  bool get isActive => DateTime.now().isBefore(expiresAt);
}
