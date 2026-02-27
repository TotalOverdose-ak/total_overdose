import 'package:flutter/material.dart';
import '../services/eco_discounts_service.dart';

class EcoDiscount {
  final String id;
  final String title;
  final String description;
  final String discountType;
  final double discountValue;
  final double minPurchaseAmount;
  final double maxDiscountAmount;
  final int minEcoPoints;
  final String applicableCategory;
  final String? promoCode;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isActive;
  final int usageLimit;
  final int currentUsageCount;
  final String? conditions;

  EcoDiscount({
    required this.id,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.minPurchaseAmount,
    required this.maxDiscountAmount,
    required this.minEcoPoints,
    required this.applicableCategory,
    this.promoCode,
    this.startDate,
    this.endDate,
    required this.isActive,
    required this.usageLimit,
    required this.currentUsageCount,
    this.conditions,
  });

  factory EcoDiscount.fromData(EcoDiscountData data) {
    return EcoDiscount(
      id: data.id,
      title: data.title,
      description: data.description,
      discountType: data.discountType,
      discountValue: data.discountValue,
      minPurchaseAmount: data.minPurchaseAmount,
      maxDiscountAmount: data.maxDiscountAmount,
      minEcoPoints: data.minEcoPoints,
      applicableCategory: data.applicableCategory,
      promoCode: data.promoCode,
      startDate: data.startDate,
      endDate: data.endDate,
      isActive: data.isActive,
      usageLimit: data.usageLimit,
      currentUsageCount: data.currentUsageCount,
      conditions: data.conditions,
    );
  }

  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  bool get isAvailable {
    return isActive && !isExpired && currentUsageCount < usageLimit;
  }

  double calculateDiscount(double orderAmount) {
    if (!isAvailable || orderAmount < minPurchaseAmount) {
      return 0.0;
    }

    double discount = 0.0;
    switch (discountType) {
      case 'PERCENTAGE':
        discount = orderAmount * (discountValue / 100);
        break;
      case 'FIXED_AMOUNT':
        discount = discountValue;
        break;
      case 'FREE_SHIPPING':
        discount = 50.0; // Fixed shipping cost
        break;
    }

    if (maxDiscountAmount > 0 && discount > maxDiscountAmount) {
      discount = maxDiscountAmount;
    }

    return discount;
  }
}

class EcoDiscountsProvider extends ChangeNotifier {
  final List<EcoDiscount> _discounts = [];
  EcoDiscount? _appliedDiscount;
  bool _isLoading = false;
  String? _error;
  String? _currentUserId;
  int _userEcoPoints = 0;

