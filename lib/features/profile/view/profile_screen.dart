import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/core/constants/app_colors.dart';
import 'package:velouscambo_enhanced_new/models/user_model.dart';
import 'package:velouscambo_enhanced_new/features/auth/viewmodel/auth_viewmodel.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthViewModel>();
    final user = auth.userModel;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.surface,
        automaticallyImplyLeading: false,
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Avatar + name
                  _ProfileHeader(user: user)
                      .animate()
                      .fadeIn(duration: 300.ms)
                      .slideY(begin: -0.1),

                  const SizedBox(height: 20),

                  // Subscription card
                  _SubscriptionCard(user: user)
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.05),

                  const SizedBox(height: 16),

                  // Settings
                  _SettingsSection()
                      .animate()
                      .fadeIn(delay: 180.ms)
                      .slideY(begin: 0.05),

                  const SizedBox(height: 16),

                  // Log out
                  _LogOutButton()
                      .animate()
                      .fadeIn(delay: 260.ms)
                      .slideY(begin: 0.05),

                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}

// ─── Profile Header ───────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

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
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryLight, width: 2.5),
                ),
                child: ClipOval(
                  child: user.photoUrl != null
                      ? CachedNetworkImage(
                          imageUrl: user.photoUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => const _AvatarPlaceholder(),
                          errorWidget: (_, __, ___) =>
                              const _AvatarPlaceholder(),
                        )
                      : const _AvatarPlaceholder(),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  user.email,
                  style: const TextStyle(
                      fontSize: 13, color: AppColors.textMedium),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/edit-profile'),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarPlaceholder extends StatelessWidget {
  const _AvatarPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primarySurface,
      child: const Icon(
        Icons.person_rounded,
        color: AppColors.primary,
        size: 36,
      ),
    );
  }
}

// ─── Subscription Card ────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  final UserModel user;
  const _SubscriptionCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final expiryStr = user.planExpiry != null
        ? DateFormat('MMM d, yyyy').format(user.planExpiry!)
        : 'N/A';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SUBSCRIPTION',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      user.planDisplayName,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (user.hasActivePlan)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                if (user.planExpiry != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Valid until $expiryStr',
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/subscription'),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Manage',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
              if (user.hasActivePlan) ...[
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () => _showCancelDialog(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.white38),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cancel Subscription?'),
        content: const Text(
          'Are you sure you want to cancel your current plan? You will lose access to unlimited rides immediately.',
          style: TextStyle(color: AppColors.textMedium),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Plan', style: TextStyle(color: AppColors.textMedium)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await context.read<AuthViewModel>().cancelSubscription();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Subscription cancelled.')),
                );
              }
            },
            child: const Text('Cancel Plan', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Settings Section ─────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.credit_card_outlined,
            label: 'Payment Methods',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & Support',
            onTap: () {},
          ),
          const Divider(height: 1, indent: 56),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            label: 'About VelousCambo',
            onTap: () => _showAbout(context),
            showChevron: true,
          ),
        ],
      ),
    );
  }

  void _showAbout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.pedal_bike_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Text('VelousCambo', style: TextStyle(fontWeight: FontWeight.w800)),
          ],
        ),
        content: const Text(
          'VelousCambo is a mechanical bike-sharing service in Phnom Penh, '
          'inspired by VéloToulouse. Rent a bike from any station and return '
          'it to any other station in the city.\n\nVersion 1.0.0',
          style: TextStyle(color: AppColors.textMedium, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
                const Text('Close', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool showChevron;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.showChevron = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textDark,
                ),
              ),
            ),
            if (showChevron)
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}

// ─── Log Out Button ───────────────────────────────────────────────────────────

class _LogOutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final auth = context.read<AuthViewModel>();
        final navigator = Navigator.of(context);
        await auth.signOut();
        navigator.pushReplacementNamed('/login');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: AppColors.primary, size: 20),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
