import 'package:flutter/material.dart';
import '../../../models/subscription_plan_model.dart';
import '../../auth/viewmodel/auth_viewmodel.dart';

class SubscriptionState {
  final bool isLoading;
  final String? error;
  final PlanType selectedPlan;
  final bool isPurchased;

  SubscriptionState({
    this.isLoading = false,
    this.error,
    this.selectedPlan = PlanType.monthly,
    this.isPurchased = false,
  });

  SubscriptionState copyWith({
    bool? isLoading,
    String? error,
    PlanType? selectedPlan,
    bool? isPurchased,
  }) {
    return SubscriptionState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isPurchased: isPurchased ?? this.isPurchased,
    );
  }
}

class SubscriptionViewModel extends ChangeNotifier {
  final AuthViewModel _authVm;
  
  SubscriptionState _state = SubscriptionState();
  SubscriptionState get state => _state;

  SubscriptionViewModel(this._authVm);

  void selectPlan(PlanType type) {
    _state = _state.copyWith(selectedPlan: type);
    notifyListeners();
  }

  Future<bool> purchasePlan() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      // Mock payment delay
      await Future.delayed(const Duration(seconds: 2));
      
      // Update the user model in AuthViewModel
      final String planStr = _state.selectedPlan.toString().split('.').last;
      final expiry = _calculateExpiry(_state.selectedPlan);
      
      await _authVm.updateUserPlan(plan: planStr, expiry: expiry);
      
      _state = _state.copyWith(isLoading: false, isPurchased: true);
      notifyListeners();
      return true;
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: 'Payment failed. Please try again.');
      notifyListeners();
      return false;
    }
  }

  DateTime _calculateExpiry(PlanType type) {
    final now = DateTime.now();
    switch (type) {
      case PlanType.daily:
        return now.add(const Duration(days: 1));
      case PlanType.monthly:
        return now.add(const Duration(days: 30));
      case PlanType.annual:
        return now.add(const Duration(days: 365));
      default:
        return now;
    }
  }

  void resetPurchase() {
    _state = _state.copyWith(isPurchased: false);
    notifyListeners();
  }
}
