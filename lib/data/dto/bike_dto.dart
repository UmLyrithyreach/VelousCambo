import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';

class BikeDto {
  static BikeModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BikeModel(
      id: doc.id,
      stationId: data['stationId'] ?? '',
      code: data['code'] ?? '',
      status: data['status'] ?? 'available',
      condition: (data['condition'] as num?)?.toDouble() ?? 5.0,
    );
  }

  static Map<String, dynamic> toFirestore(BikeModel bike) => {
        'stationId': bike.stationId,
        'code': bike.code,
        'status': bike.status,
        'condition': bike.condition,
      };
}
