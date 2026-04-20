import 'package:flutter/material.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';

class NavItem extends StatelessWidget {
  final IconData selectedIcon;
  final IconData unselectedIcon;
  final String label;
  final bool isSelected;
  final bool badge;
  final VoidCallback onTap;

  const NavItem({
    super.key,
    required this.selectedIcon,
    required this.unselectedIcon,
    required this.label,
    required this.isSelected,
    this.badge = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = AppColors.primary;
    final inactiveColor = AppColors.textLight;

    final showBadge = badge && !isSelected;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? activeColor : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isSelected ? selectedIcon : unselectedIcon,
                      color: isSelected ? Colors.white : inactiveColor,
                      size: 24,
                    ),
                  ),
                  if (showBadge)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.available,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? activeColor : inactiveColor,
                  fontSize: 12,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
