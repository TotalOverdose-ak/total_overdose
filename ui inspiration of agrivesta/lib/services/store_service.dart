import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class StoreService {
  static const String _baseUrl = FirebaseConfig.baseApiUrl;
  static const String _storesEndpoint = '/stores';

  // Create store
  static Future<Map<String, dynamic>> createStore({
    required String name,
    required String description,
    required String category,
    required String ownerId,
    String? imageUrl,
    String? address,
    String? phone,
    String? email,
    String? authToken,
  }) async {
    try {
      final headers = {
        'Content-Type': 'application/json',
      };
      
      if (authToken != null) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http.post(
        Uri.parse('$_baseUrl$_storesEndpoint'),
        headers: headers,
        body: jsonEncode({
          'storeName': name,
          'description': description,
          'category': category,
          'ownerId': ownerId,
          'ownerEmail': email ?? 'store@ecobazaar.com',
          'contactPhone': phone ?? '',
          'address': address ?? '',
          'city': '',
          'state': '',
          'pincode': '',
          'isActive': true,
          'isVerified': false,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to create store: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error creating store: $e',
      };
    }
  }

  // Get all stores
  static Future<List<Map<String, dynamic>>> getAllStores() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_storesEndpoint'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting all stores: $e');
      return [];
    }
  }

  // Get store by ID
  static Future<Map<String, dynamic>?> getStoreById(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_storesEndpoint/$storeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      print('Error getting store by ID: $e');
      return null;
    }
  }

  // Get stores by owner
  static Future<List<Map<String, dynamic>>> getStoresByOwner(String ownerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_storesEndpoint/owner/$ownerId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting stores by owner: $e');
      return [];
    }
  }

  // Update store
  static Future<Map<String, dynamic>> updateStore({
    required String storeId,
    String? name,
    String? description,
    String? category,
    String? ownerId,
    String? imageUrl,
    String? address,
    String? phone,
    String? email,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$_storesEndpoint/$storeId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'storeName': name,
          'description': description,
          'category': category,
          'ownerId': ownerId,
          'ownerEmail': email,
          'contactPhone': phone,
          'address': address,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update store: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating store: $e',
      };
    }
  }

  // Delete store
  static Future<Map<String, dynamic>> deleteStore(String storeId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$_storesEndpoint/$storeId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to delete store: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting store: $e',
      };
    }
  }

  // Search stores
  static Future<List<Map<String, dynamic>>> searchStores(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_storesEndpoint/search?query=$query'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error searching stores: $e');
      return [];
    }
  }

  // Get stores by category
  static Future<List<Map<String, dynamic>>> getStoresByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_storesEndpoint/category/$category'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      print('Error getting stores by category: $e');
      return [];
    }
  }

  // Get store statistics
  static Future<Map<String, dynamic>> getStoreStatistics(String storeId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_storesEndpoint/$storeId/stats'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'totalProducts': 0,
          'totalOrders': 0,
          'totalRevenue': 0.0,
          'averageRating': 0.0,
        };
      }
    } catch (e) {
      print('Error getting store statistics: $e');
      return {
        'totalProducts': 0,
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'averageRating': 0.0,
      };
    }
  }

  // Get store categories
  static Future<List<String>> getStoreCategories() async {
    // TODO: Implement with Spring Boot API
    return [
      'Grocery Store',
      'Fashion Store',
      'Electronics Store',
      'Home & Garden',
      'Health & Beauty',
      'Sports & Outdoors',
      'Bookstore',
      'Restaurant',
    ];
  }
}