import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class WishlistService {
  static const String _baseUrl = FirebaseConfig.baseApiUrl;
  static const String _wishlistEndpoint = '/api/wishlist';

  // Add item to wishlist
  static Future<Map<String, dynamic>> addToWishlist({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    String? imageUrl,
    String? category,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_wishlistEndpoint/add'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'productId': productId,
          'productName': productName,
          'price': price,
          'imageUrl': imageUrl ?? '',
          'category': category ?? 'General',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to add to wishlist: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding to wishlist: $e',
      };
    }
  }

  // Remove item from wishlist
  static Future<Map<String, dynamic>> removeFromWishlist(String userId, String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$_wishlistEndpoint/remove?userId=$userId&productId=$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to remove from wishlist: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error removing from wishlist: $e',
      };
    }
  }

  // Get user wishlist
  static Future<List<Map<String, dynamic>>> getUserWishlist(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_wishlistEndpoint/user/$userId'),
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
      print('Error getting user wishlist: $e');
      return [];
    }
  }

  // Check if item is in wishlist
  static Future<bool> isInWishlist(String userId, String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_wishlistEndpoint/check?userId=$userId&productId=$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['isInWishlist'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Error checking wishlist status: $e');
      return false;
    }
  }

  // Get wishlist count
  static Future<int> getWishlistCount(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_wishlistEndpoint/count/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['count'] ?? 0;
      } else {
        return 0;
      }
    } catch (e) {
      print('Error getting wishlist count: $e');
      return 0;
    }
  }

  // Clear wishlist
  static Future<Map<String, dynamic>> clearWishlist(String userId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$_wishlistEndpoint/clear/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to clear wishlist: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error clearing wishlist: $e',
      };
    }
  }

  // Get wishlist statistics
  static Future<Map<String, dynamic>> getWishlistStatistics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_wishlistEndpoint/stats/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'totalItems': 0,
          'totalValue': 0.0,
          'categories': [],
        };
      }
    } catch (e) {
      print('Error getting wishlist statistics: $e');
      return {
        'totalItems': 0,
        'totalValue': 0.0,
        'categories': [],
      };
    }
  }

  // Move wishlist item to cart
  static Future<Map<String, dynamic>> moveToCart(String userId, String productId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl$_wishlistEndpoint/move-to-cart?userId=$userId&productId=$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to move to cart: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error moving to cart: $e',
      };
    }
  }

  // Get wishlist by category
  static Future<List<Map<String, dynamic>>> getWishlistByCategory(String userId, String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_wishlistEndpoint/category/$userId?category=$category'),
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
      print('Error getting wishlist by category: $e');
      return [];
    }
  }

  // Get recently added wishlist items
  static Future<List<Map<String, dynamic>>> getRecentWishlistItems(String userId, {int limit = 10}) async {
    try {
      final allItems = await getUserWishlist(userId);
      // Sort by addedAt (createdAt) and limit
      allItems.sort((a, b) {
        final aDate = DateTime.tryParse(a['addedAt'] ?? '') ?? DateTime.now();
        final bDate = DateTime.tryParse(b['addedAt'] ?? '') ?? DateTime.now();
        return bDate.compareTo(aDate);
      });
      return allItems.take(limit).toList();
    } catch (e) {
      print('Error getting recent wishlist items: $e');
      return [];
    }
  }

  // Share wishlist
  static Future<Map<String, dynamic>> shareWishlist(String userId) async {
    // For now, return a placeholder response
    // This could be implemented with a sharing service in the future
    return {
      'success': true,
      'message': 'Wishlist sharing feature coming soon',
      'shareUrl': 'https://ecobazaar.com/wishlist/$userId',
    };
  }

  // Get wishlist recommendations
  static Future<List<Map<String, dynamic>>> getWishlistRecommendations(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_wishlistEndpoint/recommendations/$userId'),
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
      print('Error getting wishlist recommendations: $e');
      return [];
    }
  }

  // Update wishlist item
  static Future<Map<String, dynamic>> updateWishlistItem({
    required String userId,
    required String productId,
    String? notes,
    int? priority,
  }) async {
    // For now, return a placeholder response
    // This could be implemented with additional fields in the WishlistItem entity
    return {
      'success': true,
      'message': 'Wishlist item update feature coming soon',
    };
  }

  // Get wishlist analytics
  static Future<Map<String, dynamic>> getWishlistAnalytics(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_wishlistEndpoint/analytics/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'totalItems': 0,
          'totalValue': 0.0,
          'averagePrice': 0.0,
          'mostAddedCategory': '',
          'itemsAddedThisMonth': 0,
        };
      }
    } catch (e) {
      print('Error getting wishlist analytics: $e');
      return {
        'totalItems': 0,
        'totalValue': 0.0,
        'averagePrice': 0.0,
        'mostAddedCategory': '',
        'itemsAddedThisMonth': 0,
      };
    }
  }

  // Initialize sample wishlist items for new users
  static Future<void> initializeSampleWishlistItems(String userId) async {
    // For now, this is a placeholder that does nothing
    // In the future, this could create sample wishlist items via API call
    print('Initializing sample wishlist items for user: $userId');
    // Could add sample products here if needed
  }
}