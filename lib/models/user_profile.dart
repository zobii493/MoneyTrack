class UserProfile {
  final String id;
  final String name;
  final String email;
  final String currency;
  final String primaryGoal;
  final String? avatarUrl;
  final bool notificationsEnabled;
  final Map<String, bool> dashboardWidgets;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.currency = 'USD',
    this.primaryGoal = 'Track spending',
    this.avatarUrl,
    this.notificationsEnabled = true,
    Map<String, bool>? dashboardWidgets,
  }) : dashboardWidgets = dashboardWidgets ?? {
          'balance': true,
          'summary': true,
          'spending_chart': true,
          'expense_breakdown': true,
          'recent_transactions': true,
          'budgets': true,
          'goals': true,
        };

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'currency': currency,
      'primaryGoal': primaryGoal,
      'avatarUrl': avatarUrl,
      'notificationsEnabled': notificationsEnabled,
      'dashboardWidgets': dashboardWidgets,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      currency: json['currency'] as String? ?? 'USD',
      primaryGoal: json['primaryGoal'] as String? ?? 'Track spending',
      avatarUrl: json['avatarUrl'] as String?,
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      dashboardWidgets: json['dashboardWidgets'] != null
          ? Map<String, bool>.from(json['dashboardWidgets'] as Map)
          : null,
    );
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? email,
    String? currency,
    String? primaryGoal,
    String? avatarUrl,
    bool? notificationsEnabled,
    Map<String, bool>? dashboardWidgets,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      currency: currency ?? this.currency,
      primaryGoal: primaryGoal ?? this.primaryGoal,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dashboardWidgets: dashboardWidgets ?? this.dashboardWidgets,
    );
  }
}
