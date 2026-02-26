import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class CartService {
  static const String _baseUrl = FirebaseConfig.baseApiUrl;
  static const String _cartEndpoint = '/api/cart';

  // Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required String userId,
    required String productId,
    required String productName,
    required double productPrice,
    required String productImage,
    required String productCategory,
    required int quantity,
    required double carbonFootprint,
  }) async {
    try {
      final url = '$_baseUrl$_cartEndpoint/add';
      final requestBody = {
        'userId': userId,
        'productId': productId,
        'productName': productName,
        'productPrice': productPrice,
        'productImage': productImage,
        'productCategory': productCategory,
        'quantity': quantity,
        'carbonFootprint': carbonFootprint,
      };
      
      print('Cart: Adding item to cart');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Cart: Successfully added item');
        return result;
      } else {
        print('Cart: Failed to add item - ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to add item to cart',
        };
      }
    } catch (e) {
      print('Cart: Error adding to cart - $e');
      return {
        'success': false,
        'message': 'Error adding to cart: $e',
      };
    }
  }

  // Remove item from cart
  static Future<Map<String, dynamic>> removeFromCart({
    required String userId,
    required String productId,
  }) async {
    try {
      print('Cart: Removing item - userId: $userId, productId: $productId');
      
      final response = await http.delete(
        Uri.parse('$_baseUrl$_cartEndpoint/remove?userId=$userId&productId=$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Cart: Successfully removed item');
        return result;
      } else {
        print('Cart: Failed to remove item - ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to remove item from cart',
        };
      }
    } catch (e) {
      print('Cart: Error removing from cart - $e');
      return {
        'success': false,
        'message': 'Error removing from cart: $e',
      };
    }
  }

  // Update cart item quantity
  static Future<Map<String, dynamic>> updateCartItemQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    try {
      print('Cart: Updating quantity - userId: $userId, productId: $productId, quantity: $quantity');
      
      final response = await http.put(
        Uri.parse('$_baseUrl$_cartEndpoint/update'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'userId': userId,
          'productId': productId,
          'quantity': quantity,
        }),
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Cart: Successfully updated quantity');
        return result;
      } else {
        print('Cart: Failed to update quantity - ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to update cart item quantity',
        };
      }
    } catch (e) {
      print('Cart: Error updating quantity - $e');
      return {
        'success': false,
        'message': 'Error updating cart item quantity: $e',
      };
    }
  }

  // Get user's cart
  static Future<List<Map<String, dynamic>>> getUserCart(String userId) async {
    try {
      print('Cart: Getting cart for userId: $userId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl$_cartEndpoint/user/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Cart: Get cart response - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print('Cart: Get cart success - ${data.length} items found');
        return data.cast<Map<String, dynamic>>();
      } else {
        print('Cart: Get cart failed - ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Cart: Get cart error - $e');
      return [];
    }
  }

  // Get cart summary
  static Future<Map<String, dynamic>> getCartSummary(String userId) async {
    try {
      print('Cart: Getting cart summary for userId: $userId');
      
      final response = await http.get(
        Uri.parse('$_baseUrl$_cartEndpoint/summary/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('Cart: Get cart summary response - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Cart: Get cart summary success - $result');
        return result;
      } else {
        print('Cart: Get cart summary failed - ${response.statusCode}: ${response.body}');
        return {
          'totalAmount': 0,
          'totalItems': 0,
          'totalQuantity': 0,
          'totalCarbonFootprint': 0,
          'userId': userId,
        };
      }
    } catch (e) {
      print('Cart: Get cart summary error - $e');
      return {
        'totalAmount': 0,
        'totalItems': 0,
        'totalQuantity': 0,
        'totalCarbonFootprint': 0,
        'userId': userId,
      };
    }
  }

  // Clear cart
  static Future<Map<String, dynamic>> clearCart(String userId) async {
    try {
      print('Cart: Clearing cart for userId: $userId');
      
      final response = await http.delete(
        Uri.parse('$_baseUrl$_cartEndpoint/clear/$userId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );
      
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('Cart: Successfully cleared cart');
        return result;
      } else {
        print('Cart: Failed to clear cart - ${response.statusCode}');
        return {
          'success': false,
          'message': 'Failed to clear cart',
        };
      }
    } catch (e) {
      print('Cart: Error clearing cart - $e');
      return {
        'success': false,
        'message': 'Error clearing cart: $e',
      };
    }
  }
}