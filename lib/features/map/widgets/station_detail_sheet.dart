import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/features/map/viewmodel/station_viewmodel.dart';

class StationDetailSheet extends StatelessWidget {
  const StationDetailSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StationViewModel>();
    final station = sp.selectedStation;
    final bikes = sp.selectedStationBikes;

    if (station == null) return const SizedBox.shrink();

    return DraggableScrollableSheet(
      initialChildSize: 0.48,
      minChildSize: 0.3,
      maxChildSize: 0.88,
      builder: (ctx, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 8),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Station header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: _StationHeader(station: station),
            ),

            const Divider(height: 1),

            // Bike list
            Expanded(
              child: bikes.isEmpty
                  ? const _EmptyBikes()
                  : ListView.separated(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: bikes.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (ctx, i) => _BikeCard(
                        bike: bikes[i],
                        station: station,
                      ).animate().fadeIn(delay: (i * 60).ms).slideX(begin: 0.05),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Station Header ───────────────────────────────────────────────────────────

class _StationHeader extends StatelessWidget {
  final StationModel station;
  const _StationHeader({required this.station});

  @override
  Widget build(BuildContext context) {
    final available = station.availableBikes;
    final isGood = available > 3;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primarySurface,
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.location_on_rounded,
              color: AppColors.primary, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                station.name,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                station.address,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textMedium,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isGood ? AppColors.availableLight : AppColors.rentedLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pedal_bike_rounded,
                size: 14,
                color: isGood ? AppColors.available : AppColors.rented,
              ),
              const SizedBox(width: 4),
              Text(
                '$available',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: isGood ? AppColors.available : AppColors.rented,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Bike Card ────────────────────────────────────────────────────────────────

class _BikeCard extends StatelessWidget {
  final BikeModel bike;
  final StationModel station;

  const _BikeCard({required this.bike, required this.station});

  @override
  Widget build(BuildContext context) {
    final isAvailable = bike.isAvailable;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isAvailable
                  ? AppColors.availableLight
                  : AppColors.divider,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.pedal_bike_rounded,
              size: 22,
              color: isAvailable ? AppColors.available : AppColors.textLight,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bike #${bike.code}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _StarRating(rating: bike.condition),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: isAvailable
                            ? AppColors.availableLight
                            : AppColors.divider,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isAvailable ? 'Available' : bike.status,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isAvailable
                              ? AppColors.available
                              : AppColors.textLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isAvailable)
            GestureDetector(
              onTap: () => _onBook(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 9),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onBook(BuildContext context) {
    Navigator.pop(context);
    Navigator.pushNamed(
      context,
      '/booking',
      arguments: {'bike': bike, 'station': station},
    );
  }
}

// ─── Star Rating ──────────────────────────────────────────────────────────────

class _StarRating extends StatelessWidget {
  final double rating;
  const _StarRating({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        return Icon(
          i < rating.floor()
              ? Icons.star_rounded
              : (i < rating
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded),
          size: 13,
          color: const Color(0xFFFFC107),
        );
      }),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyBikes extends StatelessWidget {
  const _EmptyBikes();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.pedal_bike_rounded,
                color: AppColors.textLight, size: 30),
          ),
          const SizedBox(height: 14),
          const Text(
            'No bikes available',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Check back later or try another station',
            style: TextStyle(fontSize: 13, color: AppColors.textMedium),
          ),
        ],
      ),
    );
  }
}
