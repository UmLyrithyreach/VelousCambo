import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';

class RentalDto {
  static RentalModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RentalModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      bikeId: data['bikeId'] ?? '',
      bikeCode: data['bikeCode'] ?? '',
      stationId: data['stationId'] ?? '',
      stationName: data['stationName'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      durationMinutes: data['durationMinutes'],
      status: data['status'] ?? 'active',
    );
  }

  static Map<String, dynamic> toFirestore(RentalModel rental) => {
        'userId': rental.userId,
        'bikeId': rental.bikeId,
        'bikeCode': rental.bikeCode,
        'stationId': rental.stationId,
        'stationName': rental.stationName,
        'startTime': Timestamp.fromDate(rental.startTime),
        'endTime':
            rental.endTime != null ? Timestamp.fromDate(rental.endTime!) : null,
        'durationMinutes': rental.durationMinutes,
        'status': rental.status,
      };
}
