import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/firebase_config.dart';

class EcoDiscountData {
  final String id;
  final String title;
  final String description;
  final String discountType; // PERCENTAGE, FIXED_AMOUNT, FREE_SHIPPING
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
  final DateTime? createdAt;
  final DateTime? updatedAt;

  EcoDiscountData({
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
    this.createdAt,
    this.updatedAt,
  });

  factory EcoDiscountData.fromMap(Map<String, dynamic> map) {
    return EcoDiscountData(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      discountType: map['discountType']?.toString() ?? 'PERCENTAGE',
      discountValue: map['discountValue']?.toDouble() ?? 0.0,
      minPurchaseAmount: map['minPurchaseAmount']?.toDouble() ?? 0.0,
      maxDiscountAmount: map['maxDiscountAmount']?.toDouble() ?? 0.0,
      minEcoPoints: map['minEcoPoints']?.toInt() ?? 0,
      applicableCategory: map['applicableCategory']?.toString() ?? 'ALL',
      promoCode: map['promoCode']?.toString(),
      startDate: map['startDate'] != null ? DateTime.tryParse(map['startDate']) : null,
      endDate: map['endDate'] != null ? DateTime.tryParse(map['endDate']) : null,
      isActive: map['isActive'] ?? true,
      usageLimit: map['usageLimit']?.toInt() ?? 1000,
      currentUsageCount: map['currentUsageCount']?.toInt() ?? 0,
      conditions: map['conditions']?.toString(),
      createdAt: map['createdAt'] != null ? DateTime.tryParse(map['createdAt']) : null,
      updatedAt: map['updatedAt'] != null ? DateTime.tryParse(map['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'discountType': discountType,
      'discountValue': discountValue,
      'minPurchaseAmount': minPurchaseAmount,
      'maxDiscountAmount': maxDiscountAmount,
      'minEcoPoints': minEcoPoints,
      'applicableCategory': applicableCategory,
      'promoCode': promoCode,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'isActive': isActive,
      'usageLimit': usageLimit,
      'currentUsageCount': currentUsageCount,
      'conditions': conditions,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class EcoDiscountsService {
  static const String baseUrl = '${FirebaseConfig.baseApiUrl}/api/eco-discounts';

  // Get all active eco discounts
  static Future<List<EcoDiscountData>> getActiveDiscounts() async {
    try {
      print('🔄 Fetching active eco discounts from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/active'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final discounts = data.map((json) => EcoDiscountData.fromMap(json)).toList();
        print('✅ Loaded ${discounts.length} active eco discounts');
        return discounts;
      } else {
        print('❌ Failed to fetch active discounts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching active discounts: $e');
      return [];
    }
  }

  // Get eligible discounts for user
  static Future<List<EcoDiscountData>> getEligibleDiscounts(String userId, int userEcoPoints) async {
    try {
      print('🔄 Fetching eligible discounts from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/eligible/$userId?ecoPoints=$userEcoPoints'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final discounts = data.map((json) => EcoDiscountData.fromMap(json)).toList();
        print('✅ Loaded ${discounts.length} eligible eco discounts');
        return discounts;
      } else {
        print('❌ Failed to fetch eligible discounts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching eligible discounts: $e');
      return [];
    }
  }

  // Apply discount to order
  static Future<Map<String, dynamic>> applyDiscount({
    required String discountId,
    required String userId,
    required String orderId,
    required double orderAmount,
  }) async {
    try {
      print('🔄 Applying discount from backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/$discountId/apply'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'orderId': orderId,
          'orderAmount': orderAmount,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Discount applied: ${data['discountAmount']}');
        return data;
      } else {
        print('❌ Failed to apply discount: ${response.statusCode}');
        throw Exception('Failed to apply discount: ${response.body}');
      }
    } catch (e) {
      print('❌ Error applying discount: $e');
      rethrow;
    }
  }

  // Validate promo code
  static Future<Map<String, dynamic>> validatePromoCode(String promoCode, String userId) async {
    try {
      print('🔄 Validating promo code from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/promo/$promoCode/validate?userId=$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Promo code validated');
        return data;
      } else {
        print('❌ Promo code validation failed: ${response.statusCode}');
        throw Exception('Invalid promo code');
      }
    } catch (e) {
      print('❌ Error validating promo code: $e');
      rethrow;
    }
  }

  // Get discount by category
  static Future<List<EcoDiscountData>> getDiscountsByCategory(String category) async {
    try {
      print('🔄 Fetching discounts by category from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final discounts = data.map((json) => EcoDiscountData.fromMap(json)).toList();
        print('✅ Loaded ${discounts.length} discounts for category: $category');
        return discounts;
      } else {
        print('❌ Failed to fetch category discounts: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching category discounts: $e');
      return [];
    }
  }

  // Initialize sample discounts
  static Future<bool> initializeSampleDiscounts() async {
    try {
      print('🔄 Initializing sample discounts in backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/initialize-sample-data'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Sample discounts initialized successfully');
        return true;
      } else {
        print('❌ Failed to initialize sample discounts: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing sample discounts: $e');
      return false;
    }
  }
}
