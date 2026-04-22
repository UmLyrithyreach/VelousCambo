import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velouscambo_enhanced_new/models/user_model.dart';

class UserDto {
  static UserModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    DateTime? expiry;
    if (data['planExpiry'] is Timestamp) {
      expiry = (data['planExpiry'] as Timestamp).toDate();
    } else if (data['planExpiry'] is String) {
      expiry = DateTime.tryParse(data['planExpiry'] as String);
    }

    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      plan: data['plan'] ?? 'none',
      planExpiry: expiry,
    );
  }

  static Map<String, dynamic> toFirestore(UserModel user) => {
        'name': user.name,
        'email': user.email,
        'photoUrl': user.photoUrl,
        'plan': user.plan,
        'planExpiry':
            user.planExpiry != null ? Timestamp.fromDate(user.planExpiry!) : null,
      };
}
