import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class ApiService {
  static const String _baseUrl = FirebaseConfig.baseApiUrl;
  static const Duration _timeout = Duration(seconds: 30);

  // Headers for API requests
  static Map<String, String> _getHeaders({String? authToken}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (authToken != null) 'Authorization': 'Bearer $authToken',
    };
  }

  // Generic GET request
  static Future<Map<String, dynamic>> get(
    String endpoint, {
    String? authToken,
    Map<String, String>? queryParams,
  }) async {
    try {
      String url = '$_baseUrl$endpoint';
      
      if (queryParams != null && queryParams.isNotEmpty) {
        final uri = Uri.parse(url);
        url = uri.replace(queryParameters: queryParams).toString();
      }

      print('API GET Request: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: _getHeaders(authToken: authToken),
      ).timeout(_timeout);


      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('API GET Error: $e');
      rethrow;
    }
  }

  // Generic POST request
  static Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    String? authToken,
  }) async {
    try {
      final url = '$_baseUrl$endpoint';
      

      final response = await http.post(
        Uri.parse(url),
        headers: _getHeaders(authToken: authToken),
        body: body != null ? json.encode(body) : null,
      ).timeout(_timeout);


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('API POST Error: $e');
      rethrow;
    }
  }

  // Generic PUT request
  static Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    String? authToken,
  }) async {
    try {
      final url = '$_baseUrl$endpoint';
      
      print('API PUT Request: $url');
      print('API PUT Body: ${json.encode(body)}');

      final response = await http.put(
        Uri.parse(url),
        headers: _getHeaders(authToken: authToken),
        body: body != null ? json.encode(body) : null,
      ).timeout(_timeout);


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('API PUT Error: $e');
      rethrow;
    }
  }

  // Generic DELETE request
  static Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? authToken,
  }) async {
    try {
      final url = '$_baseUrl$endpoint';
      
      print('API DELETE Request: $url');

      final response = await http.delete(
        Uri.parse(url),
        headers: _getHeaders(authToken: authToken),
      ).timeout(_timeout);


      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(response.body);
      } else {
        throw HttpException('HTTP ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('API DELETE Error: $e');
      rethrow;
    }
  }

  // Health check
  static Future<Map<String, dynamic>> healthCheck() async {
    try {
      return await get('/actuator/health');
    } catch (e) {
      print('Health check failed: $e');
      return {
        'status': 'DOWN',
        'error': e.toString(),
      };
    }
  }

  // Settings API endpoints
  static Future<Map<String, dynamic>> getSettings(String userId, {String? authToken}) async {
    try {
      return await get('/settings/$userId', authToken: authToken);
    } catch (e) {
      print('Get settings failed: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> updateSettings(
    String userId,
    Map<String, dynamic> settings, {
    String? authToken,
  }) async {
    try {
      return await put('/settings/$userId', body: settings, authToken: authToken);
    } catch (e) {
      print('Update settings failed: $e');
      rethrow;
    }
  }

  // Store API endpoints
  static Future<Map<String, dynamic>> getStores({String? authToken}) async {
    try {
      return await get('/stores', authToken: authToken);
    } catch (e) {
      print('Get stores failed: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getStore(String storeId, {String? authToken}) async {
    try {
      return await get('/stores/$storeId', authToken: authToken);
    } catch (e) {
      print('Get store failed: $e');
      rethrow;
    }
  }

  // Product API endpoints
  static Future<Map<String, dynamic>> getProducts({String? authToken}) async {
    try {
      return await get('/products', authToken: authToken);
    } catch (e) {
      print('Get products failed: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> getProduct(String productId, {String? authToken}) async {
    try {
      return await get('/products/$productId', authToken: authToken);
    } catch (e) {
      print('Get product failed: $e');
      rethrow;
    }
  }

  // Order API endpoints
  static Future<Map<String, dynamic>> getOrders(String userId, {String? authToken}) async {
    try {
      return await get('/orders/user/$userId', authToken: authToken);
    } catch (e) {
      print('Get orders failed: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData, {
    String? authToken,
  }) async {
    try {
      return await post('/orders', body: orderData, authToken: authToken);
    } catch (e) {
      print('Create order failed: $e');
      rethrow;
    }
  }

  // Authentication API endpoints
  static Future<Map<String, dynamic>> authenticate(
    String email,
    String password,
    String role,
  ) async {
    try {
      final response = await post('/auth/login', body: {
        'email': email,
        'password': password,
        'role': role,
      });
      
      // Handle JWT token format - backend returns 'accessToken' but frontend expects 'token'
      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'] ?? 'Login successful',
          'token': response['accessToken'] ?? response['token'], // Try both field names
          'refreshToken': response['refreshToken'],
          'userId': response['userId'],
          'userRole': response['userRole'],
          'userName': response['userName'] ?? email.split('@')[0], // Add userName if available
        };
      }
      
      return response;
    } catch (e) {
      print('Authentication failed: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> register(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await post('/auth/register', body: userData);
      
      // Handle new JWT token format
      if (response['success'] == true) {
        return {
          'success': true,
          'message': response['message'],
          'userId': response['userId'],
          'userRole': response['userRole'],
        };
      }
      
      return response;
    } catch (e) {
      print('Registration failed: $e');
      rethrow;
    }
  }

  // JWT Token validation
  static Future<Map<String, dynamic>> validateToken(String token) async {
    try {
      return await post('/auth/validate', body: {
        'token': token,
      });
    } catch (e) {
      print('Token validation failed: $e');
      rethrow;
    }
  }

  // Refresh JWT token
  static Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    try {
      return await post('/auth/refresh', body: {
        'refreshToken': refreshToken,
      });
    } catch (e) {
      print('Token refresh failed: $e');
      rethrow;
    }
  }

  static Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      return await post('/auth/reset-password', body: {
        'email': email,
      });
    } catch (e) {
      print('Password reset failed: $e');
      rethrow;
    }
  }
}
