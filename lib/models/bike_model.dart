class BikeModel {
  final String id;
  final String stationId;
  final String code;
  final String status; // 'available' | 'rented' | 'maintenance'
  final double condition; // 1.0 - 5.0

  const BikeModel({
    required this.id,
    required this.stationId,
    required this.code,
    required this.status,
    required this.condition,
  });

  bool get isAvailable => status == 'available';
}
