import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/data/services/firestore_service.dart';

class RentalRepository {
  final FirestoreService _firestore;

  RentalRepository() : _firestore = FirestoreService();

  Stream<RentalModel?> watchActiveRental(String userId) =>
      _firestore.getActiveRental(userId);

  Stream<List<RentalModel>> watchRentalHistory(String userId) =>
      _firestore.getRentalHistory(userId);

  Future<RentalModel> startRental({
    required String userId,
    required BikeModel bike,
    required StationModel station,
  }) =>
      _firestore.startRental(userId: userId, bike: bike, station: station);

  Future<void> endRental({
    required String rentalId,
    required String bikeId,
    required String stationId,
    required DateTime startTime,
  }) =>
      _firestore.endRental(
        rentalId: rentalId,
        bikeId: bikeId,
        stationId: stationId,
        startTime: startTime,
      );
}