  List<EcoDiscount> get allDiscounts => List.from(_discounts);
  List<EcoDiscount> get activeDiscounts => _discounts.where((d) => d.isAvailable).toList();
  List<EcoDiscount> get eligibleDiscounts => _discounts.where((d) => d.isAvailable && d.minEcoPoints <= _userEcoPoints).toList();
  EcoDiscount? get appliedDiscount => _appliedDiscount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get userEcoPoints => _userEcoPoints;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Load active discounts from backend
  Future<void> loadActiveDiscounts() async {
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Loading active eco discounts from backend...');
      final discountsData = await EcoDiscountsService.getActiveDiscounts();
      
      _discounts.clear();
      for (var discountData in discountsData) {
        _discounts.add(EcoDiscount.fromData(discountData));
      }

      print('✅ Loaded ${_discounts.length} active eco discounts');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading discounts: $e');
      _error = 'Failed to load discounts: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Load eligible discounts for user
  Future<void> loadEligibleDiscounts(String userId, int ecoPoints) async {
    _setLoading(true);
    _error = null;
    _currentUserId = userId;
    _userEcoPoints = ecoPoints;

    try {
      print('🔄 Loading eligible discounts for user: $userId (Points: $ecoPoints)');
      final discountsData = await EcoDiscountsService.getEligibleDiscounts(userId, ecoPoints);
      
      _discounts.clear();
      for (var discountData in discountsData) {
        _discounts.add(EcoDiscount.fromData(discountData));
      }

      print('✅ Loaded ${_discounts.length} eligible eco discounts');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading eligible discounts: $e');
      _error = 'Failed to load eligible discounts: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Apply discount to order
  Future<Map<String, dynamic>?> applyDiscount({
    required String discountId,
    required String userId,
    required String orderId,
    required double orderAmount,
  }) async {
    try {
      print('🔄 Applying discount: $discountId');
      
      final result = await EcoDiscountsService.applyDiscount(
        discountId: discountId,
        userId: userId,
        orderId: orderId,
        orderAmount: orderAmount,
      );

      // Update applied discount
      final discountIndex = _discounts.indexWhere((d) => d.id == discountId);
      if (discountIndex != -1) {
        _appliedDiscount = _discounts[discountIndex];
      }

      print('✅ Discount applied successfully');
      notifyListeners();
      return result;
    } catch (e) {
      print('❌ Error applying discount: $e');
      _error = 'Failed to apply discount: ${e.toString()}';
      return null;
    }
  }

  // Validate promo code
  Future<Map<String, dynamic>?> validatePromoCode(String promoCode, String userId) async {
    try {
      print('🔄 Validating promo code: $promoCode');
      
      final result = await EcoDiscountsService.validatePromoCode(promoCode, userId);

      print('✅ Promo code validated successfully');
      return result;
    } catch (e) {
      print('❌ Error validating promo code: $e');
      _error = 'Invalid promo code: ${e.toString()}';
      return null;
    }
  }

  // Get discounts by category
  Future<void> loadDiscountsByCategory(String category) async {
    _setLoading(true);
    _error = null;

    try {
      print('🔄 Loading discounts for category: $category');
      final discountsData = await EcoDiscountsService.getDiscountsByCategory(category);
      
      _discounts.clear();
      for (var discountData in discountsData) {
        _discounts.add(EcoDiscount.fromData(discountData));
      }

      print('✅ Loaded ${_discounts.length} discounts for category: $category');
      notifyListeners();
    } catch (e) {
      print('❌ Error loading category discounts: $e');
      _error = 'Failed to load category discounts: ${e.toString()}';
    } finally {
      _setLoading(false);
    }
  }

  // Remove applied discount
  void removeAppliedDiscount() {
    _appliedDiscount = null;
    notifyListeners();
  }

  // Update user eco points
  void updateUserEcoPoints(int points) {
    _userEcoPoints = points;
    notifyListeners();
  }

  // Initialize sample discounts
  Future<void> initializeSampleDiscounts() async {
    try {
      print('🔄 Initializing sample discounts...');
      await EcoDiscountsService.initializeSampleDiscounts();
      await loadActiveDiscounts();
      print('✅ Sample discounts initialized');
    } catch (e) {
      print('❌ Error initializing sample discounts: $e');
    }
  }

  // Calculate best discount for order
  EcoDiscount? getBestDiscountForOrder(double orderAmount, String category) {
    final eligibleDiscounts = _discounts.where((d) => 
      d.isAvailable &&
      d.minEcoPoints <= _userEcoPoints &&
      (d.applicableCategory == 'ALL' || d.applicableCategory == category) &&
      orderAmount >= d.minPurchaseAmount
    ).toList();

    if (eligibleDiscounts.isEmpty) return null;

    // Sort by discount amount (descending)
    eligibleDiscounts.sort((a, b) => 
      b.calculateDiscount(orderAmount).compareTo(a.calculateDiscount(orderAmount))
    );

    return eligibleDiscounts.first;
  }

  // Clear all data
  void clearAllData() {
    _discounts.clear();
    _appliedDiscount = null;
    _userEcoPoints = 0;
    _currentUserId = null;
    _error = null;
    notifyListeners();
  }
}
