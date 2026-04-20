import 'package:flutter/material.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/icon_box.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/surface_card.dart';

// ─── Bike Detail Card ──────────────────────────────────────────────────────────

class BikeDetailCard extends StatelessWidget {
  final BikeModel bike;
  const BikeDetailCard({super.key, required this.bike});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          const IconBox(
            icon: Icons.pedal_bike_rounded,
            iconColor: AppColors.available,
            backgroundColor: AppColors.availableLight,
            size: 52,
            iconSize: 26,
            radius: 14,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bike #${bike.code}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                StarRow(rating: bike.condition),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.availableLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Available',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.available,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Station Card ──────────────────────────────────────────────────────────────

class StationBookingCard extends StatelessWidget {
  final StationModel station;
  const StationBookingCard({super.key, required this.station});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          const IconBox(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primarySurface,
            size: 52,
            iconSize: 26,
            radius: 14,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  station.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  station.address,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMedium),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan Card ────────────────────────────────────────────────────────────────

class PlanCard extends StatelessWidget {
  final dynamic user;
  const PlanCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return SurfaceCard(
      child: Row(
        children: [
          const IconBox(
            icon: Icons.card_membership_rounded,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primarySurface,
            size: 44,
            iconSize: 22,
            radius: 12,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.planDisplayName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  user.hasActivePlan ? 'Active subscription' : 'No active plan',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMedium),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: user.hasActivePlan
                  ? AppColors.availableLight
                  : AppColors.divider,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              user.hasActivePlan ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: user.hasActivePlan
                    ? AppColors.available
                    : AppColors.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Star Row ─────────────────────────────────────────────────────────────────

class StarRow extends StatelessWidget {
  final double rating;
  const StarRow({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            i < rating.floor()
                ? Icons.star_rounded
                : (i < rating
                    ? Icons.star_half_rounded
                    : Icons.star_outline_rounded),
            size: 14,
            color: const Color(0xFFFFC107),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '${rating.toStringAsFixed(1)} condition',
          style: const TextStyle(fontSize: 12, color: AppColors.textMedium),
        ),
      ],
    );
  }
}
