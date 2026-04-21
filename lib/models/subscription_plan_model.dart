import 'package:flutter/material.dart';

enum PlanType { none, daily, monthly, annual }

class SubscriptionPlan {
  final PlanType type;
  final String title;
  final String priceLabel;
  final double price;
  final String durationLabel;
  final List<String> features;
  final Color color;
  final IconData icon;

  const SubscriptionPlan({
    required this.type,
    required this.title,
    required this.priceLabel,
    required this.price,
    required this.durationLabel,
    required this.features,
    required this.color,
    required this.icon,
  });

  static List<SubscriptionPlan> get availablePlans => [
        /*const SubscriptionPlan(
          type: PlanType.daily,
          title: 'Day Pass',
          priceLabel: '\$1.50',
          price: 1.50,
          durationLabel: '/ 24 Hours',
          icon: Icons.timer_outlined,
          color: Color(0xFF4CAF50),
          features: [
            'Unlimited 30-min rides',
            'No unlock fee',
            'Perfect for tourists',
            'Insurance included',
          ],
        ),*/
        const SubscriptionPlan(
          type: PlanType.monthly,
          title: 'Monthly Saver',
          priceLabel: '\$12.00',
          price: 12.00,
          durationLabel: '/ Month',
          icon: Icons.calendar_month_outlined,
          color: Color(0xFFD32F2F),
          features: [
            'Unlimited 45-min rides',
            'Priority support',
            'Free ride reservations',
            'Cancel anytime',
          ],
        ),
        const SubscriptionPlan(
          type: PlanType.annual,
          title: 'Annual Pro',
          priceLabel: '\$99.00',
          price: 99.00,
          durationLabel: '/ Year',
          icon: Icons.verified_user_outlined,
          color: Color(0xFF1976D2),
          features: [
            'Unlimited 60-min rides',
            '2 months free',
            'Exclusive events access',
            'Family sharing support',
          ],
        ),
      ];
}
