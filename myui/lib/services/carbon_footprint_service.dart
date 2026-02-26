import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/firebase_config.dart';

class CarbonFootprintService {
  static const String baseUrl = '${FirebaseConfig.baseApiUrl}/api/carbon-footprint';

  // Calculate carbon footprint for a product
  static Future<Map<String, dynamic>> calculateCarbonFootprint({
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
      
      final response = await http.post(
        Uri.parse('$baseUrl/calculate'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'userId': userId,
          'productId': productId,
          'productName': productName,
          'category': category,
          'materials': materials,
          'weight': weight,
          'transportMode': transportMode,
          'transportDistance': transportDistance,
          'manufacturingType': manufacturingType,
          'packagingType': packagingType,
          'packagingWeight': packagingWeight,
          'disposalMethod': disposalMethod,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        print('✅ Carbon footprint calculated: ${data['totalCarbonFootprint']} kg CO2');
        return data;
      } else {
        print('❌ Failed to calculate carbon footprint: ${response.statusCode}');
        throw Exception('Failed to calculate carbon footprint: ${response.body}');
      }
    } catch (e) {
      print('❌ Error calculating carbon footprint: $e');
      rethrow;
    }
  }

  // Get user's carbon footprint history
  static Future<List<Map<String, dynamic>>> getUserHistory(String userId) async {
    try {
      print('🔄 Fetching user carbon history from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/history'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        print('✅ Loaded ${data.length} carbon footprint records');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('❌ Failed to fetch carbon history: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error fetching carbon history: $e');
      return [];
    }
  }

  // Get user's carbon statistics
  static Future<Map<String, dynamic>> getUserStatistics(String userId) async {
    try {
      print('🔄 Fetching user carbon statistics from backend...');
      
      final response = await http.get(
        Uri.parse('$baseUrl/user/$userId/statistics'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ Loaded carbon statistics');
        return data;
      } else {
        print('❌ Failed to fetch carbon statistics: ${response.statusCode}');
        return _getDefaultStatistics();
      }
    } catch (e) {
      print('❌ Error fetching carbon statistics: $e');
      return _getDefaultStatistics();
    }
  }

  // Initialize emission factors in backend
  static Future<bool> initializeEmissionFactors() async {
    try {
      print('🔄 Initializing emission factors in backend...');
      
      final response = await http.post(
        Uri.parse('$baseUrl/initialize-emission-factors'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Emission factors initialized successfully');
        return true;
      } else {
        print('❌ Failed to initialize emission factors: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing emission factors: $e');
      return false;
    }
  }

  // Check backend health
  static Future<bool> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Backend health check failed: $e');
      return false;
    }
  }

  // Default statistics when backend is unavailable
  static Map<String, dynamic> _getDefaultStatistics() {
    return {
      'totalCalculations': 0,
      'totalCarbonFootprint': 0.0,
      'totalCarbonSavings': 0.0,
      'averageCarbonFootprint': 0.0,
      'averageSavingsPercentage': 0.0,
      'totalTreesEquivalent': 0.0,
      'totalCarKmEquivalent': 0.0,
      'totalElectricityEquivalent': 0.0,
      'totalPlasticBottlesEquivalent': 0,
      'ecoRatingDistribution': {
        'A+': 0,
        'A': 0,
        'B': 0,
        'C': 0,
        'D': 0,
        'F': 0,
      },
      'categoryCarbonSavings': {},
      'monthlyTrend': [],
    };
  }
}
