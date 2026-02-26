import 'package:flutter/material.dart';
import '../services/carbon_footprint_service.dart';

class CarbonPurchase {
  final String orderId;
  final String customerId;
  final String customerName;
  final double totalAmount;
  final double totalCarbonSaved;
  final Map<String, double> carbonByCategory;
  final List<Map<String, dynamic>> items;
  final DateTime timestamp;

  CarbonPurchase({
    required this.orderId,
    required this.customerId,
    required this.customerName,
    required this.totalAmount,
    required this.totalCarbonSaved,
    required this.carbonByCategory,
    required this.items,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() {
    return {
      'orderId': orderId,
      'customerId': customerId,
      'customerName': customerName,
      'totalAmount': totalAmount,
      'totalCarbonSaved': totalCarbonSaved,
      'carbonByCategory': carbonByCategory,
      'items': items,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  factory CarbonPurchase.fromJson(Map<String, dynamic> json) {
    return CarbonPurchase(
      orderId: json['orderId'],
      customerId: json['customerId'],
      customerName: json['customerName'],
      totalAmount: json['totalAmount'].toDouble(),
      totalCarbonSaved: json['totalCarbonSaved'].toDouble(),
      carbonByCategory: Map<String, double>.from(json['carbonByCategory']),
      items: List<Map<String, dynamic>>.from(json['items']),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class CarbonTrackingProvider with ChangeNotifier {
  final List<CarbonPurchase> _purchases = [];
  final Map<String, double> _categoryCarbonTotals = {};
  double _totalCarbonSaved = 0.0;
  double _monthlyCarbonSaved = 0.0;
  int _totalOrders = 0;
  double _totalRevenue = 0.0;

  // Getters
  List<CarbonPurchase> get purchases => [..._purchases];
  Map<String, double> get categoryCarbonTotals => {..._categoryCarbonTotals};
  double get totalCarbonSaved => _totalCarbonSaved;
  double get monthlyCarbonSaved => _monthlyCarbonSaved;
  int get totalOrders => _totalOrders;
  double get totalRevenue => _totalRevenue;

  // Get carbon savings for the current month
  double get currentMonthCarbonSaved {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    return _purchases
        .where((purchase) => purchase.timestamp.isAfter(currentMonth))
        .fold(0.0, (sum, purchase) => sum + purchase.totalCarbonSaved);
  }

  // Get carbon savings for the current year
  double get currentYearCarbonSaved {
    final now = DateTime.now();
    final currentYear = DateTime(now.year);
    
    return _purchases
        .where((purchase) => purchase.timestamp.isAfter(currentYear))
        .fold(0.0, (sum, purchase) => sum + purchase.totalCarbonSaved);
  }

  // Get recent purchases (last 30 days)
  List<CarbonPurchase> get recentPurchases {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
    return _purchases
        .where((purchase) => purchase.timestamp.isAfter(thirtyDaysAgo))
        .toList();
  }

  // Get carbon savings by category for the current month
  Map<String, double> get currentMonthCarbonByCategory {
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    
    Map<String, double> categoryTotals = {};
    
    for (var purchase in _purchases) {
      if (purchase.timestamp.isAfter(currentMonth)) {
        purchase.carbonByCategory.forEach((category, carbon) {
          categoryTotals[category] = (categoryTotals[category] ?? 0.0) + carbon;
        });
      }
    }
    
    return categoryTotals;
  }

  // Add a new purchase and update totals
  void addPurchase(CarbonPurchase purchase) {
    _purchases.add(purchase);
    _updateTotals();
    notifyListeners();
  }

  // Add purchase from cart data
  void addPurchaseFromCart({
    required String orderId,
    required String customerId,
    required String customerName,
    required Map<String, dynamic> cartSummary,
  }) {
    final purchase = CarbonPurchase(
      orderId: orderId,
      customerId: customerId,
      customerName: customerName,
      totalAmount: cartSummary['totalAmount'].toDouble(),
      totalCarbonSaved: cartSummary['totalCarbonSaved'].toDouble(),
      carbonByCategory: Map<String, double>.from(cartSummary['carbonByCategory']),
      items: List<Map<String, dynamic>>.from(cartSummary['items']),
      timestamp: DateTime.now(),
    );

    addPurchase(purchase);
  }

  // Update totals based on all purchases
  void _updateTotals() {
    _totalCarbonSaved = _purchases.fold(0.0, (sum, purchase) => sum + purchase.totalCarbonSaved);
    _totalOrders = _purchases.length;
    _totalRevenue = _purchases.fold(0.0, (sum, purchase) => sum + purchase.totalAmount);
    
    // Calculate monthly carbon saved
    final now = DateTime.now();
    final currentMonth = DateTime(now.year, now.month);
    _monthlyCarbonSaved = _purchases
        .where((purchase) => purchase.timestamp.isAfter(currentMonth))
        .fold(0.0, (sum, purchase) => sum + purchase.totalCarbonSaved);

    // Calculate category totals
    _categoryCarbonTotals.clear();
    for (var purchase in _purchases) {
      purchase.carbonByCategory.forEach((category, carbon) {
        _categoryCarbonTotals[category] = (_categoryCarbonTotals[category] ?? 0.0) + carbon;
      });
    }
  }

  // Get carbon savings trend (last 7 days)
  List<Map<String, dynamic>> get weeklyCarbonTrend {
    final List<Map<String, dynamic>> trend = [];
    final now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayCarbon = _purchases
          .where((purchase) => 
              purchase.timestamp.isAfter(dayStart) && 
              purchase.timestamp.isBefore(dayEnd))
          .fold(0.0, (sum, purchase) => sum + purchase.totalCarbonSaved);
      
      trend.add({
        'date': date,
        'carbonSaved': dayCarbon,
        'dayName': _getDayName(date.weekday),
      });
    }
    
    return trend;
  }

  // Get carbon savings trend (last 30 days)
  List<Map<String, dynamic>> get monthlyCarbonTrend {
    final List<Map<String, dynamic>> trend = [];
    final now = DateTime.now();
    
    for (int i = 29; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final dayStart = DateTime(date.year, date.month, date.day);
      final dayEnd = dayStart.add(const Duration(days: 1));
      
      final dayCarbon = _purchases
          .where((purchase) => 
              purchase.timestamp.isAfter(dayStart) && 
              purchase.timestamp.isBefore(dayEnd))
          .fold(0.0, (sum, purchase) => sum + purchase.totalCarbonSaved);
      
      trend.add({
        'date': date,
        'carbonSaved': dayCarbon,
        'dayName': '${date.day}/${date.month}',
      });
    }
    
    return trend;
  }

  // Get top customers by carbon savings
  List<Map<String, dynamic>> get topCustomersByCarbonSavings {
    final Map<String, double> customerCarbon = {};
    
    for (var purchase in _purchases) {
      customerCarbon[purchase.customerName] = 
          (customerCarbon[purchase.customerName] ?? 0.0) + purchase.totalCarbonSaved;
    }
    
    final sortedCustomers = customerCarbon.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCustomers.take(10).map((entry) => {
      'customerName': entry.key,
      'carbonSaved': entry.value,
    }).toList();
  }

  // Get top categories by carbon savings
  List<Map<String, dynamic>> get topCategoriesByCarbonSavings {
    final sortedCategories = _categoryCarbonTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sortedCategories.map((entry) => {
      'category': entry.key,
      'carbonSaved': entry.value,
    }).toList();
  }

  // Get environmental impact statistics
  Map<String, dynamic> get environmentalImpactStats {
    final treesEquivalent = _totalCarbonSaved * 50; // 1kg CO2 = 50 trees
    final carKmEquivalent = _totalCarbonSaved * 2.5; // 1kg CO2 = 2.5 km car travel
    final electricityEquivalent = _totalCarbonSaved * 0.5; // 1kg CO2 = 0.5 kWh
    
    return {
      'treesEquivalent': treesEquivalent,
      'carKmEquivalent': carKmEquivalent,
      'electricityEquivalent': electricityEquivalent,
      'totalCarbonSaved': _totalCarbonSaved,
      'monthlyCarbonSaved': _monthlyCarbonSaved,
      'yearlyCarbonSaved': currentYearCarbonSaved,
    };
  }

  // Helper method to get day name
  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  // Load user's carbon footprint history from backend
  Future<void> loadUserHistory(String userId) async {
    try {
      print('🔄 Loading carbon history from backend for user: $userId');
      final history = await CarbonFootprintService.getUserHistory(userId);
      
      _purchases.clear();
      for (var record in history) {
        final purchase = CarbonPurchase(
          orderId: record['id']?.toString() ?? '',
          customerId: record['userId']?.toString() ?? userId,
          customerName: record['productName']?.toString() ?? 'Unknown',
          totalAmount: 0.0, // Not tracked in carbon footprint
          totalCarbonSaved: record['carbonSavings']?.toDouble() ?? 0.0,
          carbonByCategory: {
            record['category']?.toString() ?? 'General': record['carbonSavings']?.toDouble() ?? 0.0,
          },
          items: [],
          timestamp: record['calculatedAt'] != null 
              ? DateTime.parse(record['calculatedAt']) 
              : DateTime.now(),
        );
        _purchases.add(purchase);
      }
      
      _updateTotals();
      notifyListeners();
      print('✅ Loaded ${_purchases.length} carbon footprint records');
    } catch (e) {
      print('❌ Error loading carbon history: $e');
    }
  }

  // Load user's carbon statistics from backend
  Future<Map<String, dynamic>> loadUserStatistics(String userId) async {
    try {
      print('🔄 Loading carbon statistics from backend for user: $userId');
      final stats = await CarbonFootprintService.getUserStatistics(userId);
      print('✅ Loaded carbon statistics');
      return stats;
    } catch (e) {
      print('❌ Error loading carbon statistics: $e');
      return {};
    }
  }

  // Calculate carbon footprint for a product using backend
  Future<Map<String, dynamic>> calculateProductCarbonFootprint({
    required String userId,
    required String productId,
    required String productName,
    required String category,
    required String materials,
    required double weight,
    required String transportMode,
    required double transportDistance,
    required String manufacturingType,
    required String packagingType,
    required double packagingWeight,
    required String disposalMethod,
  }) async {
    try {
      print('🔄 Calculating carbon footprint from backend...');
      final result = await CarbonFootprintService.calculateCarbonFootprint(
        userId: userId,
        productId: productId,
        productName: productName,
        category: category,
        materials: materials,
        weight: weight,
        transportMode: transportMode,
        transportDistance: transportDistance,
        manufacturingType: manufacturingType,
        packagingType: packagingType,
        packagingWeight: packagingWeight,
        disposalMethod: disposalMethod,
      );
      
      print('✅ Carbon footprint calculated: ${result['totalCarbonFootprint']} kg CO2');
      return result;
    } catch (e) {
      print('❌ Error calculating carbon footprint: $e');
      rethrow;
    }
  }

  // Initialize emission factors in backend
  Future<void> initializeEmissionFactors() async {
    try {
      await CarbonFootprintService.initializeEmissionFactors();
    } catch (e) {
      print('❌ Error initializing emission factors: $e');
    }
  }

  // Clear all data (for testing/reset)
  void clearAllData() {
    _purchases.clear();
    _categoryCarbonTotals.clear();
    _totalCarbonSaved = 0.0;
    _monthlyCarbonSaved = 0.0;
    _totalOrders = 0;
    _totalRevenue = 0.0;
    notifyListeners();
  }

  // Load sample data for demonstration
  void loadSampleData() {
    final samplePurchases = [
      CarbonPurchase(
        orderId: 'ECO001',
        customerId: 'CUST001',
        customerName: 'John Doe',
        totalAmount: 2156.0,
        totalCarbonSaved: 1.2,
        carbonByCategory: {
          'Food & Beverages': 0.5,
          'Clothing & Fashion': 0.4,
          'Home & Garden': 0.3,
        },
        items: [
          {
            'id': '1',
            'name': 'Organic Cotton T-Shirt',
            'quantity': 1,
            'price': 899.0,
            'totalPrice': 899.0,
            'category': 'Clothing & Fashion',
            'carbonFootprint': 0.4,
            'totalCarbonSaved': 0.4,
          },
          {
            'id': '2',
            'name': 'Bamboo Water Bottle',
            'quantity': 2,
            'price': 599.0,
            'totalPrice': 1198.0,
            'category': 'Home & Garden',
            'carbonFootprint': 0.3,
            'totalCarbonSaved': 0.6,
          },
          {
            'id': '3',
            'name': 'Reusable Shopping Bag',
            'quantity': 1,
            'price': 299.0,
            'totalPrice': 299.0,
            'category': 'Home & Garden',
            'carbonFootprint': 0.2,
            'totalCarbonSaved': 0.2,
          },
        ],
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      CarbonPurchase(
        orderId: 'ECO002',
        customerId: 'CUST002',
        customerName: 'Jane Smith',
        totalAmount: 1899.0,
        totalCarbonSaved: 0.8,
        carbonByCategory: {
          'Food & Beverages': 0.3,
          'Electronics': 0.5,
        },
        items: [
          {
            'id': '4',
            'name': 'Solar Power Bank',
            'quantity': 1,
            'price': 1899.0,
            'totalPrice': 1899.0,
            'category': 'Electronics',
            'carbonFootprint': 0.8,
            'totalCarbonSaved': 0.8,
          },
        ],
        timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      ),
    ];

    for (var purchase in samplePurchases) {
      addPurchase(purchase);
    }
  }
}
