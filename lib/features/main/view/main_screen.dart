import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:velouscambo_enhanced_new/features/auth/viewmodel/auth_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/history/viewmodel/history_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/map/viewmodel/station_viewmodel.dart';
import 'package:velouscambo_enhanced_new/features/map/view/home_screen.dart';
import 'package:velouscambo_enhanced_new/features/history/view/history_screen.dart';
import 'package:velouscambo_enhanced_new/features/profile/view/profile_screen.dart';
import 'package:velouscambo_enhanced_new/shared/widgets/navigation_bar/navigation_bar.dart';
import 'package:velouscambo_enhanced_new/features/ride/viewmodel/ride_viewmodel.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    HistoryScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthViewModel>();
    final uid = auth.firebaseUser?.uid;
    final plan = auth.userModel?.plan;
    
    // Use actual uid if logged in, otherwise use a test uid so stations
    // still stream from Firestore during development testing.
    final effectiveUid = uid ?? 'test-user-dev';
    
    context.read<StationViewModel>().init(effectiveUid);
    context.read<HistoryViewModel>().load(effectiveUid);
    context.read<RideViewModel>().init(effectiveUid, plan);
  }

  @override
  Widget build(BuildContext context) {
    final hasActive = context.watch<StationViewModel>().hasActiveRental;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: AppNavigationBar(
        selectedIndex: _currentIndex,
        hasActiveRental: hasActive,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
