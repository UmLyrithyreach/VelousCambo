import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/rental_model.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/custom_button.dart';
import 'package:velouscambo_enhanced_new/features/ride/viewmodel/ride_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/ride/state/ride_state.dart';

class ActiveRentalScreen extends StatefulWidget {
  const ActiveRentalScreen({super.key});

  @override
  State<ActiveRentalScreen> createState() => _ActiveRentalScreenState();
}

class _ActiveRentalScreenState extends State<ActiveRentalScreen>
    with SingleTickerProviderStateMixin {
  late Timer _ticker;
  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _endRide() async {
    final rideVm = context.read<RideViewModel>();
    final state = rideVm.state;
    if (state is! RideActive) return;

    final rental = state.rental;
    final elapsed = rental.elapsed;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('End Ride?',
            style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text(
          'You have been riding for ${_formatDuration(elapsed)}.\n'
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

    final ok = await rideVm.endRental();
    if (ok && mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('Ride ended • ${_formatDuration(elapsed)} total'),
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
    final rideVm = context.watch<RideViewModel>();
    final state = rideVm.state;

    // 1. Handle non-active states
    if (state is! RideActive) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('Active Ride')),
        body: Center(
          child: state is RideLoading
              ? const CircularProgressIndicator()
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.info_outline, size: 48, color: AppColors.textMedium),
                    const SizedBox(height: 16),
                    Text(
                      state is RideError ? state.message : 'No active rental found.',
                      style: const TextStyle(color: AppColors.textMedium),
                    ),
                    const SizedBox(height: 24),
                    TextButton(
                      onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
                      child: const Text('Return to Map'),
                    ),
                  ],
                ),
        ),
      );
    }

    // 2. Pure Rendering for Active State
    final rental = state.rental;
    final planLimitMinutes = state.planLimitMinutes;
    final elapsed = rental.elapsed;
    final remainingUnlockSeconds =
        (30 - elapsed.inSeconds).clamp(0, 30);
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
            _TimerRing(
              elapsed: elapsed,
              isUnlocking: isUnlocking,
              remainingUnlockSeconds: remainingUnlockSeconds,
              pulseAnim: _pulseCtrl,
              planLimitMinutes: planLimitMinutes,
            )
                .animate()
                .fadeIn(duration: 400.ms)
                .scale(begin: const Offset(0.8, 0.8)),

            const SizedBox(height: 28),

            _InfoCard(rental: rental)
                .animate()
                .fadeIn(delay: 150.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 20),

            _UnlockStatusCard(
              bikeCode: rental.bikeCode,
              isUnlocking: isUnlocking,
              remainingUnlockSeconds: remainingUnlockSeconds,
              planLimitMinutes: planLimitMinutes,
            ).animate().fadeIn(delay: 250.ms).slideY(begin: 0.05),

            const SizedBox(height: 32),

            DestructiveButton(
              label: 'End Ride',
              onPressed: _endRide,
              isLoading: rideVm.isLoading,
            ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _TimerRing extends StatelessWidget {
  static const int _unlockSeconds = 30;
  final Duration elapsed;
  final bool isUnlocking;
  final int remainingUnlockSeconds;
  final AnimationController pulseAnim;
  final int planLimitMinutes;

  const _TimerRing({
    required this.elapsed,
    required this.isUnlocking,
    required this.remainingUnlockSeconds,
    required this.pulseAnim,
    required this.planLimitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final minutes = elapsed.inMinutes;
    final seconds = elapsed.inSeconds % 60;

    final limitSeconds = planLimitMinutes * 60;
    final rideProgress = (elapsed.inSeconds / limitSeconds).clamp(0.0, 1.0);
    final unlockProgress = (_unlockSeconds - remainingUnlockSeconds) / _unlockSeconds;

    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) {
        final scale = 1.0 + 0.02 * pulseAnim.value;
        return Transform.scale(
          scale: scale,
          child: SizedBox(
            width: 220,
            height: 220,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: 14,
                    color: AppColors.primaryLight.withOpacity(0.2),
                  ),
                ),
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: isUnlocking ? unlockProgress : rideProgress,
                    strokeWidth: 14,
                    color: isUnlocking ? AppColors.available : AppColors.primary,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isUnlocking) ...[
                      const Icon(Icons.lock_open_rounded, color: AppColors.available, size: 32),
                      const SizedBox(height: 4),
                      Text(
                        remainingUnlockSeconds.toString().padLeft(2, '0'),
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.available),
                      ),
                      const Text('unlock window', style: TextStyle(fontSize: 12, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                    ] else ...[
                      Text(
                        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                        style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: AppColors.textDark, letterSpacing: -1),
                      ),
                      Text('of $planLimitMinutes min free', style: const TextStyle(fontSize: 14, color: AppColors.textMedium, fontWeight: FontWeight.w600)),
                    ],
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

class _InfoCard extends StatelessWidget {
  final RentalModel rental;
  const _InfoCard({required this.rental});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.pedal_bike_rounded, color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Bike #${rental.bikeCode}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
                const SizedBox(height: 2),
                Text(rental.stationName, style: const TextStyle(color: AppColors.textMedium, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UnlockStatusCard extends StatelessWidget {
  final String bikeCode;
  final bool isUnlocking;
  final int remainingUnlockSeconds;
  final int planLimitMinutes;

  const _UnlockStatusCard({
    required this.bikeCode,
    required this.isUnlocking,
    required this.remainingUnlockSeconds,
    required this.planLimitMinutes,
  });

  @override
  Widget build(BuildContext context) {
    final title = isUnlocking ? 'Bike Alarm Deactivated' : 'Enjoy Your Ride!';
    final message = isUnlocking
        ? 'The alarm is off for $remainingUnlockSeconds more seconds. Pull the bike out now.'
        : 'You have $planLimitMinutes minutes included in your plan for this session.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isUnlocking ? AppColors.available.withOpacity(0.08) : AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isUnlocking ? AppColors.available.withOpacity(0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(isUnlocking ? Icons.timer_outlined : Icons.check_circle_outline_rounded, color: isUnlocking ? AppColors.available : AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: isUnlocking ? AppColors.available : AppColors.textDark)),
                const SizedBox(height: 2),
                Text(message, style: const TextStyle(color: AppColors.textMedium, fontSize: 13, height: 1.3)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
