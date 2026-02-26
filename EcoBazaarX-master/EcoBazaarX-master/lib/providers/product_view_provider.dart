import 'package:flutter/material.dart';
import 'dart:math';

class ProductView {
  final String productId;
  final String name;
  final String description;
  final double price;
  final double rating;
  final String category;
  final IconData icon;
  final Color color;
  final DateTime viewedAt;

  ProductView({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.rating,
    required this.category,
    required this.icon,
    required this.color,
    required this.viewedAt,
  });
}

class ProductViewProvider extends ChangeNotifier {
  static final ProductViewProvider _instance = ProductViewProvider._internal();
  factory ProductViewProvider() => _instance;
  ProductViewProvider._internal();

  final List<ProductView> _viewedProducts = [];
  final Map<String, int> _categoryViewCounts = {};

  List<ProductView> get viewedProducts => List.from(_viewedProducts.reversed);
  
  int get totalProductsViewed => _viewedProducts.length;
  
  Map<String, int> get categoryViewCounts => Map.from(_categoryViewCounts);

  void addProductView(Map<String, dynamic> product) {
    // Check if product already exists in viewed list
    final existingIndex = _viewedProducts.indexWhere((view) => view.productId == product['id']);
    
    if (existingIndex != -1) {
      // Remove existing entry to add it at the top (most recent)
      _viewedProducts.removeAt(existingIndex);
    }

    // Add new product view at the beginning
    _viewedProducts.insert(0, ProductView(
      productId: product['id'] ?? 'unknown',
      name: product['name'] ?? 'Unknown Product',
      description: product['description'] ?? 'Eco-friendly product',
      price: _parsePrice(product['price']),
      rating: 4.0 + (Random().nextDouble() * 1.0), // Random rating between 4.0-5.0
      category: _parseCategory(product['category']),
      icon: _parseIcon(product['icon']),
      color: _parseColor(product['color']),
      viewedAt: DateTime.now(),
    ));

    // Update category view count
    final categoryString = _parseCategory(product['category']);
    _categoryViewCounts[categoryString] = (_categoryViewCounts[categoryString] ?? 0) + 1;

    // Keep only last 20 viewed products
    if (_viewedProducts.length > 20) {
      _viewedProducts.removeLast();
    }

    notifyListeners();
  }

  List<ProductView> getRecentlyViewed(int count) {
    return _viewedProducts.take(count).toList();
  }

  List<ProductView> getViewedProductsByCategory(String category) {
    return _viewedProducts.where((view) => view.category == category).toList();
  }

  void clearViewedProducts() {
    _viewedProducts.clear();
    _categoryViewCounts.clear();
    notifyListeners();
  }

  // Get top viewed categories
  List<MapEntry<String, int>> get topViewedCategories {
    final sortedCategories = _categoryViewCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedCategories.take(4).toList();
  }

  // Helper method to parse color to Color object
  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) {
      return const Color(0xFFB5C7F7); // Default color
    }
    
    // If it's already a Color object, return it
    if (colorValue is Color) {
      return colorValue;
    }
    
    // If it's a string, parse it
    if (colorValue is String) {
      if (colorValue.isEmpty) {
        return const Color(0xFFB5C7F7); // Default color
      }
      
      try {
        // Remove # if present
        String hex = colorValue.startsWith('#') ? colorValue.substring(1) : colorValue;
        
        // Handle different hex formats
        if (hex.length == 6) {
          return Color(int.parse('FF$hex', radix: 16));
        } else if (hex.length == 8) {
          return Color(int.parse(hex, radix: 16));
        } else {
          return const Color(0xFFB5C7F7); // Default color
        }
      } catch (e) {
        print('Error parsing color: $colorValue - $e');
        return const Color(0xFFB5C7F7); // Default color
      }
    }
    
    return const Color(0xFFB5C7F7); // Default color
  }



  // Helper method to parse category to String
  String _parseCategory(dynamic categoryValue) {
    if (categoryValue == null) {
      return 'General';
    }
    
    if (categoryValue is String) {
      return categoryValue;
    }
    
    return categoryValue.toString();
  }

  // Helper method to parse icon to IconData
  IconData _parseIcon(dynamic iconValue) {
    if (iconValue == null) {
      return Icons.shopping_bag_rounded; // Default icon
    }
    
    // If it's already an IconData object, return it
    if (iconValue is IconData) {
      return iconValue;
    }
    
    // If it's a string, parse it
    if (iconValue is String) {
      if (iconValue.isEmpty) {
        return Icons.shopping_bag_rounded; // Default icon
      }
      
      // Map of icon strings to IconData
      final iconMap = {
        'checkroom_rounded': Icons.checkroom_rounded,
        'water_drop_rounded': Icons.water_drop_rounded,
        'solar_power_rounded': Icons.solar_power_rounded,
        'shopping_bag_rounded': Icons.shopping_bag_rounded,
        'brush_rounded': Icons.brush_rounded,
        'spa_rounded': Icons.spa_rounded,
        'book_rounded': Icons.book_rounded,
        'face_rounded': Icons.face_rounded,
        'fitness_center_rounded': Icons.fitness_center_rounded,
        'local_florist_rounded': Icons.local_florist_rounded,
        'local_cafe_rounded': Icons.local_cafe_rounded,
        'eco_rounded': Icons.eco_rounded,
        'recycling_rounded': Icons.recycling_rounded,
        'park_rounded': Icons.park_rounded,
        'forest_rounded': Icons.forest_rounded,
        'local_drink_rounded': Icons.local_drink_rounded,
        'directions_bus_rounded': Icons.directions_bus_rounded,
        'directions_walk_rounded': Icons.directions_walk_rounded,
        'restaurant_rounded': Icons.restaurant_rounded,
        'lightbulb_rounded': Icons.lightbulb_rounded,
        'store_rounded': Icons.store_rounded,
      };
      
      return iconMap[iconValue] ?? Icons.shopping_bag_rounded;
    }
    
    return Icons.shopping_bag_rounded; // Default icon
  }

  // Helper method to safely parse price values
  double _parsePrice(dynamic priceValue) {
    if (priceValue == null) return 0.0;
    if (priceValue is double) return priceValue;
    if (priceValue is int) return priceValue.toDouble();
    if (priceValue is String) {
      return double.tryParse(priceValue) ?? 0.0;
    }
    return 0.0;
  }

  // Get products viewed today
  List<ProductView> get productsViewedToday {
    final today = DateTime.now();
    return _viewedProducts.where((view) => 
      view.viewedAt.year == today.year &&
      view.viewedAt.month == today.month &&
      view.viewedAt.day == today.day
    ).toList();
  }

  int get productsViewedTodayCount => productsViewedToday.length;
}
