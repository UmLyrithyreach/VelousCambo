import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/data/services/firestore_service.dart';

class StationRepository {
  final FirestoreService _firestore;

  StationRepository() : _firestore = FirestoreService();

  Stream<List<StationModel>> watchStations() => _firestore.getStations();

  Stream<List<BikeModel>> watchBikesForStation(String stationId) =>
      _firestore.getBikesForStation(stationId);
}
