import 'package:flutter/material.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  
  List<Map<String, dynamic>> _cartItems = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _cartSummary;
  
  // Circuit breaker variables to prevent infinite loops
  String? _lastUserId;
  DateTime? _lastLoadTime;
  bool _isInitialized = false;
  bool _hasLoadError = false;
  final Duration _loadCooldown = Duration(seconds: 5); // Prevent loading too frequently

  // Getters
  List<Map<String, dynamic>> get cartItems => List.from(_cartItems);
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get cartSummary => _cartSummary;
  int get totalItems => _cartItems.length;
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + ((item['quantity'] as int?) ?? 0));
  double get totalAmount => _cartItems.fold(0.0, (sum, item) => sum + ((item['totalPrice'] as double?) ?? 0.0));
  double get totalCarbonFootprint => _cartItems.fold(0.0, (sum, item) => sum + ((item['carbonFootprint'] as double?) ?? 0.0) * ((item['quantity'] as int?) ?? 0));

  // Initialize cart for a user
  Future<void> initializeCart(String userId) async {
    // Circuit breaker: Don't initialize if already done recently for same user
    if (_isInitialized && 
        _lastUserId == userId && 
        _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _loadCooldown) {
      print('Cart: Skipping initialization - already done recently for user $userId');
      return;
    }
    
    // If there was an error, don't retry immediately
    if (_hasLoadError && 
        _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _loadCooldown) {
      print('🛒 CartProvider: Skipping initialization - error cooldown active');
      return;
    }
    
    print('Cart: Initializing cart for user $userId');
    _setLoading(true);
    _clearError();
    _hasLoadError = false;
    
    try {
      await loadCart(userId);
      _isInitialized = true;
      _lastUserId = userId;
      _lastLoadTime = DateTime.now();
      print('Cart: Initialized successfully with ${_cartItems.length} items');
    } catch (e) {
      _hasLoadError = true;
      _lastLoadTime = DateTime.now();
      print('🛒 CartProvider: Failed to initialize cart: $e');
      _setError('Failed to load cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load cart items from backend
  Future<void> loadCart(String userId) async {
    print('Cart: Loading cart for user $userId');
    _setLoading(true);
    _clearError();
    
    try {
      final items = await CartService.getUserCart(userId);
      final summary = await CartService.getCartSummary(userId);
      
      _cartItems = items;
      _cartSummary = summary;
      
      print('Cart: Loaded successfully with ${_cartItems.length} items');
      notifyListeners();
    } catch (e) {
      print('🛒 CartProvider: Failed to load cart: $e');
      _setError('Failed to load cart: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Add item to cart
  Future<bool> addItem({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    String? imageUrl,
    String? category,
    int quantity = 1,
    double carbonFootprint = 0.0,
  }) async {
    print('Cart: Adding item $productName to cart');
    
    _setLoading(true);
    _clearError();
    
    try {
      print('Cart: Calling backend service...');
      final result = await CartService.addToCart(
        userId: userId,
        productId: productId,
        productName: productName,
        productPrice: price,
        productImage: imageUrl ?? '',
        productCategory: category ?? 'Uncategorized',
        quantity: quantity,
        carbonFootprint: carbonFootprint,
      );
      
      if (result['success'] == true) {
        print('Cart: Successfully added item, reloading cart...');
        // Reload cart to get updated data
        await loadCart(userId);
        return true;
      } else {
        print('Cart: Failed to add item: ${result['message']}');
        _setError(result['message'] ?? 'Failed to add item to cart');
        return false;
      }
    } catch (e) {
      print('Cart: Error adding item: $e');
      _setError('Error adding item to cart: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove item from cart
  Future<bool> removeItem(String userId, String productId) async {
    print('Cart: Removing item from cart - productId: $productId');
    _setLoading(true);
    _clearError();
    
    try {
      final result = await CartService.removeFromCart(
        userId: userId,
        productId: productId,
      );
      
      if (result['success'] == true) {
        // Reload cart to get updated data
        await loadCart(userId);
        print('🛒 CartProvider: Item removed successfully');
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to remove item from cart');
        print('🛒 CartProvider: Failed to remove item: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('🛒 CartProvider: Error removing item: $e');
      _setError('Error removing item from cart: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update item quantity
  Future<bool> updateQuantity({
    required String userId,
    required String productId,
    required int quantity,
  }) async {
    print('🛒 CartProvider: Updating item quantity - productId: $productId, quantity: $quantity');
    _setLoading(true);
    _clearError();
    
    try {
      final result = await CartService.updateCartItemQuantity(
        userId: userId,
        productId: productId,
        quantity: quantity,
      );
      
      if (result['success'] == true) {
        // Reload cart to get updated data
        await loadCart(userId);
        print('🛒 CartProvider: Quantity updated successfully');
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to update quantity');
        print('🛒 CartProvider: Failed to update quantity: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('🛒 CartProvider: Error updating quantity: $e');
      _setError('Error updating quantity: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove single item (decrease quantity by 1)
  Future<bool> removeSingleItem(String userId, String productId) async {
    final item = _cartItems.firstWhere(
      (item) => item['productId'] == productId,
      orElse: () => {},
    );
    
    if (item.isEmpty) return false;
    
    final currentQuantity = item['quantity'] as int? ?? 1;
    
    if (currentQuantity <= 1) {
      // Remove item completely if quantity is 1
      return await removeItem(userId, productId);
    } else {
      // Decrease quantity by 1
      return await updateQuantity(
        userId: userId,
        productId: productId,
        quantity: currentQuantity - 1,
      );
    }
  }

  // Clear entire cart
  Future<bool> clearCart(String userId) async {
    print('🛒 CartProvider: Clearing entire cart');
    _setLoading(true);
    _clearError();
    
    try {
      final result = await CartService.clearCart(userId);
      
      if (result['success'] == true) {
        _cartItems.clear();
        _cartSummary = null;
        print('🛒 CartProvider: Cart cleared successfully');
        notifyListeners();
        return true;
      } else {
        _setError(result['message'] ?? 'Failed to clear cart');
        print('🛒 CartProvider: Failed to clear cart: ${result['message']}');
        return false;
      }
    } catch (e) {
      print('🛒 CartProvider: Error clearing cart: $e');
      _setError('Error clearing cart: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if item is in cart
  bool isInCart(String productId) {
    return _cartItems.any((item) => item['productId'] == productId);
  }

  // Get item quantity in cart
  int getItemQuantity(String productId) {
    final item = _cartItems.firstWhere(
      (item) => item['productId'] == productId,
      orElse: () => {},
    );
    return item['quantity'] as int? ?? 0;
  }

  // Get cart item by product id
  Map<String, dynamic>? getCartItem(String productId) {
    try {
      return _cartItems.firstWhere((item) => item['productId'] == productId);
    } catch (e) {
      return null;
    }
  }

  // Refresh cart data
  Future<void> refreshCart(String userId) async {
    print('🛒 CartProvider: Refreshing cart data');
    await loadCart(userId);
  }

  // Helper methods
  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Reset provider state (useful for logout)
  void reset() {
    _cartItems.clear();
    _cartSummary = null;
    _error = null;
    _isLoading = false;
    _isInitialized = false;
    _hasLoadError = false;
    _lastUserId = null;
    _lastLoadTime = null;
    notifyListeners();
    print('🛒 CartProvider: Provider state reset');
  }

  // Get formatted cart summary
  String getFormattedSummary() {
    if (_cartItems.isEmpty) return 'Cart is empty';
    
    return '$totalItems items • ₹${totalAmount.toStringAsFixed(2)} • ${totalCarbonFootprint.toStringAsFixed(1)}kg CO₂';
  }

  // Get total carbon footprint saved (for payment success screen)
  double get totalCarbonFootprintSaved => totalCarbonFootprint;

  // Get purchase summary for carbon tracking
  Map<String, dynamic> getPurchaseSummary() {
    return {
      'totalItems': totalItems,
      'totalQuantity': totalQuantity,
      'totalAmount': totalAmount,
      'totalCarbonFootprint': totalCarbonFootprint,
      'items': _cartItems.map((item) => {
        'productId': item['productId'] ?? '',
        'productName': item['productName'] ?? item['name'] ?? 'Unknown Product',
        'category': item['productCategory'] ?? item['category'] ?? 'General',
        'price': (item['productPrice'] ?? item['price'] ?? 0.0) as double,
        'quantity': (item['quantity'] ?? 1) as int,
        'totalPrice': (item['totalPrice'] ?? 0.0) as double,
        'carbonFootprint': (item['carbonFootprint'] ?? 0.0) as double,
        'totalCarbonFootprint': ((item['carbonFootprint'] ?? 0.0) as double) * ((item['quantity'] ?? 1) as int),
      }).toList(),
      'purchaseDate': DateTime.now().toIso8601String(),
    };
  }
}