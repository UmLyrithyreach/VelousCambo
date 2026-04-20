import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/features/map/viewmodel/station_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/map/widgets/station_detail_sheet.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/icon_box.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/surface_card.dart';

class StationListTile extends StatelessWidget {
  final StationModel station;
  final int index;
  const StationListTile(
      {super.key, required this.station, required this.index});

  @override
  Widget build(BuildContext context) {
    final available = station.availableBikes;
    final isGood = available > 3;

    return GestureDetector(
      onTap: () {
        final sp = context.read<StationViewModel>();
        sp.selectStation(station);
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => ChangeNotifierProvider.value(
            value: sp,
            child: const StationDetailSheet(),
          ),
        ).whenComplete(sp.clearSelectedStation);
      },
      child: SurfaceCard(
        child: Row(
          children: [
            const IconBox(
              icon: Icons.location_on_rounded,
              iconColor: AppColors.primary,
              backgroundColor: AppColors.primarySurface,
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.pedal_bike_rounded,
                        size: 14,
                        color: isGood ? AppColors.available : AppColors.rented),
                    const SizedBox(width: 3),
                    Text(
                      '$available bikes',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isGood ? AppColors.available : AppColors.rented,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${station.totalDocks} docks',
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.textLight),
                ),
              ],
            ),
          ],
        ),
      )
          .animate()
          .fadeIn(delay: (index * 40).ms)
          .slideY(begin: 0.05, curve: Curves.easeOut),
    );
  }
}
