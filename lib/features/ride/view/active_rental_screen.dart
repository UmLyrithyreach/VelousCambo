import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/features/map/viewmodel/station_viewmodel.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/custom_button.dart';

class ActiveRentalScreen extends StatefulWidget {
  const ActiveRentalScreen({super.key});

  @override
  State<ActiveRentalScreen> createState() => _ActiveRentalScreenState();
}

class _ActiveRentalScreenState extends State<ActiveRentalScreen>
    with SingleTickerProviderStateMixin {
  static const int _unlockSeconds = 30;
  late Timer _ticker;
  late AnimationController _pulseCtrl;
  Duration _elapsed = Duration.zero;
  RentalModel? _rental;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        final rental = context.read<StationViewModel>().activeRental;
        setState(() {
          _rental = rental;
          _elapsed = rental?.elapsed ?? _elapsed + const Duration(seconds: 1);
        });
      }
    });

    _rental = context.read<StationViewModel>().activeRental;
    if (_rental != null) _elapsed = _rental!.elapsed;
  }

  @override
  void dispose() {
    _ticker.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _endRide() async {
    final sp = context.read<StationViewModel>();
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Ride?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'You have been riding for ${_formatDuration(_elapsed)}.\n'
          'Are you sure you want to return this bike?',
          style: const TextStyle(color: AppColors.textMedium, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Continue Riding',
                style: TextStyle(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('End Ride',
                style: TextStyle(
                    color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    final ok = await sp.endRental();
    if (ok && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('Ride ended • ${_formatDuration(_elapsed)} total'),
          ]),
          backgroundColor: AppColors.available,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      navigator.pushReplacementNamed('/home');
    }
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<StationViewModel>();
    final rental = sp.activeRental ?? _rental;

    if (rental == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Active Ride')),
        body: const Center(child: Text('No active rental found.')),
      );
    }

    final remainingUnlockSeconds =
        (_unlockSeconds - _elapsed.inSeconds).clamp(0, _unlockSeconds);
    final isUnlocking = remainingUnlockSeconds > 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Active Ride'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            child:
                const Text('Map', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Timer ring
            _TimerRing(
              elapsed: _elapsed,
              isUnlocking: isUnlocking,
              remainingUnlockSeconds: remainingUnlockSeconds,
              pulseAnim: _pulseCtrl,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 28),

            // Bike + station info
            _InfoCard(rental: rental)
                .animate()
                .fadeIn(delay: 150.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 20),

            // Unlock countdown / ride status
            _UnlockStatusCard(
              bikeCode: rental.bikeCode,
              isUnlocking: isUnlocking,
              remainingUnlockSeconds: remainingUnlockSeconds,
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),

            const SizedBox(height: 32),

            DestructiveButton(
              label: 'End Ride',
              onPressed: _endRide,
              isLoading: sp.isLoading,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─── Timer Ring ───

class _TimerRing extends StatelessWidget {
  static const int _unlockSeconds = 30;
  final Duration elapsed;
  final bool isUnlocking;
  final int remainingUnlockSeconds;
  final AnimationController pulseAnim;

  const _TimerRing({
    required this.elapsed,
    required this.isUnlocking,
    required this.remainingUnlockSeconds,
    required this.pulseAnim,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;
    final rideProgress = (elapsed.inSeconds % 1800) / 1800; // 30-min cycle
    final unlockProgress =
        (_unlockSeconds - remainingUnlockSeconds) / _unlockSeconds;

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) {
        final scale = 1.0 + 0.02 * pulseAnim.value;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 200,
            height: 200,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background ring
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 12,
                    color: AppColors.primaryLight,
                  ),
                ),
                // Progress ring
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: isUnlocking ? unlockProgress : rideProgress,
                    strokeWidth: 12,
                    color: AppColors.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Timer text
                if (isUnlocking)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        remainingUnlockSeconds.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1,
                        ),
                      ),
                      const Text(
                        'seconds',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'unlock window',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        minutes.toString().padLeft(2, '0'),
                        style: const TextStyle(
                          fontSize: 52,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          height: 1,
                        ),
                      ),
                      Text(
                        ':${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'minutes',
                        style:
                            TextStyle(fontSize: 12, color: AppColors.textLight),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Info Card ───

class _InfoCard extends StatelessWidget {
  final RentalModel rental;
  const _InfoCard({required this.rental});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.pedal_bike_rounded,
            iconColor: AppColors.available,
            label: 'Bike',
            value: '#${rental.bikeCode}',
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.location_on_rounded,
            iconColor: AppColors.primary,
            label: 'Station',
            value: rental.stationName,
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.access_time_rounded,
            iconColor: AppColors.rented,
            label: 'Started',
            value: _formatTime(rental.startTime),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Text(label,
            style: const TextStyle(fontSize: 13, color: AppColors.textMedium)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark),
        ),
      ],
    );
  }
}

// ─── Unlock Status Card ──

class _UnlockStatusCard extends StatelessWidget {
  final String bikeCode;
  final bool isUnlocking;
  final int remainingUnlockSeconds;

  const _UnlockStatusCard({
    required this.bikeCode,
    required this.isUnlocking,
    required this.remainingUnlockSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final title = isUnlocking ? 'Bike Alarm Deactivated' : 'You Can Ride Now';
    final message = isUnlocking
        ? 'Bike #$bikeCode is booked for you.\n'
            'Alarm is off for $remainingUnlockSeconds seconds. '
            'Please unlock and start riding now.'
        : 'Bike #$bikeCode is ready. Start your journey and ride safely.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_active_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          if (!isUnlocking) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.availableLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                '✅ Alarm window completed. Ride is active.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.available,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
