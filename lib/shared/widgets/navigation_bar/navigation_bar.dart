import 'package:flutter/material.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'nav_item.dart';

class AppNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final bool hasActiveRental;

  const AppNavigationBar({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    this.hasActiveRental = false,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(
              color: AppColors.border.withOpacity(0.3),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            children: [
              NavItem(
                selectedIcon: Icons.map_rounded,
                unselectedIcon: Icons.map_outlined,
                label: 'Map',
                isSelected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              NavItem(
                selectedIcon: Icons.history_rounded,
                unselectedIcon: Icons.history_outlined,
                label: 'History',
                isSelected: selectedIndex == 1,
                badge: hasActiveRental,
                onTap: () => onTap(1),
              ),
              NavItem(
                selectedIcon: Icons.person_rounded,
                unselectedIcon: Icons.person_outline_rounded,
                label: 'Profile',
                isSelected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
