import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/features/history/viewmodel/history_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/history/widgets/rental_card.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistoryViewModel>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ride History'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: _buildBody(vm),
    );
  }

  Widget _buildBody(HistoryViewModel vm) {
    if (vm.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (vm.error != null) {
      return _ErrorState(
        error: vm.error!,
        onRetry: () {
          // Retry loading - in a real app you'd pass userId here
          // For now, this helps users understand they can retry
        },
      );
    }
    if (vm.rentals.isEmpty) {
      return const _EmptyHistory();
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      itemCount: vm.rentals.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => RentalCard(rental: vm.rentals[i], index: i),
    );
  }
}

// ─── Empty State ────

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(Icons.history_rounded,
                color: AppColors.textLight, size: 38),
          ),
          const SizedBox(height: 18),
          const Text(
            'No rides yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Your completed rides will appear here',
            style: TextStyle(fontSize: 14, color: AppColors.textMedium),
          ),
        ],
      ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
    );
  }
}

// ─── Error State ───

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback? onRetry;
  const _ErrorState({required this.error, this.onRetry});

  @override
  Widget build(BuildContext context) {
    final isIndexError = error.contains('index');

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.error_outline_rounded,
                  color: Color(0xFFC62828), size: 38),
            ),
            const SizedBox(height: 18),
            Text(
              isIndexError
                  ? 'Firebase Setup Required'
                  : 'Unable to Load History',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isIndexError
                  ? 'A Firestore composite index needs to be created in Firebase Console.'
                  : 'Check your internet connection and try again.',
              style: const TextStyle(fontSize: 14, color: AppColors.textMedium),
              textAlign: TextAlign.center,
            ),
            if (isIndexError) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3E0),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB74D), width: 1),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fix:',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '1. Go to Firebase Console\n'
                      '2. Firestore → Indexes tab\n'
                      '3. Create composite index:\n'
                      '   - Collection: rentals\n'
                      '   - Fields: status, userId, startTime (desc)',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6D4C41),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
