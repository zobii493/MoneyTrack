enum TransactionType { expense, income, transfer }

class TransactionModel {
  final String id;
  final String userId;
  final TransactionType type;
  final double amount;
  final String currency;
  final String categoryId;
  final String accountId;
  final String? toAccountId;
  final String title;
  final String description;
  final DateTime date;
  final String paymentMethod;
  final String? notes;
  final String? receiptUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  TransactionModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.categoryId,
    required this.accountId,
    this.toAccountId,
    required this.title,
    this.description = '',
    required this.date,
    required this.paymentMethod,
    this.notes,
    this.receiptUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'amount': amount,
      'currency': currency,
      'categoryId': categoryId,
      'accountId': accountId,
      'toAccountId': toAccountId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod,
      'notes': notes,
      'receiptUrl': receiptUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String,
      userId: json['userId'] as String? ?? 'user_1',
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      categoryId: json['categoryId'] as String? ?? 'other',
      accountId: json['accountId'] as String? ?? 'acc_1',
      toAccountId: json['toAccountId'] as String?,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      paymentMethod: json['paymentMethod'] as String? ?? 'Card',
      notes: json['notes'] as String?,
      receiptUrl: json['receiptUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  TransactionModel copyWith({
    String? id,
    String? userId,
    TransactionType? type,
    double? amount,
    String? currency,
    String? categoryId,
    String? accountId,
    String? toAccountId,
    String? title,
    String? description,
    DateTime? date,
    String? paymentMethod,
    String? notes,
    String? receiptUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      toAccountId: toAccountId ?? this.toAccountId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
