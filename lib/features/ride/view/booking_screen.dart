import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/bike_model.dart';
import 'package:velouscambo_enhanced_new/models/station_model.dart';
import 'package:velouscambo_enhanced_new/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/ride/viewmodel/ride_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/ride/widgets/booking_cards.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/custom_button.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/section_label.dart';
import 'package:velouscambo_enhanced_new/features/ride/state/ride_state.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late BikeModel _bike;
  late StationModel _station;
  bool _argumentsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argumentsLoaded) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      _bike = args['bike'] as BikeModel;
      _station = args['station'] as StationModel;
      _argumentsLoaded = true;
    }
  }

  Future<void> _confirmBooking() async {
    final authVm = context.read<AuthViewModel>();
    final rideVm = context.read<RideViewModel>();
    final state = rideVm.state;

    final uid = authVm.firebaseUser?.uid;
    final user = authVm.userModel;

    if (uid == null || user == null) return;

// subscription check
    if (!user.hasActivePlan) {
      Navigator.pushNamed(
        context,
        '/payment-type',
        arguments: {'bike': _bike, 'station': _station},
      );
      return;
    }

    final ok = await rideVm.book(
      userId: uid,
      bike: _bike,
      station: _station,
    );

    if (!mounted) return;

    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state is RideError
                ? state.message
                : 'Failed to start rental. Please try again.',
          ),
          backgroundColor: AppColors.primary,
        ),
      );
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      '/booking-confirmed',
      arguments: _bike.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_argumentsLoaded) return const SizedBox.shrink();
    final rideVm = context.watch<RideViewModel>();
    final user = context.watch<AuthViewModel>().userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        leading: IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(label: 'Your Bike'),
            const SizedBox(height: 10),
            BikeDetailCard(bike: _bike)
                .animate()
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 20),

            const SectionLabel(label: 'Pick-up Station'),
            const SizedBox(height: 10),
            StationBookingCard(station: _station)
                .animate()
                .fadeIn(delay: 80.ms)
                .slideY(begin: 0.05),

            const SizedBox(height: 20),

            if (user != null) ...[
              const SectionLabel(label: 'Your Plan'),
              const SizedBox(height: 10),
              PlanCard(user: user)
                  .animate()
                  .fadeIn(delay: 160.ms)
                  .slideY(begin: 0.05),
              const SizedBox(height: 20),
            ],

            // Info box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primaryLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppColors.primary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'After booking, you will get a 30-second unlock window '
                      'where the alarm is turned off for your selected bike.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.primary.withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 240.ms),

            const SizedBox(height: 32),

            PrimaryButton(
              label: 'Book Bike',
              icon: Icons.pedal_bike_rounded,
              onPressed: _confirmBooking,
              isLoading: rideVm.isLoading,
            ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),

            const SizedBox(height: 12),

            SecondaryButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ).animate().fadeIn(delay: 360.ms),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
