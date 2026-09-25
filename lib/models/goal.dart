class GoalModel {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final String currency;
  final DateTime targetDate;
  final int iconCode;
  final int colorValue;
  final String? notes;
  final DateTime createdAt;

  GoalModel({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.currency,
    required this.targetDate,
    required this.iconCode,
    required this.colorValue,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'currency': currency,
      'targetDate': targetDate.toIso8601String(),
      'iconCode': iconCode,
      'colorValue': colorValue,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory GoalModel.fromJson(Map<String, dynamic> json) {
    return GoalModel(
      id: json['id'] as String,
      title: json['title'] as String,
      targetAmount: (json['targetAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      targetDate: DateTime.parse(json['targetDate'] as String),
      iconCode: json['iconCode'] as int,
      colorValue: json['colorValue'] as int,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  GoalModel copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    String? currency,
    DateTime? targetDate,
    int? iconCode,
    int? colorValue,
    String? notes,
    DateTime? createdAt,
  }) {
    return GoalModel(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      currency: currency ?? this.currency,
      targetDate: targetDate ?? this.targetDate,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
