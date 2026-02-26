// import 'package:cloud_firestore/cloud_firestore.dart'; // DISABLED - Using Spring Boot Backend
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/firebase_config.dart';

class PaymentService {
  // DISABLED - Using Spring Boot Backend
  // All Firestore functionality has been moved to Spring Boot backend
  // This service is kept for compatibility but will be replaced with API calls

  // static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // static final CollectionReference _paymentsCollection = _firestore.collection('payments');
  // static final CollectionReference _transactionsCollection = _firestore.collection('transactions');
  // static final CollectionReference _refundsCollection = _firestore.collection('refunds');

  // Process payment (original method)
  static Future<Map<String, dynamic>> processPaymentOriginal({
    required String orderId,
    required double amount,
    required String paymentMethod,
    required String userId,
    Map<String, dynamic>? paymentDetails,
  }) async {
    // TODO: Implement with Spring Boot API
    return {
      'success': false,
      'message': 'Payment processing will be implemented with Spring Boot backend',
    };
  }

  // Get payment status
  static Future<Map<String, dynamic>?> getPaymentStatus(String paymentId) async {
    // TODO: Implement with Spring Boot API
    return null;
  }

  // Get user payments
  static Future<List<Map<String, dynamic>>> getUserPayments(String userId) async {
    // TODO: Implement with Spring Boot API
    return [];
  }

  // Get payment by ID
  static Future<Map<String, dynamic>?> getPaymentById(String paymentId) async {
    // TODO: Implement with Spring Boot API
    return null;
  }

  // Refund payment
  static Future<Map<String, dynamic>> refundPayment({
    required String paymentId,
    required double amount,
    String? reason,
  }) async {
    // TODO: Implement with Spring Boot API
    return {
      'success': false,
      'message': 'Payment refund will be implemented with Spring Boot backend',
    };
  }

