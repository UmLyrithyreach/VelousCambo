import 'package:flutter/material.dart';
import '../../../models/subscription_plan_model.dart';

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
  SubscriptionState _state = SubscriptionState();
  SubscriptionState get state => _state;

  void selectPlan(PlanType type) {
    _state = _state.copyWith(selectedPlan: type);
    notifyListeners();
  }

  Future<void> purchasePlan() async {
    _state = _state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      // Mock payment delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would call your AuthRepository/FirestoreService
      // to update the user's plan and expiry date.
      
      _state = _state.copyWith(isLoading: false, isPurchased: true);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, error: 'Payment failed. Please try again.');
      notifyListeners();
    }
  }

  void resetPurchase() {
    _state = _state.copyWith(isPurchased: false);
    notifyListeners();
  }
}
