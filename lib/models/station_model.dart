class StationModel {
  final String id;
  final String name;
  final String address;
  final double lat;
  final double lng;
  final int totalDocks;
  final int availableBikes;

  const StationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.lat,
    required this.lng,
    required this.totalDocks,
    required this.availableBikes,
  });

  StationModel copyWith({int? availableBikes}) => StationModel(
        id: id,
        name: name,
        address: address,
        lat: lat,
        lng: lng,
        totalDocks: totalDocks,
        availableBikes: availableBikes ?? this.availableBikes,
      );
}
