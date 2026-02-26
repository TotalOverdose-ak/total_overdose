import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class ProductService {
  static const String _baseUrl = FirebaseConfig.baseApiUrl;
  static const String _productsEndpoint = '/products';

  // Add product
  static Future<Map<String, dynamic>> addProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required String category,
    required String storeId,
    required String storeName,
    String? imageUrl,
    String? icon,
    String? color,
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
        Uri.parse('$_baseUrl$_productsEndpoint'),
        headers: headers,
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'quantity': stock,
          'category': category,
          'storeId': storeId,
          'storeName': storeName,
          'imageUrl': imageUrl ?? '',
          'isActive': true,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to add product: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error adding product: $e',
      };
    }
  }

  // Get all products
  static Future<List<Map<String, dynamic>>> getAllProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_productsEndpoint'),
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
      print('Error getting all products: $e');
      return [];
    }
  }

  // Get products by category
  static Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_productsEndpoint/category/$category'),
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
      print('Error getting products by category: $e');
      return [];
    }
  }

  // Get product by ID
  static Future<Map<String, dynamic>?> getProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_productsEndpoint/$productId'),
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
      print('Error getting product by ID: $e');
      return null;
    }
  }

  // Update product
  static Future<Map<String, dynamic>> updateProduct({
    required String productId,
    String? name,
    String? description,
    double? price,
    int? stock,
    String? category,
    String? imageUrl,
    String? icon,
    String? color,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl$_productsEndpoint/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'description': description,
          'price': price,
          'quantity': stock,
          'category': category,
          'imageUrl': imageUrl ?? '',
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to update product: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error updating product: $e',
      };
    }
  }

  // Delete product
  static Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl$_productsEndpoint/$productId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Failed to delete product: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting product: $e',
      };
    }
  }

  // Search products
  static Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_productsEndpoint/search?query=$query'),
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
      print('Error searching products: $e');
      return [];
    }
  }

  // Get featured products
  static Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    // TODO: Implement with Spring Boot API
    return [];
  }

  // Get products by price range
  static Future<List<Map<String, dynamic>>> getProductsByPriceRange(double minPrice, double maxPrice) async {
    // TODO: Implement with Spring Boot API
    return [];
  }

  // Get low stock products
  static Future<List<Map<String, dynamic>>> getLowStockProducts(int threshold) async {
    // TODO: Implement with Spring Boot API
    return [];
  }

  // Update product stock
  static Future<Map<String, dynamic>> updateProductStock(String productId, int newStock) async {
    // TODO: Implement with Spring Boot API
    return {
      'success': false,
      'message': 'Stock update will be implemented with Spring Boot backend',
    };
  }

  // Get product categories
  static Future<List<String>> getProductCategories() async {
    // TODO: Implement with Spring Boot API
    return [
      'Food & Beverages',
      'Clothing & Fashion',
      'Home & Garden',
      'Electronics',
      'Health & Beauty',
      'Sports & Outdoors',
    ];
  }

  // Get product statistics
  static Future<Map<String, dynamic>> getProductStatistics() async {
    // TODO: Implement with Spring Boot API
    return {
      'totalProducts': 0,
      'totalCategories': 0,
      'lowStockProducts': 0,
      'totalValue': 0.0,
    };
  }
}