  // Get payment methods
  static Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    // Return predefined payment methods
    return [
      {
        'id': 'credit_card',
        'name': 'Credit Card',
        'icon': 'credit_card',
        'enabled': true,
      },
      {
        'id': 'debit_card',
        'name': 'Debit Card',
        'icon': 'account_balance',
        'enabled': true,
      },
      {
        'id': 'upi',
        'name': 'UPI',
        'icon': 'payment',
        'enabled': true,
      },
      {
        'id': 'net_banking',
        'name': 'Net Banking',
        'icon': 'account_balance',
        'enabled': true,
      },
      {
        'id': 'wallet',
        'name': 'Digital Wallet',
        'icon': 'account_balance_wallet',
        'enabled': true,
      },
    ];
  }

  // Validate payment details
  static Future<Map<String, dynamic>> validatePaymentDetails(Map<String, dynamic> paymentDetails) async {
    // TODO: Implement with Spring Boot API
    return {
      'valid': false,
      'message': 'Payment validation will be implemented with Spring Boot backend',
    };
  }

  // Get payment statistics
  static Future<Map<String, dynamic>> getPaymentStatistics(String userId) async {
    // TODO: Implement with Spring Boot API
    return {
      'totalPayments': 0,
      'totalAmount': 0.0,
      'successfulPayments': 0,
      'failedPayments': 0,
      'refundedPayments': 0,
    };
  }

  // Get transaction history
  static Future<List<Map<String, dynamic>>> getTransactionHistory(String userId, {int limit = 50}) async {
    // TODO: Implement with Spring Boot API
    return [];
  }

  // Generate payment receipt
  static Future<Map<String, dynamic>> generatePaymentReceipt(String paymentId) async {
    // TODO: Implement with Spring Boot API
    return {
      'success': false,
      'message': 'Payment receipt generation will be implemented with Spring Boot backend',
    };
  }

  // Get refund status
  static Future<Map<String, dynamic>?> getRefundStatus(String refundId) async {
    // TODO: Implement with Spring Boot API
    return null;
  }

  // Get user refunds
  static Future<List<Map<String, dynamic>>> getUserRefunds(String userId) async {
    // TODO: Implement with Spring Boot API
    return [];
  }

  // Calculate payment fees
  static Future<Map<String, dynamic>> calculatePaymentFees({
    required double amount,
    required String paymentMethod,
  }) async {
    // TODO: Implement with Spring Boot API
    return {
      'amount': amount,
      'fees': 0.0,
      'total': amount,
    };
  }

  // Generate payment ID
  static String generatePaymentId() {
    final now = DateTime.now();
    final random = Random().nextInt(1000);
    return 'PAY_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_$random';
  }

  // Generate transaction ID
  static String generateTransactionId() {
    final now = DateTime.now();
    final random = Random().nextInt(1000);
    return 'TXN_${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}_$random';
  }

  // Create order (MySQL Backend Integration)
  static Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String userEmail,
    required String userName,
    required String userPhone,
    required List<Map<String, dynamic>> cartItems,
    required Map<String, dynamic> shippingAddress,
    required Map<String, dynamic> billingAddress,
    required double totalAmount,
    required double taxAmount,
    required double shippingAmount,
    required double discountAmount,
    required double finalAmount,
    required String paymentMethod,
    String? deliveryNotes,
  }) async {
    try {
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final String orderId = generatePaymentId();
      
      // Create main order in MySQL
      final orderResponse = await http.post(
        Uri.parse('$baseUrl/api/orders'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'userId': userId,
          'userEmail': userEmail,
          'userName': userName,
          'userPhone': userPhone,
          'totalAmount': totalAmount,
          'taxAmount': taxAmount,
          'shippingAmount': shippingAmount,
          'discountAmount': discountAmount,
          'finalAmount': finalAmount,
          'orderStatus': 'PENDING',
          'paymentStatus': 'PENDING',
          'paymentMethod': paymentMethod,
          'shippingAddress': '${shippingAddress['address']}, ${shippingAddress['city']}, ${shippingAddress['state']}, ${shippingAddress['pincode']}',
          'billingAddress': '${billingAddress['address']}, ${billingAddress['city']}, ${billingAddress['state']}, ${billingAddress['pincode']}',
          'deliveryNotes': deliveryNotes ?? '',
          'carbonFootprint': cartItems.fold(0.0, (sum, item) => sum + (item['carbonFootprint'] ?? 0.0)),
          'ecoPointsEarned': cartItems.fold<int>(0, (sum, item) => sum + (item['ecoPoints'] as int? ?? 0)),
          'currency': 'INR',
        }),
      );

      if (orderResponse.statusCode == 200) {
        final orderData = jsonDecode(orderResponse.body);
        print('🛍️ Order created successfully: $orderId');
        
        // Create order items (user_orders) for each cart item
        for (final item in cartItems) {
          final userOrderId = 'UO-${DateTime.now().millisecondsSinceEpoch}-${Random().nextInt(1000)}';
          
          final userOrderResponse = await http.post(
            Uri.parse('$baseUrl/api/userorders'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'userOrderId': userOrderId,
              'userId': userId,
              'orderId': orderId,
              'productId': item['productId'],
              'productName': item['productName'],
              'productPrice': item['price'],
              'quantity': item['quantity'],
              'totalAmount': item['price'] * item['quantity'],
              'storeId': item['storeId'] ?? 'STORE-001',
              'storeName': item['storeName'] ?? 'EcoStore',
              'orderStatus': 'PENDING',
            }),
          );
          
          if (userOrderResponse.statusCode == 200) {
            print('📦 Order item created: ${item['productName']}');
          } else {
            print('❌ Failed to create order item: ${item['productName']}');
          }
        }
        
        return {
          'success': true,
          'orderId': orderId,
          'message': 'Order created successfully',
          'orderData': orderData,
        };
      } else {
        print('❌ Failed to create order: ${orderResponse.statusCode} - ${orderResponse.body}');
        return {
          'success': false,
          'message': 'Failed to create order: ${orderResponse.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Error creating order: $e');
      return {
        'success': false,
        'message': 'Error creating order: $e',
      };
    }
  }

  // Simulate Razorpay payment
  static Future<Map<String, dynamic>> simulateRazorpayPayment({
    required double amount,
    required String currency,
    required String orderId,
  }) async {
    // TODO: Implement with Spring Boot API
    return {
      'success': true,
      'paymentId': generatePaymentId(),
      'message': 'Payment successful (simulated)',
    };
  }

  // Process payment (Spring Boot API implementation)
  static Future<Map<String, dynamic>> processPayment({
    required String orderId,
    required String userId,
    required String paymentMethod,
    required String paymentGateway,
    required double amount,
    required Map<String, dynamic> gatewayResponse,
    String? failureReason,
  }) async {
    try {
      final String baseUrl = FirebaseConfig.baseApiUrl;
      final response = await http.post(
        Uri.parse('$baseUrl/api/payments/process'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'orderId': orderId,
          'userId': userId,
          'paymentMethod': paymentMethod,
          'paymentGateway': paymentGateway,
          'amount': amount,
          'gatewayResponse': gatewayResponse,
          'failureReason': failureReason,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print('💳 Payment processed successfully: ${data['paymentId']}');
        return data;
      } else {
        print('💳 Payment processing failed: ${response.statusCode} - ${response.body}');
        return {
          'success': false,
          'message': 'Payment processing failed: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('💳 Error processing payment: $e');
      return {
        'success': false,
        'message': 'Error processing payment: $e',
      };
    }
  }
}