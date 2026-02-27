import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
// import 'package:cloud_firestore/cloud_firestore.dart'; // DISABLED - Using Spring Boot Backend
import '../services/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _userOrders = [];
  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get userOrders => _userOrders;
  List<Map<String, dynamic>> get allOrders => _allOrders;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize orders
  Future<void> initializeOrders(String userId) async {
    _setLoading(true);
    try {
      await Future.wait([
        loadUserOrders(userId),
        loadAllOrders(),
      ]);
      _error = null;
    } catch (e) {
      _error = 'Failed to load orders: ${e.toString()}';
      print('Error initializing orders: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load user orders
  Future<void> loadUserOrders(String userId) async {
    try {
      final orders = await OrdersService.getUserOrders(userId);
      _userOrders = orders;
      notifyListeners();
    } catch (e) {
      print('Error loading user orders: $e');
      _error = 'Failed to load user orders';
    }
  }

  // Load all orders (for admin/shopkeeper)
  Future<void> loadAllOrders({int limit = 100}) async {
    try {
      // Use the new getAllOrders method from OrdersService
      _allOrders = await OrdersService.getAllOrders(limit: limit);
      notifyListeners();
    } catch (e) {
      print('Error loading all orders: $e');
      _error = 'Failed to load all orders';
      
      // Fallback to loading by status
      try {
        final pendingOrders = await OrdersService.getOrdersByStatus('PENDING');
        final shippedOrders = await OrdersService.getOrdersByStatus('SHIPPED');
        final deliveredOrders = await OrdersService.getOrdersByStatus('DELIVERED');
        final cancelledOrders = await OrdersService.getOrdersByStatus('CANCELLED');
        
        _allOrders = [...pendingOrders, ...shippedOrders, ...deliveredOrders, ...cancelledOrders];
        notifyListeners();
      } catch (fallbackError) {
        print('Fallback error loading orders: $fallbackError');
      }
    }
  }

  // Create new order
  Future<Map<String, dynamic>> createOrder({
    required String userId,
    required String userEmail,
    required String userName,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required String status,
    String? deliveryAddress,
    String? paymentMethod,
  }) async {
    try {
      final result = await OrdersService.createOrder(
        userId: userId,
        items: items,
        totalAmount: totalAmount,
        deliveryAddress: deliveryAddress ?? '',
        paymentMethod: paymentMethod,
      );

      if (result['success']) {
        // Reload orders after creating new one
        await loadUserOrders(userId);
        await loadAllOrders();
      }

      return result;
    } catch (e) {
      print('Error creating order: $e');
      return {
        'success': false,
        'message': 'Failed to create order: ${e.toString()}',
      };
    }
  }

  // Update order status
  Future<Map<String, dynamic>> updateOrderStatus(String orderId, String newStatus) async {
    try {
      final result = await OrdersService.updateOrderStatus(
        orderId: orderId,
        status: newStatus,
      );
      
      if (result['success']) {
        // Reload orders after updating
        await loadUserOrders(_userOrders.first['userId'] ?? '');
        await loadAllOrders();
      }

      return result;
    } catch (e) {
      print('Error updating order status: $e');
      return {
        'success': false,
        'message': 'Failed to update order status: ${e.toString()}',
      };
    }
  }

  // Get orders by status
  Future<List<Map<String, dynamic>>> getOrdersByStatus(String status) async {
    try {
      return await OrdersService.getOrdersByStatus(status);
    } catch (e) {
      print('Error getting orders by status: $e');
      return [];
    }
  }

  // Get order statistics
  Future<Map<String, dynamic>> getOrderStatistics(String userId) async {
    try {
      return await OrdersService.getOrderStatistics(userId);
    } catch (e) {
      print('Error getting order statistics: $e');
      return {
        'totalOrders': 0,
        'totalRevenue': 0.0,
        'statusCounts': {},
        'monthlyRevenue': {},
        'averageOrderValue': 0.0,
      };
    }
  }

  // Track order (get detailed tracking info)
  Future<Map<String, dynamic>?> trackOrder(String orderId) async {
    try {
      print('🔄 Tracking order: $orderId');
      final trackingInfo = await OrdersService.trackOrder(orderId);
      if (trackingInfo != null) {
        print('✅ Order tracking info loaded');
      }
      return trackingInfo;
    } catch (e) {
      print('❌ Error tracking order: $e');
      _error = 'Failed to track order: ${e.toString()}';
      return null;
    }
  }

  // Update order tracking info
  Future<Map<String, dynamic>> updateOrderTracking({
    required String orderId,
    required String trackingId,
    required String carrier,
    String? estimatedDelivery,
    String? trackingUrl,
  }) async {
    try {
      print('🔄 Updating order tracking: $orderId');
      final result = await OrdersService.updateOrderTracking(
        orderId: orderId,
        trackingId: trackingId,
        carrier: carrier,
        estimatedDelivery: estimatedDelivery,
        trackingUrl: trackingUrl,
      );
      
      if (result['success']) {
        print('✅ Order tracking updated');
        // Reload orders after updating
        await loadAllOrders();
      }
      
      return result;
    } catch (e) {
      print('❌ Error updating order tracking: $e');
      return {
        'success': false,
        'message': 'Failed to update tracking info: ${e.toString()}',
      };
    }
  }

  // Get order timeline/history
  Future<List<Map<String, dynamic>>> getOrderTimeline(String orderId) async {
    try {
      print('🔄 Loading order timeline: $orderId');
      final timeline = await OrdersService.getOrderTimeline(orderId);
      print('✅ Loaded ${timeline.length} timeline events');
      return timeline;
    } catch (e) {
      print('❌ Error loading order timeline: $e');
      return [];
    }
  }

  // Add order note
  Future<Map<String, dynamic>> addOrderNote({
    required String orderId,
    required String note,
    String? addedBy,
  }) async {
    try {
      print('🔄 Adding order note: $orderId');
      final result = await OrdersService.addOrderNote(
        orderId: orderId,
        note: note,
        addedBy: addedBy,
      );
      
      if (result['success']) {
        print('✅ Order note added');
      }
      
      return result;
    } catch (e) {
      print('❌ Error adding order note: $e');
      return {
        'success': false,
        'message': 'Failed to add note: ${e.toString()}',
      };
    }
  }

  // Get recent orders
  Future<List<Map<String, dynamic>>> getRecentOrders(String userId, {int limit = 10}) async {
    try {
      print('🔄 Loading recent orders for user: $userId');
      final orders = await OrdersService.getRecentOrders(userId, limit: limit);
      print('✅ Loaded ${orders.length} recent orders');
      return orders;
    } catch (e) {
      print('❌ Error loading recent orders: $e');
      return [];
    }
  }

  // Get order history
  Future<List<Map<String, dynamic>>> getOrderHistory(String userId, {int limit = 50}) async {
    try {
      print('🔄 Loading order history for user: $userId');
      final history = await OrdersService.getOrderHistory(userId, limit: limit);
      print('✅ Loaded ${history.length} orders in history');
      return history;
    } catch (e) {
      print('❌ Error loading order history: $e');
      return [];
    }
  }

  // Helper method to format order status for display
  String getStatusDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'processing':
        return 'Processing';
      case 'shipped':
        return 'Shipped';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'refunded':
        return 'Refunded';
      default:
        return status;
    }
  }

  // Helper method to get status color
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  // Helper method to parse color from string
  Color _parseColor(dynamic colorValue) {
    if (colorValue is Color) {
      return colorValue;
    }
    
    if (colorValue is String) {
      if (colorValue.startsWith('#')) {
        return Color(int.parse(colorValue.replaceFirst('#', '0xFF')));
      }
    }
    
    return const Color(0xFFB5C7F7); // Default color
  }

  // Helper method to get icon from string
  IconData _getIconFromString(dynamic iconValue) {
    if (iconValue is IconData) {
      return iconValue;
    }
    
    if (iconValue is String) {
      switch (iconValue) {
        case 'water_drop_rounded':
          return Icons.water_drop_rounded;
        case 'checkroom_rounded':
          return Icons.checkroom_rounded;
        case 'spa_rounded':
          return Icons.spa_rounded;
        case 'solar_power_rounded':
          return Icons.solar_power_rounded;
        case 'shopping_bag_rounded':
          return Icons.shopping_bag_rounded;
        case 'eco_rounded':
          return Icons.eco_rounded;
        case 'store_rounded':
          return Icons.store_rounded;
        default:
          return Icons.shopping_bag_rounded;
      }
    }
    
    return Icons.shopping_bag_rounded; // Default icon
  }

  // Get formatted order data for UI
  List<Map<String, dynamic>> getFormattedUserOrders() {
    return _userOrders.map((order) {
      final items = order['items'] as List<dynamic>? ?? [];
      final firstItem = items.isNotEmpty ? items.first : {};
      
      return {
        'id': order['orderId'] ?? order['id'] ?? 'Unknown',
        'product': firstItem['name'] ?? 'Unknown Product',
        'status': order['status'] ?? 'Unknown',
        'date': order['createdAt'] != null 
            ? order['createdAt'].toString().split(' ')[0]
            : 'Unknown',
        'amount': '₹${(order['totalAmount'] ?? 0.0).toStringAsFixed(0)}',
        'color': _parseColor(firstItem['color'] ?? '#B5C7F7'),
        'icon': _getIconFromString(firstItem['icon'] ?? 'shopping_bag_rounded'),
        'orderData': order,
      };
    }).toList();
  }

  // Get formatted all orders data for UI
  List<Map<String, dynamic>> getFormattedAllOrders() {
    return _allOrders.map((order) {
      final items = order['items'] as List<dynamic>? ?? [];
      final firstItem = items.isNotEmpty ? items.first : {};
      
      return {
        'id': order['orderId'] ?? order['id'] ?? 'Unknown',
        'product': firstItem['name'] ?? 'Unknown Product',
        'status': order['status'] ?? 'Unknown',
        'date': order['createdAt'] != null 
            ? order['createdAt'].toString().split(' ')[0]
            : 'Unknown',
        'amount': '₹${(order['totalAmount'] ?? 0.0).toStringAsFixed(0)}',
        'color': _parseColor(firstItem['color'] ?? '#B5C7F7'),
        'icon': _getIconFromString(firstItem['icon'] ?? 'shopping_bag_rounded'),
        'orderData': order,
      };
    }).toList();
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh orders
  Future<void> refreshOrders(String userId) async {
    await initializeOrders(userId);
  }
}
