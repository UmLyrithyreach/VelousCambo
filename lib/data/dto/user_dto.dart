import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velouscambo_enhanced_new/models/user_model.dart';

class UserDto {
  static UserModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      photoUrl: data['photoUrl'],
      plan: data['plan'] ?? 'none',
      planExpiry: data['planExpiry'] != null
          ? (data['planExpiry'] as Timestamp).toDate()
          : null,
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
