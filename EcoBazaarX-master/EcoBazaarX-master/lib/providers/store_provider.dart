import 'dart:math';
import 'package:flutter/foundation.dart';
import '../services/store_service.dart';

class StoreProvider with ChangeNotifier {
  
  List<Map<String, dynamic>> _allStores = [];
  List<Map<String, dynamic>> _filteredStores = [];
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic>? _selectedStore;

  // Getters
  List<Map<String, dynamic>> get allStores => _allStores;
  List<Map<String, dynamic>> get filteredStores => _filteredStores;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic>? get selectedStore => _selectedStore;

  // Available store categories for dropdowns
  List<String> get availableCategories => [
    'General Store',
    'Specialty Store',
    'Local Store',
    'Premium Store',
    'Organic Store',
    'Electronics Store',
    'Fashion Store',
    'Home & Garden Store',
    'Food & Beverages Store',
    'Personal Care Store',
  ];

  // Available locations for dropdowns
  List<String> get availableLocations => [
    'Mumbai, Maharashtra',
    'Delhi, NCR',
    'Bangalore, Karnataka',
    'Chennai, Tamil Nadu',
    'Pune, Maharashtra',
    'Hyderabad, Telangana',
    'Kolkata, West Bengal',
    'Ahmedabad, Gujarat',
    'Jaipur, Rajasthan',
    'Lucknow, Uttar Pradesh',
  ];

  // Initialize stores from MySQL backend
  Future<void> initializeStores() async {
    await loadStores(); // Use the updated loadStores method
  }

  // Load stores from MySQL backend via Spring Boot API
  Future<void> loadStores() async {
    try {
      _setLoading(true);
      _error = null;
      
      List<Map<String, dynamic>> stores = await StoreService.getAllStores();
      
      // Transform backend data to match frontend expectations
      _allStores = stores.map((store) {
        return {
          'id': store['id']?.toString() ?? store['storeId'] ?? 'unknown',
          'storeId': store['storeId'] ?? store['id']?.toString() ?? 'unknown',
          'name': store['storeName'] ?? store['name'] ?? 'Unknown Store',
          'category': store['category'] ?? 'Other',
          'description': store['description'] ?? '',
          'ownerId': store['ownerId'] ?? '',
          'ownerEmail': store['ownerEmail'] ?? '',
          'contactPhone': store['contactPhone'] ?? '',
          'address': store['address'] ?? '',
          'city': store['city'] ?? '',
          'state': store['state'] ?? '',
          'pincode': store['pincode'] ?? '',
          'isActive': store['isActive'] ?? true,
          'isVerified': store['isVerified'] ?? false,
          'totalProducts': store['totalProducts'] ?? 0,
          'ecoRating': store['ecoRating'] ?? 0.0,
          'logoUrl': store['logoUrl'] ?? '',
          'bannerUrl': store['bannerUrl'] ?? '',
          'createdAt': store['createdAt'] ?? DateTime.now().toIso8601String(),
          'updatedAt': store['updatedAt'] ?? DateTime.now().toIso8601String(),
          // Add analytics data for compatibility
          'status': (store['isActive'] ?? true) ? 'Active' : 'Inactive',
          'revenue': Random().nextInt(50000) + 10000, // Random revenue for analytics
          'products': store['totalProducts'] ?? Random().nextInt(100),
          'performance': Random().nextDouble() * 0.4 + 0.6, // 60-100% performance
          'onlineUsers': Random().nextInt(50),
          'lastOrder': DateTime.now().subtract(Duration(hours: Random().nextInt(24))),
          'lastUpdated': DateTime.now(),
        };
      }).toList();
      
      _filteredStores = _allStores;
      print('Loaded ${_allStores.length} stores from MySQL backend');
    } catch (e) {
      print('Error loading stores from backend: $e');
      _error = 'Failed to load stores: ${e.toString()}';
      // Fallback to empty list instead of static data
      _allStores = [];
      _filteredStores = [];
    } finally {
      _setLoading(false);
    }
  }

