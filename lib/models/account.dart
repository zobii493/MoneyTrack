enum AccountType { cash, bank, creditCard, savings, digitalWallet }

class AccountModel {
  final String id;
  final String name;
  final AccountType type;
  final double balance;
  final String currency;
  final String? accountNumberMasked;
  final int iconCode;
  final int colorValue;
  final DateTime updatedAt;

  AccountModel({
    required this.id,
    required this.name,
    required this.type,
    required this.balance,
    required this.currency,
    this.accountNumberMasked,
    required this.iconCode,
    required this.colorValue,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'balance': balance,
      'currency': currency,
      'accountNumberMasked': accountNumberMasked,
      'iconCode': iconCode,
      'colorValue': colorValue,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: AccountType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AccountType.bank,
      ),
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      accountNumberMasked: json['accountNumberMasked'] as String?,
      iconCode: json['iconCode'] as int,
      colorValue: json['colorValue'] as int,
      updatedAt: DateTime.parse(json['updatedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  AccountModel copyWith({
    String? id,
    String? name,
    AccountType? type,
    double? balance,
    String? currency,
    String? accountNumberMasked,
    int? iconCode,
    int? colorValue,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      accountNumberMasked: accountNumberMasked ?? this.accountNumberMasked,
      iconCode: iconCode ?? this.iconCode,
      colorValue: colorValue ?? this.colorValue,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
