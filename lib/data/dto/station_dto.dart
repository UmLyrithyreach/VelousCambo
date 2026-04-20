import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';

class StationDto {
  static StationModel fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StationModel(
      id: doc.id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      lat: (data['lat'] as num).toDouble(),
      lng: (data['lng'] as num).toDouble(),
      totalDocks: (data['totalDocks'] as num?)?.toInt() ?? 0,
      availableBikes: (data['availableBikes'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, dynamic> toFirestore(StationModel station) => {
        'name': station.name,
        'address': station.address,
        'lat': station.lat,
        'lng': station.lng,
        'totalDocks': station.totalDocks,
        'availableBikes': station.availableBikes,
      };
}
