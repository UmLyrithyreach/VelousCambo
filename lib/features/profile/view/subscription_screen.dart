import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../models/subscription_plan_model.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/section_label.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';
import '../../ride/viewmodel/ride_viewmodel.dart';
import '../viewmodel/subscription_viewmodel.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Get arguments (bike and station) if they exist from the redirect
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    return ChangeNotifierProvider(
      create: (context) => SubscriptionViewModel(context.read<AuthViewModel>()),
      child: Consumer<SubscriptionViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textDark),
                onPressed: () => Navigator.pop(context),
              ),
              title: const Text('Unlock Unlimited Rides',
                  style: AppTextStyles.headlineSmall),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    const Text(
                      'Choose a plan that fits your lifestyle and enjoy VelousCambo to the fullest.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMedium,
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: ListView.builder(
                        itemCount: SubscriptionPlan.availablePlans.length,
                        itemBuilder: (context, index) {
                          final plan = SubscriptionPlan.availablePlans[index];
                          final isSelected =
                              viewModel.state.selectedPlan == plan.type;

                          return _PlanCard(
                            plan: plan,
                            isSelected: isSelected,
                            onTap: () => viewModel.selectPlan(plan.type),
                          )
                              .animate()
                              .fadeIn(delay: (index * 100).ms)
                              .slideX(begin: 0.1);
                        },
                      ),
                    ),
                    _SubscriptionFooter(
                      isLoading: viewModel.state.isLoading,
                      onPurchase: () =>
                          _showPaymentOptions(context, viewModel, args),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showPaymentOptions(BuildContext context,
      SubscriptionViewModel viewModel, Map<String, dynamic>? args) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SectionLabel(label: 'Select Payment Method'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.credit_card, color: AppColors.primary),
              title: const Text('Credit Card'),
              onTap: () => _finalizePurchase(context, viewModel, args),
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.qr_code_scanner, color: AppColors.primary),
              title: const Text('QR Pay (ABA/PayWay)'),
              onTap: () => _finalizePurchase(context, viewModel, args),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _finalizePurchase(BuildContext context,
      SubscriptionViewModel viewModel, Map<String, dynamic>? args) async {
    Navigator.pop(context); // Close sheet

    final success = await viewModel.purchasePlan();
    if (success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription purchased successfully!')),
      );

      if (args != null) {
        // Automatically complete the booking if we came from that user flow
        final rideVm = context.read<RideViewModel>();
        final authVm = context.read<AuthViewModel>();
        final uid = authVm.firebaseUser?.uid;

        if (uid != null) {
          final bike = args['bike'];
          final station = args['station'];
          final ok =
              await rideVm.book(userId: uid, bike: bike, station: station);

          if (ok && context.mounted) {
            Navigator.pushReplacementNamed(context, '/booking-confirmed',
                arguments: bike.id);
            return;
          }
        }
      }

      // If no booking args, just go back (came from Profile)
      if (!context.mounted) return;
      Navigator.pop(context);
    }
  }
}

class _PlanCard extends StatelessWidget {
  final SubscriptionPlan plan;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.plan,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? plan.color : AppColors.border,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: plan.color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: plan.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(plan.icon, color: plan.color, size: 24),
                ),
                if (isSelected)
                  Icon(Icons.check_circle, color: plan.color, size: 24),
              ],
            ),
            const SizedBox(height: 16),
            Text(plan.title, style: AppTextStyles.headlineSmall),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(plan.priceLabel,
                    style: AppTextStyles.headlineMedium
                        .copyWith(color: plan.color)),
                const SizedBox(width: 4),
                Text(plan.durationLabel, style: AppTextStyles.bodySmall),
              ],
            ),
            const SizedBox(height: 16),
            ...plan.features.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                          color: plan.color, size: 16),
                      const SizedBox(width: 8),
                      Text(feature, style: AppTextStyles.bodySmall),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _SubscriptionFooter extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPurchase;

  const _SubscriptionFooter({
    required this.isLoading,
    required this.onPurchase,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          PrimaryButton(
            label: 'Subscribe Now',
            onPressed: onPurchase,
            isLoading: isLoading,
          ),
          const SizedBox(height: 12),
          Text(
            'Secure Payment via Stripe/PayWay',
            style: AppTextStyles.bodySmall.copyWith(fontSize: 11),
          ),
        ],
      ),
    );
  }
}
