import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/section_label.dart';
import '../viewmodel/ride_viewmodel.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class PaymentTypeScreen extends StatelessWidget {
  const PaymentTypeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments (bike and station) if they exist
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Payment Options'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'No active subscription found. How would you like to pay for this ride?',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 30),
            _PaymentOptionCard(
              title: 'Pay to Go',
              subtitle: 'One-time payment for this ride only',
              price: '\$0.50',
              icon: Icons.payments_outlined,
              onTap: () {
                _showPaymentMethod(context, args);
              },
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
            const SizedBox(height: 16),
            _PaymentOptionCard(
              title: 'Buy a Subscription',
              subtitle: 'Unlock unlimited rides and save more',
              price: 'from \$1.50',
              icon: Icons.card_membership_outlined,
              isRecommended: true,
              onTap: () {
                Navigator.pushNamed(context, '/subscription', arguments: args);
              },
            )
                .animate()
                .fadeIn(delay: 150.ms, duration: 400.ms)
                .slideY(begin: 0.1),
            const Spacer(),
            SecondaryButton(
              label: 'Cancel Booking',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showPaymentMethod(BuildContext context, Map<String, dynamic>? args) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SectionLabel(label: 'Choose Payment Method'),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppColors.primary),
              title: const Text('Credit Card'),
              onTap: () => _processPayToGo(context, args),
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.qr_code_scanner, color: AppColors.primary),
              title: const Text('ABA / PayWay QR'),
              onTap: () => _processPayToGo(context, args),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _processPayToGo(
      BuildContext context, Map<String, dynamic>? args) async {
    Navigator.pop(context); // Close sheet

    if (args != null) {
      final rideVm = context.read<RideViewModel>();
      final authVm = context.read<AuthViewModel>();
      final uid = authVm.firebaseUser?.uid;

      if (uid != null) {
        final bike = args['bike'];
        final station = args['station'];

        final ok = await rideVm.book(
          userId: uid,
          bike: bike,
          station: station,
        );

        if (!context.mounted) return;

        if (!ok) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                rideVm.error ?? 'Payment succeeded but booking failed.',
              ),
            ),
          );
          return;
        }
      }
    }
  }
}

class _PaymentOptionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String price;
  final IconData icon;
  final VoidCallback onTap;
  final bool isRecommended;

  const _PaymentOptionCard({
    required this.title,
    required this.subtitle,
    required this.price,
    required this.icon,
    required this.onTap,
    this.isRecommended = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isRecommended ? AppColors.primary : AppColors.border,
            width: isRecommended ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isRecommended
                    ? AppColors.primarySurface
                    : AppColors.background,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  color:
                      isRecommended ? AppColors.primary : AppColors.textMedium),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineSmall),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            Text(
              price,
              style: AppTextStyles.headlineSmall
                  .copyWith(color: AppColors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
