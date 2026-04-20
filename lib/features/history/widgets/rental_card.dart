import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/icon_box.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/surface_card.dart';

class RentalCard extends StatelessWidget {
  final RentalModel rental;
  final int index;
  const RentalCard({super.key, required this.rental, required this.index});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('MMM d, yyyy').format(rental.startTime);
    final timeStr = DateFormat('HH:mm').format(rental.startTime);
    final duration = rental.durationMinutes ?? 0;

    return SurfaceCard(
      child: Row(
        children: [
          const IconBox(
            icon: Icons.pedal_bike_rounded,
            iconColor: AppColors.primary,
            backgroundColor: AppColors.primarySurface,
            size: 48,
            iconSize: 24,
            radius: 14,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rental.stationName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  '$dateStr • $timeStr',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textMedium),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.pedal_bike_rounded,
                        size: 12, color: AppColors.textLight),
                    const SizedBox(width: 3),
                    Text(
                      'Bike #${rental.bikeCode}',
                      style: const TextStyle(
                          fontSize: 11, color: AppColors.textLight),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${duration}m',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Completed',
                style: TextStyle(fontSize: 11, color: AppColors.available),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: (index * 50).ms)
        .slideY(begin: 0.05, curve: Curves.easeOut);
  }
}
