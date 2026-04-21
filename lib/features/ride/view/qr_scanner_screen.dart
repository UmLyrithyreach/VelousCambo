import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';

class QRScannerScreen extends StatelessWidget {
  final String expectedBikeId;

  const QRScannerScreen({super.key, required this.expectedBikeId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Unlock Bike'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Scan the QR code on the bike to unlock',
              style: AppTextStyles.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Target Bike ID: $expectedBikeId',
              style: AppTextStyles.bodyMedium,
            ),
            const SizedBox(height: 40),
            
            // Simplified QR Placeholder
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: QrImageView(
                data: expectedBikeId,
                version: QrVersions.auto,
                size: 200.0,
                foregroundColor: AppColors.textDark,
              ),
            ),
            
            const SizedBox(height: 60),
            
            PrimaryButton(
              label: 'Verify & Unlock',
              icon: Icons.qr_code_scanner,
              onPressed: () {
                // Success path leads to the Active Ride
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Bike #$expectedBikeId Unlocked!'),
                    backgroundColor: AppColors.available,
                  ),
                );
                Navigator.pushReplacementNamed(context, '/active-rental');
              },
            ),
            const SizedBox(height: 16),
            SecondaryButton(
              label: 'Cancel',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
