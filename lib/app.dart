import 'package:flutter/material.dart';
import 'package:velouscambo_enhanced_new/core/theme/app_theme.dart';
import 'package:velouscambo_enhanced_new/features/splash/view/splash_screen.dart';
import 'package:velouscambo_enhanced_new/features/auth/view/login_screen.dart';
import 'package:velouscambo_enhanced_new/features/auth/view/register_screen.dart';
import 'package:velouscambo_enhanced_new/features/main/view/main_screen.dart';
import 'package:velouscambo_enhanced_new/features/ride/view/booking_screen.dart';
import 'package:velouscambo_enhanced_new/features/ride/view/active_rental_screen.dart';
import 'package:velouscambo_enhanced_new/features/profile/view/edit_profile_screen.dart';
import 'package:velouscambo_enhanced_new/features/search/view/search_screen.dart';

class VelousCamboApp extends StatelessWidget {
  const VelousCamboApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VelousCambo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // TODO: revert to '/' once auth/splash are implemented by teammates
      initialRoute: '/home',
      routes: {
        '/': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/register': (_) => const RegisterScreen(),
        '/home': (_) => const MainScreen(),
        '/search': (_) => const SearchScreen(),
        '/booking': (_) => const BookingScreen(),
        '/active-rental': (_) => const ActiveRentalScreen(),
        '/edit-profile': (_) => const EditProfileScreen(),
      },
    );
  }
}
