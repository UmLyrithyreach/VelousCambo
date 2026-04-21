import 'package:flutter/material.dart';
import 'package:velouscambo_enhanced_new/core/theme/app_theme.dart';
import 'package:velouscambo_enhanced_new/features/splash/view/splash_screen.dart';
import 'package:velouscambo_enhanced_new/features/auth/view/login_screen.dart';
import 'package:velouscambo_enhanced_new/features/auth/view/register_screen.dart';
import 'package:velouscambo_enhanced_new/features/main/view/main_screen.dart';
import 'package:velouscambo_enhanced_new/features/ride/view/booking_screen.dart';
import 'package:velouscambo_enhanced_new/features/ride/view/active_rental_screen.dart';
import 'package:velouscambo_enhanced_new/features/ride/view/qr_scanner_screen.dart';
import 'package:velouscambo_enhanced_new/features/ride/view/payment_type_screen.dart';
import 'package:velouscambo_enhanced_new/features/ride/view/booking_confirmed_screen.dart';
import 'package:velouscambo_enhanced_new/features/profile/view/edit_profile_screen.dart';
import 'package:velouscambo_enhanced_new/features/profile/view/subscription_screen.dart';
import 'package:velouscambo_enhanced_new/features/search/view/search_screen.dart';

class VelousCamboApp extends StatelessWidget {
  const VelousCamboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VelousCambo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const MainScreen());
          case '/search':
            return MaterialPageRoute(builder: (_) => const SearchScreen());
          case '/booking':
            return MaterialPageRoute(builder: (_) => const BookingScreen(), settings: settings);
          case '/booking-confirmed':
            final bikeId = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => BookingConfirmedScreen(bikeId: bikeId));
          case '/qr-scanner':
            final bikeId = settings.arguments as String;
            return MaterialPageRoute(builder: (_) => QRScannerScreen(expectedBikeId: bikeId));
          case '/payment-type':
            return MaterialPageRoute(builder: (_) => const PaymentTypeScreen(), settings: settings);
          case '/active-rental':
            return MaterialPageRoute(builder: (_) => const ActiveRentalScreen());
          case '/edit-profile':
            return MaterialPageRoute(builder: (_) => const EditProfileScreen());
          case '/subscription':
            return MaterialPageRoute(builder: (_) => const SubscriptionScreen(), settings: settings);
          default:
            return MaterialPageRoute(builder: (_) => const SplashScreen());
        }
      },
    );
  }
}
