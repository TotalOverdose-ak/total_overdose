import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../services/wishlist_service.dart';

class WishlistProvider extends ChangeNotifier {
  
  List<Map<String, dynamic>> _wishlistItems = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _wishlistStats;
  Map<String, dynamic>? _wishlistAnalytics;
  
  // Circuit breaker variables to prevent infinite loops
  String? _lastUserId;
  DateTime? _lastLoadTime;
  bool _isInitialized = false;
  bool _hasLoadError = false;
  final Duration _loadCooldown = Duration(seconds: 30); // Prevent loading too frequently
  bool _isInitializing = false; // Prevent concurrent initializations

  // Getters
  List<Map<String, dynamic>> get wishlistItems => List.from(_wishlistItems);
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get wishlistStats => _wishlistStats;
  Map<String, dynamic>? get wishlistAnalytics => _wishlistAnalytics;
  int get totalItems => _wishlistItems.length;

  // Initialize wishlist for a user
  Future<void> initializeWishlist(String userId) async {
    // Prevent concurrent initializations
    if (_isInitializing) {
      print('🔥 WishlistProvider: Skipping initialization - already in progress');
      return;
    }
    
    // Circuit breaker: Don't initialize if already done recently for same user
    if (_isInitialized && 
        _lastUserId == userId && 
        _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _loadCooldown) {
      print('🔥 WishlistProvider: Skipping initialization - already done recently for user $userId');
      return;
    }
    
    // If there was an error, don't retry immediately
    if (_hasLoadError && 
        _lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < _loadCooldown) {
      print('🔥 WishlistProvider: Skipping initialization - error cooldown active');
      return;
    }
    
    _isInitializing = true;
    print('🔥 WishlistProvider: Initializing wishlist for user $userId');
    _setLoading(true);
    _clearError();
    _hasLoadError = false;
    
    try {
      final items = await WishlistService.getUserWishlist(userId);
      print('🔥 WishlistProvider: Loaded ${items.length} items from backend');
      _wishlistItems = items;
      
      // Only initialize sample data once if no items and not already tried
      if (_wishlistItems.isEmpty && !_isInitialized) {
        print('Initializing sample wishlist items for user: $userId');
        // Don't call the service method that might cause loops
        // Just set some local sample data
      }
      
      // Mark as initialized
      _isInitialized = true;
      _lastUserId = userId;
      _lastLoadTime = DateTime.now();
      
      // Load stats and analytics only once
      await _loadWishlistStats(userId);
      await _loadWishlistAnalytics(userId);
      
      notifyListeners(); // Ensure UI updates after loading wishlist
      
    } catch (e) {
      _setError('Failed to load wishlist: ${e.toString()}');
      _hasLoadError = true;
      _lastLoadTime = DateTime.now();
    } finally {
      _setLoading(false);
      _isInitializing = false;
    }
  }

  // Load wishlist items (with circuit breaker)
  Future<void> loadWishlist(String userId) async {
    // Circuit breaker: Don't load too frequently
    if (_lastLoadTime != null && 
        DateTime.now().difference(_lastLoadTime!) < Duration(seconds: 5)) {
      print('🔥 WishlistProvider: Skipping load - too frequent requests');
      return;
    }
    
    _setLoading(true);
    _clearError();
    
    try {
      final items = await WishlistService.getUserWishlist(userId);
      _wishlistItems = items;
      _lastLoadTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError('Failed to load wishlist: ${e.toString()}');
      _hasLoadError = true;
    } finally {
      _setLoading(false);
    }
  }

