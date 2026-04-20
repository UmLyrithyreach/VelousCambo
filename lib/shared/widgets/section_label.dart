import 'package:flutter/material.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';

/// Small uppercase-style section label used above cards.
class SectionLabel extends StatelessWidget {
  final String label;

  const SectionLabel({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textMedium,
        letterSpacing: 0.3,
      ),
    );
  }
}
