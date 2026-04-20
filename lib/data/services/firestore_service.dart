import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/user_model.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/data/dto/station_dto.dart';
import 'package:velouscambo_enhanced_new/data/dto/bike_dto.dart';
import 'package:velouscambo_enhanced_new/data/dto/user_dto.dart';
import 'package:velouscambo_enhanced_new/data/dto/rental_dto.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ─── Stations ────────────────────────────────────────────────────────────

  Stream<List<StationModel>> getStations() {
    return _db.collection('stations').snapshots().map(
          (snap) => snap.docs.map(StationDto.fromFirestore).toList(),
        );
  }

  Stream<List<BikeModel>> getBikesForStation(String stationId) {
    return _db
        .collection('bikes')
        .where('stationId', isEqualTo: stationId)
        .snapshots()
        .map((snap) => snap.docs.map(BikeDto.fromFirestore).toList());
  }

  // ─── User ─────────────────────────────────────────────────────────────────

  Future<void> createUser(String uid, String name, String email) async {
    await _db.collection('users').doc(uid).set({
      'name': name,
      'email': email,
      'photoUrl': null,
      'plan': 'monthly',
      'planExpiry': Timestamp.fromDate(
        DateTime.now().add(const Duration(days: 30)),
      ),
    });
  }

  Stream<UserModel?> getUser(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserDto.fromFirestore(doc) : null);
  }

  Future<bool> userProfileExists(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.exists;
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _db.collection('users').doc(uid).update(data);
  }

  // ─── Rentals ──────────────────────────────────────────────────────────────

  Future<RentalModel> startRental({
    required String userId,
    required BikeModel bike,
    required StationModel station,
  }) async {
    final batch = _db.batch();

    final rentalRef = _db.collection('rentals').doc();
    final rentalData = {
      'userId': userId,
      'bikeId': bike.id,
      'bikeCode': bike.code,
      'stationId': station.id,
      'stationName': station.name,
      'startTime': FieldValue.serverTimestamp(),
      'endTime': null,
      'durationMinutes': null,
      'status': 'active',
    };
    batch.set(rentalRef, rentalData);

    batch.update(_db.collection('bikes').doc(bike.id), {'status': 'rented'});
    batch.update(
      _db.collection('stations').doc(station.id),
      {'availableBikes': FieldValue.increment(-1)},
    );

    await batch.commit();

    final snap = await rentalRef.get();
    return RentalDto.fromFirestore(snap);
  }

  Future<void> endRental({
    required String rentalId,
    required String bikeId,
    required String stationId,
    required DateTime startTime,
  }) async {
    final now = DateTime.now();
    final duration = now.difference(startTime).inMinutes;
    final batch = _db.batch();

    batch.update(_db.collection('rentals').doc(rentalId), {
      'endTime': Timestamp.fromDate(now),
      'durationMinutes': duration,
      'status': 'completed',
    });
    batch.update(_db.collection('bikes').doc(bikeId), {'status': 'available'});
    batch.update(
      _db.collection('stations').doc(stationId),
      {'availableBikes': FieldValue.increment(1)},
    );

    await batch.commit();
  }

  Stream<RentalModel?> getActiveRental(String userId) {
    return _db
        .collection('rentals')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots()
        .map((snap) =>
            snap.docs.isEmpty ? null : RentalDto.fromFirestore(snap.docs.first));
  }

  Stream<List<RentalModel>> getRentalHistory(String userId) {
    return _db
        .collection('rentals')
        .where('userId', isEqualTo: userId)
        .where('status', isEqualTo: 'completed')
        .orderBy('startTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(RentalDto.fromFirestore).toList());
  }

  // ─── Seed Demo Data ───────────────────────────────────────────────────────

  Future<void> seedDemoData() async {
    final stationsSnap = await _db.collection('stations').limit(1).get();
    if (stationsSnap.docs.isNotEmpty) return; // already seeded

    const stations = [
      {
        'id': 'station_watphnom',
        'name': 'Wat Phnom Station',
        'address': 'Wat Phnom, Daun Penh, Phnom Penh',
        'lat': 11.5748,
        'lng': 104.9210,
        'totalDocks': 10,
        'availableBikes': 6,
      },
      {
        'id': 'station_riverside',
        'name': 'Riverside Station',
        'address': 'Sisowath Quay, Daun Penh, Phnom Penh',
        'lat': 11.5684,
        'lng': 104.9283,
        'totalDocks': 12,
        'availableBikes': 8,
      },
      {
        'id': 'station_central',
        'name': 'Central Market Station',
        'address': 'Phsar Thmei, Daun Penh, Phnom Penh',
        'lat': 11.5688,
        'lng': 104.9176,
        'totalDocks': 8,
        'availableBikes': 4,
      },
      {
        'id': 'station_independence',
        'name': 'Independence Monument',
        'address': 'Norodom Blvd, Chamkarmon, Phnom Penh',
        'lat': 11.5540,
        'lng': 104.9246,
        'totalDocks': 10,
        'availableBikes': 3,
      },
      {
        'id': 'station_olympic',
        'name': 'Olympic Stadium',
        'address': 'Street 217, Chamkarmon, Phnom Penh',
        'lat': 11.5501,
        'lng': 104.9212,
        'totalDocks': 15,
        'availableBikes': 10,
      },
      {
        'id': 'station_royalpalace',
        'name': 'Royal Palace Station',
        'address': 'Samdech Sothearos Blvd, Phnom Penh',
        'lat': 11.5629,
        'lng': 104.9307,
        'totalDocks': 8,
        'availableBikes': 5,
      },
      {
        'id': 'station_russianmarket',
        'name': 'Russian Market Station',
        'address': 'Phsar Toul Tom Poung, Phnom Penh',
        'lat': 11.5459,
        'lng': 104.9197,
        'totalDocks': 10,
        'availableBikes': 7,
      },
    ];

    final batch = _db.batch();

    for (final s in stations) {
      final stationId = s['id'] as String;
      final ref = _db.collection('stations').doc(stationId);
      batch.set(ref, {
        'name': s['name'],
        'address': s['address'],
        'lat': s['lat'],
        'lng': s['lng'],
        'totalDocks': s['totalDocks'],
        'availableBikes': s['availableBikes'],
      });

      final bikeCount = s['availableBikes'] as int;
      for (int i = 1; i <= bikeCount; i++) {
        final bikeRef = _db.collection('bikes').doc('${stationId}_bike$i');
        batch.set(bikeRef, {
          'stationId': stationId,
          'code': 'B${stationId.substring(8, 11).toUpperCase()}${i.toString().padLeft(2, '0')}',
          'status': 'available',
          'condition': (4.0 + (i % 2) * 0.5),
        });
      }
    }

    await batch.commit();
  }
}
