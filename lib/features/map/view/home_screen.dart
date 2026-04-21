import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/features/map/viewmodel/station_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/map/widgets/station_detail_sheet.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GoogleMapController? _mapController;
  final Map<String, BitmapDescriptor> _markerCache = {};
  Set<Marker> _markers = {};
  bool _locationLoading = false;
  bool _sheetOpen = false;

  static const _phnomPenh = LatLng(11.5564, 104.9282);

  static const _mapStyle = '''[
    {"featureType":"poi","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"transit","elementType":"labels","stylers":[{"visibility":"off"}]},
    {"featureType":"road","elementType":"geometry","stylers":[{"color":"#f8f8f8"}]},
    {"featureType":"water","elementType":"geometry","stylers":[{"color":"#d4e9f7"}]}
  ]''';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final stations = context.watch<StationViewModel>().stations;
    _buildMarkers(stations);
  }

  Future<void> _buildMarkers(List<StationModel> stations) async {
    final newMarkers = <Marker>{};
    for (final s in stations) {
      final icon = await _getMarkerIcon(s.availableBikes);
      newMarkers.add(Marker(
        markerId: MarkerId(s.id),
        position: LatLng(s.lat, s.lng),
        icon: icon,
        onTap: () => _onStationTap(s),
        infoWindow: InfoWindow(title: s.name),
      ));
    }
    if (mounted) setState(() => _markers = newMarkers);
  }

  Future<BitmapDescriptor> _getMarkerIcon(int count) async {
    final key = 'marker_$count';
    if (_markerCache.containsKey(key)) return _markerCache[key]!;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 56.0;

    // Shadow
    final shadowPaint = Paint()
      ..color = const Color(0x40000000)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    canvas.drawCircle(
        const Offset(size / 2, size / 2 + 3), size / 2 - 4, shadowPaint);

    // Background circle
    final bgPaint = Paint()..color = AppColors.primary;
    canvas.drawCircle(const Offset(size / 2, size / 2), size / 2 - 4, bgPaint);

    // White border
    final borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(
        const Offset(size / 2, size / 2), size / 2 - 4, borderPaint);

    // Count text
    final tp = TextPainter(
      text: TextSpan(
        text: '$count',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset((size - tp.width) / 2, (size - tp.height) / 2));

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final descriptor = BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
    _markerCache[key] = descriptor;
    return descriptor;
  }

  void _onStationTap(StationModel station) {
    // If a sheet is already open, close it first then reopen for the new station
    if (_sheetOpen) {
      Navigator.of(context).pop();
    }

    final sp = context.read<StationViewModel>();
    sp.selectStation(station);
    setState(() => _sheetOpen = true);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ChangeNotifierProvider.value(
        value: sp,
        child: const StationDetailSheet(),
      ),
    ).whenComplete(() {
      sp.clearSelectedStation();
      if (mounted) setState(() => _sheetOpen = false);
    });
  }

  Future<void> _goToMyLocation() async {
    setState(() => _locationLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(pos.latitude, pos.longitude),
            zoom: 15,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeRental = context.watch<StationViewModel>().activeRental;

    return Scaffold(
      body: Stack(
        children: [
          // Map
          GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: _phnomPenh,
              zoom: 14,
            ),
            markers: _markers,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            style: _mapStyle,
            onMapCreated: (ctrl) => _mapController = ctrl,
            onTap: (_) {
              if (_sheetOpen) {
                Navigator.of(context).pop();
              }
            },
          ),

          // Top search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: _SearchBar(
                onTap: () => Navigator.pushNamed(context, '/search')),
          ),

          // Active rental banner
          if (activeRental != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _ActiveRentalBanner(
                bikeCode: activeRental.bikeCode,
                elapsed: activeRental.elapsedFormatted,
                onTap: () => Navigator.pushNamed(context, '/active-rental'),
              ),
            ),

          // Location FAB
          Positioned(
            right: 16,
            bottom: activeRental != null ? 100 : 24,
            child: _LocationFab(
              isLoading: _locationLoading,
              onTap: _goToMyLocation,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  final VoidCallback onTap;
  const _SearchBar({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const Icon(Icons.search_rounded,
                color: AppColors.textLight, size: 22),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Find a station...',
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 15,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 8),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.tune_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Active Rental Banner ────────────────────────────────────────────────────

class _ActiveRentalBanner extends StatefulWidget {
  final String bikeCode;
  final String elapsed;
  final VoidCallback onTap;

  const _ActiveRentalBanner({
    required this.bikeCode,
    required this.elapsed,
    required this.onTap,
  });

  @override
  State<_ActiveRentalBanner> createState() => _ActiveRentalBannerState();
}

class _ActiveRentalBannerState extends State<_ActiveRentalBanner> {
  late Timer _timer;
  late String _elapsed;

  @override
  void initState() {
    super.initState();
    _elapsed = widget.elapsed;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {
          _elapsed =
              context.read<StationViewModel>().activeRental?.elapsedFormatted ??
                  _elapsed;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.35),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pedal_bike_rounded,
                  color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bike ${widget.bikeCode} • Active',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Time: $_elapsed',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'View',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Location FAB ────────────────────────────────────────────────────────────

class _LocationFab extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onTap;

  const _LocationFab({required this.isLoading, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: AppColors.primary),
              )
            : const Icon(Icons.my_location_rounded,
                color: AppColors.primary, size: 22),
      ),
    );
  }
}