  // Add product to wishlist
  Future<bool> addToWishlist({
    required String userId,
    required String productId,
    required String productName,
    required double price,
    String? imageUrl,
    String? category,
  }) async {
    print('🔥 WishlistProvider: Adding $productId to wishlist for user $userId');
    _setLoading(true);
    _clearError();
    
    try {
      final result = await WishlistService.addToWishlist(
        userId: userId,
        productId: productId, 
        productName: productName,
        price: price,
        imageUrl: imageUrl,
        category: category,
      );
      
      if (result['success']) {
        // Directly add the item to local state for immediate UI update (check for duplicates)
        if (!_wishlistItems.any((item) => item['productId'] == productId)) {
          _wishlistItems.add({
            'productId': productId,
            'productName': productName,
            'productPrice': price,
            'productImage': imageUrl ?? '',
            'productCategory': category ?? 'General',
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
        notifyListeners(); // Force immediate UI update
        
        // Also try to reload for full sync (but don't wait for it)
        loadWishlist(userId).catchError((e) {
          print('Background sync failed: $e');
        });
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to add to wishlist: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Remove product from wishlist
  Future<bool> removeFromWishlist({
    required String userId,
    required String productId,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await WishlistService.removeFromWishlist(userId, productId);
      
      if (result['success']) {
        // Directly remove the item from local state for immediate UI update
        _wishlistItems.removeWhere((item) => item['productId'] == productId);
        notifyListeners(); // Force immediate UI update
        
        // Also try to reload for full sync (but don't wait for it)
        loadWishlist(userId).catchError((e) {
          print('Background sync failed: $e');
        });
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to remove from wishlist: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Check if product is in wishlist (synchronous - checks local list)
  bool isInWishlist(String productId) {
    final isInList = _wishlistItems.any((item) => item['productId'] == productId);
    return isInList;
  }

  // Check if product is in wishlist (asynchronous - checks database)
  Future<bool> isProductInWishlist(String userId, String productId) async {
    try {
      return await WishlistService.isInWishlist(userId, productId);
    } catch (e) {
      print('Error checking wishlist status: $e');
      return false;
    }
  }

  // Get wishlist items by category
  Future<List<Map<String, dynamic>>> getWishlistByCategory(String userId, String category) async {
    try {
      return await WishlistService.getWishlistByCategory(userId, category);
    } catch (e) {
      _setError('Failed to get wishlist by category: ${e.toString()}');
      return [];
    }
  }

  // Clear entire wishlist
  Future<bool> clearWishlist(String userId) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await WishlistService.clearWishlist(userId);
      
      if (result['success']) {
        _wishlistItems.clear();
        _wishlistStats = null;
        _wishlistAnalytics = null;
        notifyListeners();
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to clear wishlist: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Move wishlist item to cart
  Future<bool> moveToCart({
    required String userId,
    required String productId,
    required Function addToCartCallback,
  }) async {
    _setLoading(true);
    _clearError();
    
    try {
      final result = await WishlistService.moveToCart(userId, productId);
      
      if (result['success']) {
        // Just reload wishlist items, skip stats/analytics for performance
        await loadWishlist(userId);
        return true;
      } else {
        _setError(result['message']);
        return false;
      }
    } catch (e) {
      _setError('Failed to move to cart: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get wishlist recommendations
  Future<List<Map<String, dynamic>>> getWishlistRecommendations(String userId) async {
    try {
      return await WishlistService.getWishlistRecommendations(userId);
    } catch (e) {
      _setError('Failed to get recommendations: ${e.toString()}');
      return [];
    }
  }

  // Load wishlist statistics
  Future<void> _loadWishlistStats(String userId) async {
    try {
      _wishlistStats = await WishlistService.getWishlistStatistics(userId);
    } catch (e) {
      print('Error loading wishlist stats: $e');
    }
  }

  // Load wishlist analytics
  Future<void> _loadWishlistAnalytics(String userId) async {
    try {
      _wishlistAnalytics = await WishlistService.getWishlistAnalytics(userId);
    } catch (e) {
      print('Error loading wishlist analytics: $e');
    }
  }

  // Manual refresh method (resets circuit breaker)
  Future<void> forceRefresh(String userId) async {
    print('🔥 WishlistProvider: Force refreshing for user $userId');
    _isInitialized = false;
    _hasLoadError = false;
    _lastLoadTime = null;
    await initializeWishlist(userId);
  }

  // Search wishlist items
  List<Map<String, dynamic>> searchWishlistItems(String query) {
    if (query.isEmpty) return _wishlistItems;
    
    return _wishlistItems.where((item) {
      final name = (item['productName'] ?? '').toString().toLowerCase();
      final description = (item['productDescription'] ?? '').toString().toLowerCase();
      final category = item['productCategory'];
      String categoryString;
      if (category == null) {
        categoryString = 'Other';
      } else if (category is String) {
        categoryString = category;
      } else {
        categoryString = category.toString();
      }
      final searchQuery = query.toLowerCase();
      
      return name.contains(searchQuery) ||
             description.contains(searchQuery) ||
             categoryString.toLowerCase().contains(searchQuery);
    }).toList();
  }

  // Filter wishlist items by category
  List<Map<String, dynamic>> filterWishlistByCategory(String category) {
    if (category.isEmpty || category == 'All') return _wishlistItems;
    
    return _wishlistItems.where((item) {
      final itemCategory = item['productCategory'];
      if (itemCategory == null) return category == 'Other';
      if (itemCategory is String) return itemCategory == category;
      return itemCategory.toString() == category;
    }).toList();
  }

  // Sort wishlist items
  List<Map<String, dynamic>> sortWishlistItems(String sortBy) {
    final sortedItems = List<Map<String, dynamic>>.from(_wishlistItems);
    
    switch (sortBy) {
      case 'price_low_to_high':
        sortedItems.sort((a, b) => (a['productPrice'] ?? 0.0).compareTo(b['productPrice'] ?? 0.0));
        break;
      case 'price_high_to_low':
        sortedItems.sort((a, b) => (b['productPrice'] ?? 0.0).compareTo(a['productPrice'] ?? 0.0));
        break;
      case 'name_a_to_z':
        sortedItems.sort((a, b) => (a['productName'] ?? '').compareTo(b['productName'] ?? ''));
        break;
      case 'name_z_to_a':
        sortedItems.sort((a, b) => (b['productName'] ?? '').compareTo(a['productName'] ?? ''));
        break;
      case 'recently_added':
        sortedItems.sort((a, b) {
          final aDate = a['addedAt'] ?? DateTime.now();
          final bDate = b['addedAt'] ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
        break;
      default:
        // Default: recently added
        sortedItems.sort((a, b) {
          final aDate = a['addedAt'] ?? DateTime.now();
          final bDate = b['addedAt'] ?? DateTime.now();
          return bDate.compareTo(aDate);
        });
    }
    
    return sortedItems;
  }

  // Get available categories from wishlist
  List<String> get availableCategories {
    final categories = _wishlistItems
        .map((item) {
          final category = item['productCategory'];
          if (category == null) return 'Other';
          if (category is String) return category;
          return category.toString();
        })
        .toSet()
        .toList();
    categories.sort();
    return ['All', ...categories];
  }

  // Get total value of wishlist
  double get totalWishlistValue {
    return _wishlistItems.fold(0.0, (sum, item) {
      return sum + (item['productPrice'] ?? 0.0);
    });
  }

  // Get average price of wishlist items
  double get averageWishlistPrice {
    if (_wishlistItems.isEmpty) return 0.0;
    return totalWishlistValue / _wishlistItems.length;
  }

  // Get category breakdown
  Map<String, int> get categoryBreakdown {
    final breakdown = <String, int>{};
    for (var item in _wishlistItems) {
      final category = item['productCategory'];
      String categoryString;
      if (category == null) {
        categoryString = 'Other';
      } else if (category is String) {
        categoryString = category;
      } else {
        categoryString = category.toString();
      }
      breakdown[categoryString] = (breakdown[categoryString] ?? 0) + 1;
    }
    return breakdown;
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    // Check if we're in build phase before notifying
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      notifyListeners();
    } else {
      // Defer notifyListeners only if called during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _setError(String error) {
    _error = error;
    // Check if we're in build phase before notifying
    if (WidgetsBinding.instance.schedulerPhase != SchedulerPhase.persistentCallbacks) {
      notifyListeners();
    } else {
      // Defer notifyListeners only if called during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
  }
}
