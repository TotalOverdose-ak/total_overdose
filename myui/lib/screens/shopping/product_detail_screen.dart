import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/cart_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_view_provider.dart';
import '../../providers/spring_auth_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({
    super.key,
    required this.product,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _fadeController.forward();
    _slideController.forward();
    
    // Track product view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productViewProvider = Provider.of<ProductViewProvider>(context, listen: false);
      productViewProvider.addProductView(widget.product);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  // Add item to cart
  void _addToCart() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final userId = authProvider.userId ?? authProvider.userEmail ?? 'demo_user';
    
    print('🛒 Product Detail: Adding ${_quantity}x ${widget.product['name']} to cart for userId: $userId');
    
    try {
      final success = await cartProvider.addItem(
        userId: userId,
        productId: widget.product['id'],
        productName: widget.product['name'],
        price: _parseDouble(widget.product['price']),
        category: widget.product['category'],
        carbonFootprint: _parseDouble(widget.product['carbonFootprint']),
        quantity: _quantity,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${widget.product['name']} added to cart!',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: const Color(0xFFB5C7F7),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to add to cart. Please try again.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } catch (e) {
      print('❌ Error adding to cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error adding to cart. Please try again.',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            backgroundColor: Colors.red[400],
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16.0,
                      horizontal: 24.0,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFB5C7F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.arrow_back_rounded,
                              color: Color(0xFF22223B),
                              size: 20,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Consumer2<WishlistProvider, SpringAuthProvider>(
                          builder: (context, wishlistProvider, authProvider, child) {
                            final isInWishlist = wishlistProvider.isInWishlist(widget.product['id']);
                            final currentUserId = authProvider.isAuthenticated ? authProvider.userId : null;
                            
                            return IconButton(
                              onPressed: () async {
                                if (currentUserId == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please login to manage wishlist',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                      ),
                                      backgroundColor: Colors.orange[300],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                
                                if (isInWishlist) {
                                  final success = await wishlistProvider.removeFromWishlist(
                                    userId: currentUserId,
                                    productId: widget.product['id'],
                                  );
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Removed from wishlist!',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: Colors.red[300],
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                } else {
                                  final success = await wishlistProvider.addToWishlist(
                                    userId: currentUserId,
                                    productId: widget.product['id'],
                                    productName: widget.product['name'],
                                    price: _parseDouble(widget.product['price']),
                                    category: widget.product['category'],
                                  );
                                  if (success) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added to wishlist!',
                                          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                        ),
                                        backgroundColor: const Color(0xFFF9E79F),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF9E79F),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  isInWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                  color: isInWishlist ? Colors.red : const Color(0xFF22223B),
                                  size: 20,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Product Image
                SliverToBoxAdapter(
                  child: Container(
                    height: 200,
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: _parseColor(widget.product['color']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: _parseColor(widget.product['color']).withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getIconFromString(widget.product['icon']),
                      size: 120,
                      color: _parseColor(widget.product['color']),
                    ),
                  ),
                ),

                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),

                // Product Details
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                widget.product['name'],
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ),
                                                         Text(
                               '₹${_parseDouble(widget.product['price']).toStringAsFixed(2)}',
                               style: GoogleFonts.poppins(
                                 fontSize: 24,
                                 fontWeight: FontWeight.bold,
                                 color: const Color(0xFFB5C7F7),
                               ),
                             ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Category and Stock
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFB5C7F7).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.product['category'],
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFB5C7F7),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${_parseInt(widget.product['quantity'])} in stock',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[600],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Environmental Impact Section
                        Text(
                          'Environmental Impact',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 12),
                        
                        // Carbon Footprint
                        _buildEnvironmentalImpactCard(
                          'Carbon Footprint',
                          '${_parseDouble(widget.product['carbonFootprint']).toStringAsFixed(1)} kg CO₂',
                          Icons.eco_rounded,
                          Colors.green,
                        ),
                        
                        // Water Saved
                        _buildEnvironmentalImpactCard(
                          'Water Saved',
                          '${_parseDouble(widget.product['waterSaved']).toStringAsFixed(0)} L',
                          Icons.water_drop_rounded,
                          Colors.blue,
                        ),
                        
                        // Energy Saved
                        _buildEnvironmentalImpactCard(
                          'Energy Saved',
                          '${_parseDouble(widget.product['energySaved']).toStringAsFixed(1)} kWh',
                          Icons.electric_bolt_rounded,
                          Colors.orange,
                        ),
                        
                        // Waste Reduced
                        _buildEnvironmentalImpactCard(
                          'Waste Reduced',
                          '${_parseDouble(widget.product['wasteReduced']).toStringAsFixed(1)} kg',
                          Icons.delete_sweep_rounded,
                          Colors.purple,
                        ),
                        
                        // Trees Equivalent
                        _buildEnvironmentalImpactCard(
                          'Trees Equivalent',
                          '${_parseDouble(widget.product['treesEquivalent']).toStringAsFixed(0)} trees',
                          Icons.forest_rounded,
                          Colors.teal,
                        ),

                        const SizedBox(height: 16),

                        // Description
                        Text(
                          'Description',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product['description'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Material
                        Text(
                          'Material',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.product['material'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quantity Selector
                        Row(
                          children: [
                            Text(
                              'Quantity:',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF22223B),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F6F2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    onPressed: () {
                                      if (_quantity > 1) {
                                        setState(() {
                                          _quantity--;
                                        });
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.remove_rounded,
                                      color: Color(0xFF22223B),
                                    ),
                                  ),
                                  Container(
                                    width: 40,
                                    alignment: Alignment.center,
                                    child: Text(
                                      _quantity.toString(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF22223B),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {
                                      // Debug: Print the product quantity
                                      print('Product quantity: ${widget.product['quantity']}');
                                      print('Parsed quantity: ${_parseInt(widget.product['quantity'])}');
                                      print('Current _quantity: $_quantity');
                                      
                                      // Check if we can increment (with a reasonable limit)
                                      final maxQuantity = _parseInt(widget.product['quantity']);
                                      final limit = maxQuantity > 0 ? maxQuantity : 99; // Default to 99 if no stock limit
                                      
                                      if (_quantity < limit) {
                                        setState(() {
                                          _quantity++;
                                        });
                                      } else {
                                        // Show a message if trying to exceed stock
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Maximum quantity reached',
                                              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                            ),
                                            backgroundColor: Colors.orange[300],
                                            behavior: SnackBarBehavior.floating,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.add_rounded,
                                      color: Color(0xFF22223B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _addToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB5C7F7),
                              foregroundColor: const Color(0xFF22223B),
                              elevation: 0,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.shopping_cart_rounded,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Add to Cart - ₹${(_quantity * _parseDouble(widget.product['price'])).toStringAsFixed(2)}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF22223B),
                  ),
                ),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to parse color string to Color object
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return const Color(0xFFB5C7F7);
    }
    
    try {
      String hex = colorString.startsWith('#') ? colorString.substring(1) : colorString;
      
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      } else {
        return const Color(0xFFB5C7F7);
      }
    } catch (e) {
      return const Color(0xFFB5C7F7);
    }
  }

  // Helper method to get icon from string
  IconData _getIconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.shopping_bag_rounded;
    }
    
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
    
    return iconMap[iconString] ?? Icons.shopping_bag_rounded;
  }

  // Helper method to safely parse numeric values
  double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  // Helper method to safely parse integer values
  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      return int.tryParse(value) ?? 0;
    }
    return 0;
  }
}