  // Add a new store
  Future<Map<String, dynamic>> addStore(Map<String, dynamic> storeData) async {
    try {
      _setLoading(true);
      _error = null;
      
      final result = await StoreService.createStore(
        name: storeData['name'] ?? '',
        description: storeData['description'] ?? '',
        category: storeData['category'] ?? '',
        ownerId: storeData['ownerId'] ?? '',
        imageUrl: storeData['imageUrl'],
        address: storeData['address'],
        phone: storeData['phone'],
        email: storeData['email'],
      );
      
      if (result['success']) {
        // Reload stores from Firebase
        await loadStores();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to add store: ${e.toString()}';
      return {
        'success': false,
        'message': _error!,
      };
    } finally {
      _setLoading(false);
    }
  }

  // Update store
  Future<Map<String, dynamic>> updateStore(String storeId, Map<String, dynamic> updateData) async {
    try {
      _setLoading(true);
      _error = null;
      
      final result = await StoreService.updateStore(
        storeId: storeId,
        name: updateData['name'],
        description: updateData['description'],
        category: updateData['category'],
        ownerId: updateData['ownerId'],
        imageUrl: updateData['imageUrl'],
        address: updateData['address'],
        phone: updateData['phone'],
        email: updateData['email'],
      );
      
      if (result['success']) {
        // Reload stores from Firebase
        await loadStores();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to update store: ${e.toString()}';
      return {
        'success': false,
        'message': _error!,
      };
    } finally {
      _setLoading(false);
    }
  }

  // Delete store
  Future<Map<String, dynamic>> deleteStore(String storeId) async {
    try {
      _setLoading(true);
      _error = null;
      
      final result = await StoreService.deleteStore(storeId);
      
      if (result['success']) {
        // Reload stores from Firebase
        await loadStores();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to delete store: ${e.toString()}';
      return {
        'success': false,
        'message': _error!,
      };
    } finally {
      _setLoading(false);
    }
  }

  // Toggle store status
  Future<Map<String, dynamic>> toggleStoreStatus(String storeId) async {
    try {
      // Get current store status - will be used when implementing the API
      // final store = _allStores.firstWhere((s) => s['id'] == storeId);
      // final currentStatus = store['isActive'] ?? true;
      // final newStatus = !currentStatus;
      
      // TODO: Implement toggleStoreStatus with Spring Boot API
      final result = {'success': false, 'message': 'Toggle store status not implemented yet'};
      
      if (result['success'] == true) {
        // Reload stores from Firebase
        await loadStores();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to toggle store status: ${e.toString()}';
      return {
        'success': false,
        'message': _error!,
      };
    }
  }

  // Get store by ID
  Map<String, dynamic>? getStoreById(String storeId) {
    try {
      return _allStores.firstWhere((store) => store['id'] == storeId);
    } catch (e) {
      return null;
    }
  }

  // Get stores by category
  List<Map<String, dynamic>> getStoresByCategory(String category) {
    return _allStores.where((store) => store['category'] == category).toList();
  }

  // Get stores by location
  List<Map<String, dynamic>> getStoresByLocation(String location) {
    return _allStores.where((store) => store['location'] == location).toList();
  }

  // Get stores by status
  List<Map<String, dynamic>> getStoresByStatus(bool isActive) {
    return _allStores.where((store) => store['isActive'] == isActive).toList();
  }

  // Get stores by owner
  List<Map<String, dynamic>> getStoresByOwner(String ownerId) {
    return _allStores.where((store) => store['ownerId'] == ownerId).toList();
  }

  // Search stores
  List<Map<String, dynamic>> searchStores(String query) {
    if (query.isEmpty) {
      _filteredStores = _allStores;
    } else {
      _filteredStores = _allStores.where((store) {
        final name = store['name']?.toString().toLowerCase() ?? '';
        final description = store['description']?.toString().toLowerCase() ?? '';
        final category = store['category']?.toString().toLowerCase() ?? '';
        final location = store['location']?.toString().toLowerCase() ?? '';
        final ownerName = store['ownerName']?.toString().toLowerCase() ?? '';
        
        final searchQuery = query.toLowerCase();
        
        return name.contains(searchQuery) ||
               description.contains(searchQuery) ||
               category.contains(searchQuery) ||
               location.contains(searchQuery) ||
               ownerName.contains(searchQuery);
      }).toList();
    }
    notifyListeners();
    return _filteredStores;
  }

  // Search stores in Firebase
  Future<List<Map<String, dynamic>>> searchStoresFirebase(String query) async {
    try {
      return await StoreService.searchStores(query);
    } catch (e) {
      print('Error searching stores in Firebase: $e');
      return searchStores(query);
    }
  }

  // Filter stores
  void filterStores({
    String? category,
    String? location,
    bool? isActive,
    String? sortBy,
    bool ascending = true,
  }) {
    _filteredStores = _allStores.where((store) {
      bool matchesCategory = category == null || store['category'] == category;
      bool matchesLocation = location == null || store['location'] == location;
      bool matchesStatus = isActive == null || store['isActive'] == isActive;
      
      return matchesCategory && matchesLocation && matchesStatus;
    }).toList();

    // Sort stores
    if (sortBy != null) {
      _filteredStores.sort((a, b) {
        dynamic aValue = a[sortBy];
        dynamic bValue = b[sortBy];
        
        aValue ??= ascending ? double.negativeInfinity : double.infinity;
        bValue ??= ascending ? double.negativeInfinity : double.infinity;
        
        if (aValue is String && bValue is String) {
          return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        } else if (aValue is num && bValue is num) {
          return ascending ? aValue.compareTo(bValue) : bValue.compareTo(aValue);
        }
        
        return 0;
      });
    }

    notifyListeners();
  }

  // Clear filters
  void clearFilters() {
    _filteredStores = _allStores;
    notifyListeners();
  }

  // Set selected store
  void setSelectedStore(Map<String, dynamic>? store) {
    _selectedStore = store;
    notifyListeners();
  }

  // Create new store
  Future<Map<String, dynamic>> createStore(Map<String, dynamic> store, {String? authToken}) async {
    try {
      _setLoading(true);
      _error = null;
      
      final result = await StoreService.createStore(
        name: store['name'] ?? '',
        description: store['description'] ?? '',
        category: store['category'] ?? 'General Store',
        ownerId: store['ownerId'] ?? '',
        imageUrl: store['imageUrl'],
        address: store['address'],
        phone: store['phone'],
        email: store['email'],
        authToken: authToken,
      );
      
      if (result['success'] == true) {
        // Reload stores from backend
        await loadStores();
      }
      
      return result;
    } catch (e) {
      _error = 'Failed to create store: ${e.toString()}';
      return {
        'success': false,
        'message': _error!,
      };
    } finally {
      _setLoading(false);
    }
  }

  // Get store statistics
  Future<Map<String, dynamic>> getStoreStats() async {
    try {
      return await StoreService.getStoreStatistics('dummy-store-id');
    } catch (e) {
      print('Error getting store stats: $e');
      return {
        'totalStores': _allStores.length,
        'activeStores': _allStores.where((store) => store['isActive'] == true).length,
        'totalProducts': _allStores.fold(0, (sum, store) => sum + ((store['totalProducts'] ?? 0) as int)),
        'totalRevenue': _allStores.fold(0.0, (sum, store) => sum + (store['totalRevenue'] ?? 0.0)),
        'categories': _allStores.map((store) => store['category'] ?? '').toSet().toList(),
        'averageProductsPerStore': _allStores.isNotEmpty 
            ? _allStores.fold(0, (sum, store) => sum + ((store['totalProducts'] ?? 0) as int)) / _allStores.length 
            : 0.0,
      };
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

