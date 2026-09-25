enum BudgetPeriod { weekly, monthly }

class BudgetModel {
  final String id;
  final String categoryId;
  final double amountLimit;
  final BudgetPeriod period;
  final DateTime startDate;

  BudgetModel({
    required this.id,
    required this.categoryId,
    required this.amountLimit,
    required this.period,
    required this.startDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amountLimit': amountLimit,
      'period': period.name,
      'startDate': startDate.toIso8601String(),
    };
  }

  factory BudgetModel.fromJson(Map<String, dynamic> json) {
    return BudgetModel(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      amountLimit: (json['amountLimit'] as num).toDouble(),
      period: BudgetPeriod.values.firstWhere(
        (e) => e.name == json['period'],
        orElse: () => BudgetPeriod.monthly,
      ),
      startDate: DateTime.parse(json['startDate'] as String),
    );
  }

  BudgetModel copyWith({
    String? id,
    String? categoryId,
    double? amountLimit,
    BudgetPeriod? period,
    DateTime? startDate,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amountLimit: amountLimit ?? this.amountLimit,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
    );
  }
}
