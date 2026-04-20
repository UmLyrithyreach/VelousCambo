class UserModel {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;
  final String plan; // 'none' | 'daily' | 'monthly' | 'annual'
  final DateTime? planExpiry;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
    this.plan = 'none',
    this.planExpiry,
  });

  bool get hasActivePlan =>
      plan != 'none' &&
      planExpiry != null &&
      planExpiry!.isAfter(DateTime.now());

  String get planDisplayName {
    switch (plan) {
      case 'daily':
        return 'Day Pass';
      case 'monthly':
        return 'Monthly';
      case 'annual':
        return 'Annual';
      default:
        return 'No Plan';
    }
  }

  UserModel copyWith({
    String? name,
    String? photoUrl,
    String? plan,
    DateTime? planExpiry,
  }) =>
      UserModel(
        id: id,
        name: name ?? this.name,
        email: email,
        photoUrl: photoUrl ?? this.photoUrl,
        plan: plan ?? this.plan,
        planExpiry: planExpiry ?? this.planExpiry,
      );
}
