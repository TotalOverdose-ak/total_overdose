import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalEcoDiscountsService {
  static const String _discountsKey = 'eco_discounts';
  static const String _userDiscountsKey = 'user_discounts';

  // Initialize with sample discounts
  static Future<void> initializeSampleDiscounts() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if discounts already exist
    final existingDiscounts = prefs.getString(_discountsKey);
    if (existingDiscounts != null) return;
    
    final sampleDiscounts = [
      {
        'id': '1',
        'title': 'Eco Warrior 10% Off',
        'description': 'Get 10% discount on eco-friendly products for completing eco challenges',
        'discountType': 'percentage',
        'discountValue': 10.0,
        'minEcoPoints': 100,
        'minOrderAmount': 500.0,
        'maxDiscountAmount': 200.0,
        'validFrom': DateTime.now().millisecondsSinceEpoch,
        'validUntil': DateTime.now().add(const Duration(days: 30)).millisecondsSinceEpoch,
        'isActive': true,
        'usageLimit': 100,
        'usedCount': 0,
        'applicableCategories': ['Eco-Friendly', 'Sustainable'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': '2',
        'title': 'Green Champion ₹50 Off',
        'description': 'Flat ₹50 off on orders above ₹1000 for eco challenge completers',
        'discountType': 'fixed',
        'discountValue': 50.0,
        'minEcoPoints': 200,
        'minOrderAmount': 1000.0,
        'maxDiscountAmount': 50.0,
        'validFrom': DateTime.now().millisecondsSinceEpoch,
        'validUntil': DateTime.now().add(const Duration(days: 60)).millisecondsSinceEpoch,
        'isActive': true,
        'usageLimit': 50,
        'usedCount': 5,
        'applicableCategories': ['All'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      {
        'id': '3',
        'title': 'Sustainability Hero 15% Off',
        'description': 'Special 15% discount for users with 500+ eco points',
        'discountType': 'percentage',
        'discountValue': 15.0,
        'minEcoPoints': 500,
        'minOrderAmount': 800.0,
        'maxDiscountAmount': 300.0,
        'validFrom': DateTime.now().millisecondsSinceEpoch,
        'validUntil': DateTime.now().add(const Duration(days: 90)).millisecondsSinceEpoch,
        'isActive': true,
        'usageLimit': 25,
        'usedCount': 2,
        'applicableCategories': ['Eco-Friendly', 'Green Living'],
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
    ];
    
    await prefs.setString(_discountsKey, json.encode(sampleDiscounts));
  }

  // Get all discounts
  static Future<List<Map<String, dynamic>>> getAllDiscounts() async {
    await initializeSampleDiscounts();
    final prefs = await SharedPreferences.getInstance();
    final discountsData = prefs.getString(_discountsKey) ?? '[]';
    final List<dynamic> discountsList = json.decode(discountsData);
    return discountsList.cast<Map<String, dynamic>>();
  }

  // Get active discounts
  static Future<List<Map<String, dynamic>>> getActiveDiscounts() async {
    final allDiscounts = await getAllDiscounts();
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return allDiscounts.where((discount) {
      return discount['isActive'] == true &&
             discount['validFrom'] <= now &&
             discount['validUntil'] >= now &&
             discount['usedCount'] < discount['usageLimit'];
    }).toList();
  }

  // Get eligible discounts for user
  static Future<List<Map<String, dynamic>>> getEligibleDiscounts(String userId, int userEcoPoints, double orderAmount) async {
    final activeDiscounts = await getActiveDiscounts();
    
    return activeDiscounts.where((discount) {
      return userEcoPoints >= (discount['minEcoPoints'] ?? 0) &&
             orderAmount >= (discount['minOrderAmount'] ?? 0);
    }).toList();
  }

  // Get discount by ID
  static Future<Map<String, dynamic>?> getDiscountById(String discountId) async {
    final allDiscounts = await getAllDiscounts();
    try {
      return allDiscounts.firstWhere((discount) => discount['id'] == discountId);
    } catch (e) {
      return null;
    }
  }

  // Create new discount
  static Future<bool> createDiscount(Map<String, dynamic> discountData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allDiscounts = await getAllDiscounts();
      
      final newDiscount = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'createdAt': DateTime.now().millisecondsSinceEpoch,
        'usedCount': 0,
        ...discountData,
      };
      
      allDiscounts.add(newDiscount);
      await prefs.setString(_discountsKey, json.encode(allDiscounts));
      return true;
    } catch (e) {
      print('Error creating discount: $e');
      return false;
    }
  }

  // Update discount
  static Future<bool> updateDiscount(String discountId, Map<String, dynamic> discountData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allDiscounts = await getAllDiscounts();
      
      final index = allDiscounts.indexWhere((discount) => discount['id'] == discountId);
      if (index == -1) return false;
      
      allDiscounts[index] = {
        ...allDiscounts[index],
        ...discountData,
        'id': discountId, // Ensure ID doesn't change
      };
      
      await prefs.setString(_discountsKey, json.encode(allDiscounts));
      return true;
    } catch (e) {
      print('Error updating discount: $e');
      return false;
    }
  }

  // Delete discount
  static Future<bool> deleteDiscount(String discountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final allDiscounts = await getAllDiscounts();
      
      allDiscounts.removeWhere((discount) => discount['id'] == discountId);
      await prefs.setString(_discountsKey, json.encode(allDiscounts));
      return true;
    } catch (e) {
      print('Error deleting discount: $e');
      return false;
    }
  }

  // Toggle discount status
  static Future<bool> toggleDiscountStatus(String discountId) async {
    try {
      final discount = await getDiscountById(discountId);
      if (discount == null) return false;
      
      discount['isActive'] = !(discount['isActive'] ?? false);
      return await updateDiscount(discountId, discount);
    } catch (e) {
      print('Error toggling discount status: $e');
      return false;
    }
  }

  // Apply discount to order
  static Future<Map<String, dynamic>?> applyDiscount(
    String discountId, 
    String userId, 
    double orderAmount,
    int userEcoPoints,
    List<String> productCategories,
  ) async {
    try {
      final discount = await getDiscountById(discountId);
      if (discount == null) return null;
      
      // Check if discount is eligible
      final now = DateTime.now().millisecondsSinceEpoch;
      if (discount['isActive'] != true ||
          discount['validFrom'] > now ||
          discount['validUntil'] < now ||
          discount['usedCount'] >= discount['usageLimit'] ||
          userEcoPoints < (discount['minEcoPoints'] ?? 0) ||
          orderAmount < (discount['minOrderAmount'] ?? 0)) {
        return null;
      }
      
      // Check category eligibility
      final applicableCategories = List<String>.from(discount['applicableCategories'] ?? []);
      if (!applicableCategories.contains('All') && 
          !productCategories.any((category) => applicableCategories.contains(category))) {
        return null;
      }
      
      // Calculate discount amount
      double discountAmount = 0;
      if (discount['discountType'] == 'percentage') {
        discountAmount = (orderAmount * discount['discountValue']) / 100;
        final maxDiscount = discount['maxDiscountAmount'] ?? double.infinity;
        if (discountAmount > maxDiscount) {
          discountAmount = maxDiscount;
        }
      } else if (discount['discountType'] == 'fixed') {
        discountAmount = discount['discountValue'].toDouble();
      }
      
      // Update usage count
      discount['usedCount'] = (discount['usedCount'] ?? 0) + 1;
      await updateDiscount(discountId, discount);
      
      // Record user discount usage
      await _recordUserDiscountUsage(userId, discountId);
      
      return {
        'discountId': discountId,
        'discountTitle': discount['title'],
        'discountAmount': discountAmount,
        'finalAmount': orderAmount - discountAmount,
        'appliedAt': DateTime.now().millisecondsSinceEpoch,
      };
    } catch (e) {
      print('Error applying discount: $e');
      return null;
    }
  }

  // Record user discount usage
  static Future<void> _recordUserDiscountUsage(String userId, String discountId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDiscountsData = prefs.getString('${_userDiscountsKey}_$userId') ?? '[]';
      final List<dynamic> userDiscounts = json.decode(userDiscountsData);
      
      userDiscounts.add({
        'discountId': discountId,
        'usedAt': DateTime.now().millisecondsSinceEpoch,
      });
      
      await prefs.setString('${_userDiscountsKey}_$userId', json.encode(userDiscounts));
    } catch (e) {
      print('Error recording user discount usage: $e');
    }
  }

  // Get user discount usage history
  static Future<List<Map<String, dynamic>>> getUserDiscountHistory(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDiscountsData = prefs.getString('${_userDiscountsKey}_$userId') ?? '[]';
      final List<dynamic> userDiscounts = json.decode(userDiscountsData);
      return userDiscounts.cast<Map<String, dynamic>>();
    } catch (e) {
      print('Error getting user discount history: $e');
      return [];
    }
  }

  // Get discount statistics
  static Future<Map<String, dynamic>> getDiscountStatistics() async {
    try {
      final allDiscounts = await getAllDiscounts();
      final activeDiscounts = allDiscounts.where((d) => d['isActive'] == true).length;
      final totalUsage = allDiscounts.fold<int>(0, (sum, d) => sum + ((d['usedCount'] ?? 0) as int));
      
      return {
        'totalDiscounts': allDiscounts.length,
        'activeDiscounts': activeDiscounts,
        'inactiveDiscounts': allDiscounts.length - activeDiscounts,
        'totalUsage': totalUsage,
      };
    } catch (e) {
      print('Error getting discount statistics: $e');
      return {
        'totalDiscounts': 0,
        'activeDiscounts': 0,
        'inactiveDiscounts': 0,
        'totalUsage': 0,
      };
    }
  }

  // Validate discount code (for future use)
  static Future<Map<String, dynamic>?> validateDiscountCode(String code) async {
    final allDiscounts = await getAllDiscounts();
    try {
      return allDiscounts.firstWhere((discount) => 
        discount['code']?.toLowerCase() == code.toLowerCase() &&
        discount['isActive'] == true
      );
    } catch (e) {
      return null;
    }
  }
}