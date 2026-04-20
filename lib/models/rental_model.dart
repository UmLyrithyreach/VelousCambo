class RentalModel {
  final String id;
  final String userId;
  final String bikeId;
  final String bikeCode;
  final String stationId;
  final String stationName;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationMinutes;
  final String status; // 'active' | 'completed'

  const RentalModel({
    required this.id,
    required this.userId,
    required this.bikeId,
    required this.bikeCode,
    required this.stationId,
    required this.stationName,
    required this.startTime,
    this.endTime,
    this.durationMinutes,
    required this.status,
  });

  bool get isActive => status == 'active';

  Duration get elapsed => DateTime.now().difference(startTime);

  String get elapsedFormatted {
    final d = elapsed;
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m.toString().padLeft(2, '0')}m';
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
}
