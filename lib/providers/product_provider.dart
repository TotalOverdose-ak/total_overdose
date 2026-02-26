import 'package:flutter/material.dart';
import 'dart:math';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  
  // Centralized product data that both shopkeeper and admin can access
  List<Map<String, dynamic>> _allProducts = [];
  bool _isLoading = false;
  String? _error;

  // Centralized product data that both shopkeeper and admin can access
  static final List<Map<String, dynamic>> _staticProducts = [
    {
      'id': '1',
      'name': 'Men Grey Hoodie',
      'category': 'Clothing',
      'price': 49.90,
      'quantity': 96,
      'carbonFootprint': 5.2,
      'waterSaved': 2500, // liters of water saved compared to conventional cotton
      'energySaved': 45, // kWh of energy saved
      'wasteReduced': 2.5, // kg of waste reduced
      'treesEquivalent': 0.26, // trees equivalent (1 tree = 20kg CO2)
      'image': 'hoodie',
      'description': 'Eco-friendly cotton hoodie made from sustainable materials. This product saves 2500L of water and 45kWh of energy compared to conventional cotton production.',
      'material': 'Organic Cotton',
      'color': const Color(0xFFB5C7F7),
      'icon': Icons.checkroom_rounded,
      'storeId': '1', // Which store this product belongs to
      'storeName': 'GreenMart',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 30)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 2)),
    },
    {
      'id': '2',
      'name': 'Women Striped T-Shirt',
      'category': 'Clothing',
      'price': 34.90,
      'quantity': 56,
      'carbonFootprint': 3.1,
      'waterSaved': 1800,
      'energySaved': 32,
      'wasteReduced': 1.8,
      'treesEquivalent': 0.155,
      'image': 'tshirt',
      'description': 'Comfortable striped t-shirt made from recycled materials. Reduces water usage by 1800L and saves 32kWh of energy compared to virgin polyester.',
      'material': 'Recycled Polyester',
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.checkroom_rounded,
      'storeId': '2',
      'storeName': 'EcoShop',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 25)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 5)),
    },
    {
      'id': '3',
      'name': 'Bamboo Water Bottle',
      'category': 'Accessories',
      'price': 29.90,
      'quantity': 120,
      'carbonFootprint': 1.8,
      'waterSaved': 500,
      'energySaved': 15,
      'wasteReduced': 3.2,
      'treesEquivalent': 0.09,
      'image': 'bottle',
      'description': 'Sustainable bamboo water bottle, perfect for daily use. Replaces 500 plastic bottles and saves 15kWh of energy in production.',
      'material': 'Bamboo',
      'color': const Color(0xFFF9E79F),
      'icon': Icons.water_drop_rounded,
      'storeId': '1',
      'storeName': 'GreenMart',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 20)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      'id': '4',
      'name': 'Solar Phone Charger',
      'category': 'Electronics',
      'price': 89.90,
      'quantity': 45,
      'carbonFootprint': 2.5,
      'waterSaved': 800,
      'energySaved': 120,
      'wasteReduced': 1.5,
      'treesEquivalent': 0.125,
      'image': 'charger',
      'description': 'Portable solar charger for eco-friendly charging. Generates clean energy and saves 120kWh annually, equivalent to planting 0.125 trees.',
      'material': 'Recycled Plastic',
      'color': const Color(0xFFD6EAF8),
      'icon': Icons.solar_power_rounded,
      'storeId': '4',
      'storeName': 'Green Corner',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 15)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 3)),
    },
    {
      'id': '5',
      'name': 'Organic Cotton Tote',
      'category': 'Accessories',
      'price': 24.90,
      'quantity': 200,
      'carbonFootprint': 1.2,
      'waterSaved': 600,
      'energySaved': 8,
      'wasteReduced': 4.0,
      'treesEquivalent': 0.06,
      'image': 'tote',
      'description': 'Reusable shopping bag made from organic cotton. Replaces 400 plastic bags and saves 600L of water in production.',
      'material': 'Organic Cotton',
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.shopping_bag_rounded,
      'storeId': '2',
      'storeName': 'EcoShop',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 18)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 4)),
    },
    {
      'id': '6',
      'name': 'Bamboo Toothbrush',
      'category': 'Personal Care',
      'price': 8.90,
      'quantity': 300,
      'carbonFootprint': 0.5,
      'waterSaved': 200,
      'energySaved': 3,
      'wasteReduced': 0.8,
      'treesEquivalent': 0.025,
      'image': 'toothbrush',
      'description': 'Biodegradable bamboo toothbrush with soft bristles. Replaces plastic toothbrushes and saves 200L of water in production.',
      'material': 'Bamboo',
      'color': const Color(0xFFF9E79F),
      'icon': Icons.brush_rounded,
      'storeId': '1',
      'storeName': 'GreenMart',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 12)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 6)),
    },
    {
      'id': '7',
      'name': 'Organic Soap Bar',
      'category': 'Personal Care',
      'price': 12.90,
      'quantity': 150,
      'carbonFootprint': 0.8,
      'waterSaved': 300,
      'energySaved': 5,
      'wasteReduced': 1.2,
      'treesEquivalent': 0.04,
      'image': 'soap',
      'description': 'Natural organic soap made with essential oils. Saves 300L of water and reduces packaging waste by 1.2kg compared to liquid soaps.',
      'material': 'Organic Oils',
      'color': const Color(0xFFE8F5E8),
      'icon': Icons.spa_rounded,
      'storeId': '2',
      'storeName': 'EcoShop',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 10)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 7)),
    },
    {
      'id': '8',
      'name': 'Recycled Notebook',
      'category': 'Accessories',
      'price': 15.90,
      'quantity': 80,
      'carbonFootprint': 1.2,
      'waterSaved': 400,
      'energySaved': 12,
      'wasteReduced': 2.0,
      'treesEquivalent': 0.06,
      'image': 'notebook',
      'description': 'Eco-friendly notebook made from recycled paper. Saves 400L of water and 12kWh of energy compared to virgin paper production.',
      'material': 'Recycled Paper',
      'color': const Color(0xFFF5F5E8),
      'icon': Icons.book_rounded,
      'storeId': '3',
      'storeName': 'Green Corner',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 8)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 8)),
    },
    {
      'id': '9',
      'name': 'Hemp Face Mask',
      'category': 'Personal Care',
      'price': 18.90,
      'quantity': 120,
      'carbonFootprint': 1.5,
      'waterSaved': 350,
      'energySaved': 8,
      'wasteReduced': 1.8,
      'treesEquivalent': 0.075,
      'image': 'mask',
      'description': 'Reusable face mask made from sustainable hemp. Replaces 50 disposable masks and saves 350L of water in production.',
      'material': 'Hemp',
      'color': const Color(0xFFE8D5C4),
      'icon': Icons.face_rounded,
      'storeId': '1',
      'storeName': 'GreenMart',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 6)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 9)),
    },
    {
      'id': '10',
      'name': 'Cork Yoga Mat',
      'category': 'Accessories',
      'price': 45.90,
      'quantity': 60,
      'carbonFootprint': 2.8,
      'waterSaved': 600,
      'energySaved': 25,
      'wasteReduced': 2.2,
      'treesEquivalent': 0.14,
      'image': 'yogamat',
      'description': 'Natural cork yoga mat for eco-conscious fitness. Sustainable cork harvesting saves 600L of water and 25kWh of energy.',
      'material': 'Cork',
      'color': const Color(0xFFD6EAF8),
      'icon': Icons.fitness_center_rounded,
      'storeId': '4',
      'storeName': 'Green Corner',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 5)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 10)),
    },
    {
      'id': '11',
      'name': 'Jute Plant Pot',
      'category': 'Home & Garden',
      'price': 22.90,
      'quantity': 90,
      'carbonFootprint': 1.8,
      'waterSaved': 450,
      'energySaved': 10,
      'wasteReduced': 1.5,
      'treesEquivalent': 0.09,
      'image': 'plantpot',
      'description': 'Biodegradable plant pot made from natural jute. Replaces plastic pots and saves 450L of water in production.',
      'material': 'Jute',
      'color': const Color(0xFFF9E79F),
      'icon': Icons.local_florist_rounded,
      'storeId': '2',
      'storeName': 'EcoShop',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 4)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 11)),
    },
    {
      'id': '12',
      'name': 'Organic Tea Set',
      'category': 'Food & Beverages',
      'price': 35.90,
      'quantity': 75,
      'carbonFootprint': 2.2,
      'waterSaved': 550,
      'energySaved': 18,
      'wasteReduced': 1.8,
      'treesEquivalent': 0.11,
      'image': 'teaset',
      'description': 'Ceramic tea set with organic tea leaves. Sustainable ceramic production saves 550L of water and 18kWh of energy.',
      'material': 'Ceramic',
      'color': const Color(0xFFE8F5E8),
      'icon': Icons.local_cafe_rounded,
      'storeId': '3',
      'storeName': 'Green Corner',
      'isActive': true,
      'createdAt': DateTime.now().subtract(const Duration(days: 3)),
      'updatedAt': DateTime.now().subtract(const Duration(hours: 12)),
    },
  ];

  // Getters
  List<Map<String, dynamic>> get allProducts => _allProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize products from Firebase
  Future<void> initializeProducts() async {
    _setLoading(true);
    try {
      // Try to load from Firebase first
      _allProducts = await ProductService.getAllProducts();
      _error = null;
      
      // If no products in Firebase, initialize sample data
      if (_allProducts.isEmpty) {
        print('No products found in Firebase, initializing sample data...');
        // await ProductService.initializeSampleProducts(); // Method doesn't exist yet
        _allProducts = await ProductService.getAllProducts();
      }
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      print('Error initializing products: $e');
      // Fallback to static data
      _allProducts = await ProductService.getAllProducts();
    } finally {
      _setLoading(false);
    }
  }

  // Load products from Spring Boot backend
  Future<void> loadProducts() async {
    _setLoading(true);
    try {
      print('📦 Loading products from backend...');
      final backendProducts = await ProductService.getAllProducts();
      
      if (backendProducts.isNotEmpty) {
        print('📦 Loaded ${backendProducts.length} products from backend');
        _allProducts = backendProducts.map((product) => {
          'id': product['id'].toString(),
          'name': product['name'] ?? '',
          'description': product['description'] ?? '',
          'price': (product['price'] ?? 0.0).toDouble(),
          'quantity': product['quantity'] ?? 0,
          'category': product['category'] ?? 'General',
          'imageUrl': product['imageUrl'] ?? '',
          'storeId': product['storeId'] ?? '',
          'storeName': product['storeName'] ?? '',
          'carbonFootprint': (product['carbonFootprint'] ?? 0.0).toDouble(),
          'ecoPoints': product['ecoPoints'] ?? 0,
          'isActive': product['isActive'] ?? true,
          'createdAt': DateTime.tryParse(product['createdAt'] ?? '') ?? DateTime.now(),
          'updatedAt': DateTime.tryParse(product['updatedAt'] ?? '') ?? DateTime.now(),
          'icon': Icons.inventory_2,
          'color': const Color(0xFF4CAF50),
        }).toList();
      } else {
        print('📦 No products found in backend, using static data');
        _allProducts = List.from(_staticProducts);
      }
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      print('❌ Error loading products: $e');
      // Fallback to static products on error
      _allProducts = List.from(_staticProducts);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load products by category from Firebase
  Future<void> loadProductsByCategory(String category) async {
    _setLoading(true);
    try {
      _allProducts = await ProductService.getProductsByCategory(category);
      _error = null;
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      print('Error loading products by category: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Load products by store from Firebase
  Future<void> loadProductsByStore(String storeId) async {
    _setLoading(true);
    try {
      // TODO: Implement getProductsByStore with Spring Boot API
      // _allProducts = await ProductService.getProductsByStore(storeId);
      _allProducts = [];
      _error = null;
    } catch (e) {
      _error = 'Failed to load products: ${e.toString()}';
      print('Error loading products by store: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Search products in Firebase
  Future<void> searchProductsFirebase(String query) async {
    _setLoading(true);
    try {
      _allProducts = await ProductService.searchProducts(query);
      _error = null;
    } catch (e) {
      _error = 'Failed to search products: ${e.toString()}';
      print('Error searching products: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Get featured products from Firebase
  Future<List<Map<String, dynamic>>> getFeaturedProducts({int limit = 6}) async {
    try {
      return await ProductService.getFeaturedProducts();
    } catch (e) {
      print('Error getting featured products: $e');
      return [];
    }
  }

  // Get low stock products from Firebase
  Future<List<Map<String, dynamic>>> getLowStockProducts({int threshold = 10}) async {
    try {
      return await ProductService.getLowStockProducts(threshold);
    } catch (e) {
      print('Error getting low stock products: $e');
      return [];
    }
  }

  // Get product statistics from Firebase
  Future<Map<String, dynamic>> getProductStats() async {
    try {
      return await ProductService.getProductStatistics();
    } catch (e) {
      print('Error getting product stats: $e');
      return {
        'totalProducts': 0,
        'totalValue': 0.0,
        'totalQuantity': 0,
        'totalCarbonSaved': 0.0,
        'categories': [],
        'averagePrice': 0.0,
      };
    }
  }

  // Helper method to set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Get products by store
  List<Map<String, dynamic>> getProductsByStore(String storeId) {
    return _allProducts.where((product) => product['storeId'] == storeId).toList();
  }

  // Get active products
  List<Map<String, dynamic>> get activeProducts {
    return _allProducts.where((product) => product['isActive'] == true).toList();
  }

  // Get total products count
  int get totalProducts => _allProducts.length;

  // Get active products count
  int get activeProductsCount => activeProducts.length;

  // Add new product
  Future<Map<String, dynamic>> addProduct(Map<String, dynamic> product, {String? authToken, String? storeId, String? storeName}) async {
    try {
      print('📦 ProductProvider: Adding product - ${product['name']}');
      
      // Validate required fields
      if (product['name'] == null || product['name'].toString().trim().isEmpty) {
        return {
          'success': false,
          'message': 'Product name is required',
          'field': 'name'
        };
      }
      
      if (product['price'] == null || product['price'] == 0) {
        return {
          'success': false,
          'message': 'Product price is required and must be greater than 0',
          'field': 'price'
        };
      }
      
      if (product['category'] == null || product['category'].toString().trim().isEmpty) {
        return {
          'success': false,
          'message': 'Product category is required',
          'field': 'category'
        };
      }
      
      // Set default values for missing fields
      product['description'] = product['description'] ?? '';
      product['quantity'] = product['quantity'] ?? 1;
      product['imageUrl'] = product['imageUrl'] ?? '';
      product['carbonFootprint'] = _generateCarbonFootprint(product['category']);
      
      // Ensure storeId is available
      final finalStoreId = storeId ?? product['storeId'] ?? 'store-001';
      final finalStoreName = storeName ?? product['storeName'] ?? 'Default Store';
      
      print('📦 Sending to backend with storeId: $finalStoreId, storeName: $finalStoreName');
      
      // Add to Spring Boot backend
      final result = await ProductService.addProduct(
        name: product['name'].toString().trim(),
        description: product['description'].toString(),
        price: double.tryParse(product['price'].toString()) ?? 0.0,
        stock: int.tryParse(product['quantity'].toString()) ?? 1,
        category: product['category'].toString().trim(),
        storeId: finalStoreId,
        storeName: finalStoreName,
        imageUrl: product['imageUrl'].toString(),
        icon: product['icon']?.toString(),
        color: product['color']?.toString(),
        authToken: authToken,
      );
      
      print('📦 Backend result: ${result['success']} - ${result['message']}');
      
      if (result['success']) {
        // Reload products from backend
        await loadProducts();
        notifyListeners();
        return {
          'success': true,
          'message': 'Product added successfully!',
          'product': result['product']
        };
      } else {
        return result;
      }
    } catch (e) {
      print('❌ Error in ProductProvider.addProduct: $e');
      return {
        'success': false,
        'message': 'Failed to add product: ${e.toString()}',
        'error': e.toString()
      };
    }
  }

  // Update product
  Future<Map<String, dynamic>> updateProduct(String productId, Map<String, dynamic> updatedData) async {
    try {
      final result = await ProductService.updateProduct(
        productId: productId,
        name: updatedData['name'],
        description: updatedData['description'],
        price: updatedData['price']?.toDouble(),
        stock: updatedData['quantity'],
        category: updatedData['category'],
        imageUrl: updatedData['imageUrl'],
        icon: updatedData['icon'],
        color: updatedData['color'],
      );
      
      if (result['success']) {
        // Reload products from Firebase
        await loadProducts();
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update product: ${e.toString()}',
      };
    }
  }

  // Delete product
  Future<Map<String, dynamic>> deleteProduct(String productId) async {
    try {
      final result = await ProductService.deleteProduct(productId);
      
      if (result['success']) {
        // Reload products from Firebase
        await loadProducts();
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete product: ${e.toString()}',
      };
    }
  }

  // Toggle product status
  Future<Map<String, dynamic>> toggleProductStatus(String productId) async {
    try {
      // Get current product status
      final product = _allProducts.firstWhere((p) => p['id'] == productId);
      final currentStatus = product['isActive'] ?? true;
      final newStatus = !currentStatus;
      
      // TODO: Implement toggleProductStatus with Spring Boot API
      // final result = await ProductService.toggleProductStatus(productId, newStatus);
      final result = {'success': false, 'message': 'Toggle product status not implemented yet'};
      
      if (result['success'] == true) {
        // Reload products from Firebase
        await loadProducts();
      }
      
      return result;
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to toggle product status: ${e.toString()}',
      };
    }
  }

  // Get product by ID
  Map<String, dynamic>? getProductById(String productId) {
    try {
      return _allProducts.firstWhere((product) => product['id'] == productId);
    } catch (e) {
      return null;
    }
  }

  // Get products by category
  List<Map<String, dynamic>> getProductsByCategory(String category) {
    return _allProducts.where((product) => product['category'] == category).toList();
  }

  // Get products by status
  List<Map<String, dynamic>> getProductsByStatus(bool isActive) {
    return _allProducts.where((product) => product['isActive'] == isActive).toList();
  }

  // Search products by name or description
  List<Map<String, dynamic>> searchProducts(String query) {
    return _allProducts.where((product) => 
      product['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
      product['description'].toString().toLowerCase().contains(query.toLowerCase()) ||
      product['category'].toString().toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  // Get products by store owner (for shopkeeper dashboard)
  List<Map<String, dynamic>> getProductsByStoreOwner(String ownerId) {
    // First get stores owned by this owner
    final stores = _allProducts.where((product) {
      // This is a simplified check - in real app you'd check store ownership
      return product['storeName'] != null;
    }).toList();
    
    return stores;
  }

  // Helper method to generate carbon footprint based on category
  double _generateCarbonFootprint(String category) {
    switch (category.toLowerCase()) {
      case 'clothing':
        return 2.0 + (Random().nextDouble() * 4.0); // 2.0 to 6.0
      case 'accessories':
        return 0.5 + (Random().nextDouble() * 2.0); // 0.5 to 2.5
      case 'electronics':
        return 1.5 + (Random().nextDouble() * 3.0); // 1.5 to 4.5
      case 'personal care':
        return 0.3 + (Random().nextDouble() * 1.5); // 0.3 to 1.8
      case 'food & beverages':
        return 0.8 + (Random().nextDouble() * 2.0); // 0.8 to 2.8
      case 'home & garden':
        return 1.0 + (Random().nextDouble() * 3.0); // 1.0 to 4.0
      default:
        return 1.0 + (Random().nextDouble() * 2.0); // 1.0 to 3.0
    }
  }

  // Get available categories
  List<String> get availableCategories => [
    'Clothing',
    'Accessories', 
    'Electronics',
    'Personal Care',
    'Beauty & Personal Care',
    'Food & Beverages',
    'Home & Garden',
    'Home & Living',
    'Fashion',
    'Office & Stationery',
  ];

  // Get available materials
  List<String> get availableMaterials => [
    'Organic Cotton',
    'Recycled Polyester',
    'Bamboo',
    'Recycled Plastic',
    'Hemp',
    'Cork',
    'Jute',
    'Recycled Paper',
  ];

  // Get color options for products
  List<Color> get availableColors => [
    const Color(0xFFB5C7F7),
    const Color(0xFFE8D5C4),
    const Color(0xFFF9E79F),
    const Color(0xFFD6EAF8),
    const Color(0xFFE8F5E8),
    const Color(0xFFF5E8E8),
    const Color(0xFFE8E8F5),
    const Color(0xFFF5F5E8),
  ];

  // Get icon options for products
  List<IconData> get availableIcons => [
    Icons.checkroom_rounded,
    Icons.water_drop_rounded,
    Icons.solar_power_rounded,
    Icons.shopping_bag_rounded,
    Icons.brush_rounded,
    Icons.restaurant_rounded,
    Icons.home_rounded,
    Icons.spa_rounded,
    Icons.eco_rounded,
    Icons.recycling_rounded,
  ];
}
