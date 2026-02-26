import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/spring_auth_provider.dart';
import '../shopping/product_detail_screen.dart';

class WishlistScreen extends StatefulWidget {
  const WishlistScreen({super.key});

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  @override
  void initState() {
    super.initState();
    _loadWishlist();
  }

  Future<void> _loadWishlist() async {
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
    
    if (authProvider.isAuthenticated && authProvider.userId != null) {
      await wishlistProvider.initializeWishlist(authProvider.userId!);
    }
  }

  Color _parseColor(dynamic colorValue) {
    if (colorValue == null) {
      return const Color(0xFFB5C7F7);
    }
    
    if (colorValue is Color) {
      return colorValue;
    }
    
    if (colorValue is String) {
      if (colorValue.isEmpty) {
        return const Color(0xFFB5C7F7);
      }
      
      try {
        String hex = colorValue.startsWith('#') ? colorValue.substring(1) : colorValue;
        
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
    
    return const Color(0xFFB5C7F7);
  }

  IconData _getIconFromString(dynamic iconValue) {
    if (iconValue == null) {
      return Icons.shopping_bag_rounded;
    }
    
    if (iconValue is IconData) {
      return iconValue;
    }
    
    if (iconValue is String) {
      if (iconValue.isEmpty) {
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
      
      return iconMap[iconValue] ?? Icons.shopping_bag_rounded;
    }
    
    return Icons.shopping_bag_rounded;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Wishlist',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Consumer<WishlistProvider>(
            builder: (context, wishlistProvider, child) {
              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert_rounded, color: Color(0xFF22223B)),
                onSelected: (value) async {
                  if (value == 'clear') {
                    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
                    if (authProvider.isAuthenticated && authProvider.userId != null) {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Clear Wishlist', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                          content: Text('Are you sure you want to clear your entire wishlist?', style: GoogleFonts.poppins()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('Cancel', style: GoogleFonts.poppins()),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('Clear', style: GoogleFonts.poppins(color: Colors.red)),
                            ),
                          ],
                        ),
                      );
                      
                      if (confirmed == true) {
                        await wishlistProvider.clearWishlist(authProvider.userId!);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Wishlist cleared', style: GoogleFonts.poppins())),
                          );
                        }
                      }
                    }
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'clear',
                    child: Row(
                      children: [
                        const Icon(Icons.clear_all_rounded, color: Colors.red),
                        const SizedBox(width: 8),
                        Text('Clear Wishlist', style: GoogleFonts.poppins()),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer2<WishlistProvider, SpringAuthProvider>(
        builder: (context, wishlistProvider, authProvider, child) {
          if (!authProvider.isAuthenticated || authProvider.userId == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Please login to view your wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          if (wishlistProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (wishlistProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 64,
                    color: Colors.red[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading wishlist',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    wishlistProvider.error!,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadWishlist,
                    child: Text('Retry', style: GoogleFonts.poppins()),
                  ),
                ],
              ),
            );
          }

          final wishlistItems = wishlistProvider.wishlistItems;
          
          if (wishlistItems.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add items to your wishlist while shopping',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB5C7F7),
                      foregroundColor: const Color(0xFF22223B),
                    ),
                    child: Text(
                      'Start Shopping',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Wishlist Items
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: wishlistItems.length,
                  itemBuilder: (context, index) {
                    final item = wishlistItems[index];
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _parseColor(item['productColor']).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconFromString(item['productIcon']),
                            color: _parseColor(item['productColor']),
                            size: 30,
                          ),
                        ),
                        title: Text(
                          item['productName'] ?? 'Unknown Product',
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              item['productDescription'] ?? 'Eco-friendly product',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                                                 Text(
                                   '₹${_parseDouble(item['productPrice']).toStringAsFixed(0)}',
                                   style: GoogleFonts.poppins(
                                     fontWeight: FontWeight.bold,
                                     fontSize: 16,
                                     color: _parseColor(item['productColor']),
                                   ),
                                 ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Eco',
                                    style: GoogleFonts.poppins(
                                      fontSize: 10,
                                      color: Colors.green[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert_rounded),
                          onSelected: (value) async {
                            if (value == 'view') {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ProductDetailScreen(product: {
                                    'id': item['productId'] ?? 'unknown',
                                    'name': item['productName'] ?? 'Unknown Product',
                                    'description': item['productDescription'] ?? 'Eco-friendly product',
                                    'price': item['productPrice'] ?? 0.0,
                                    'color': item['productColor'] ?? '#B5C7F7',
                                    'icon': item['productIcon'] ?? 'shopping_bag_rounded',
                                    'category': item['productCategory'] ?? 'General',
                                    'carbonFootprint': item['carbonFootprint'] ?? 0.0,
                                    'waterSaved': item['waterSaved'] ?? 0.0,
                                    'energySaved': item['energySaved'] ?? 0.0,
                                    'wasteReduced': item['wasteReduced'] ?? 0.0,
                                    'treesEquivalent': item['treesEquivalent'] ?? 0.0,
                                    'material': item['material'] ?? 'Eco-friendly material',
                                    'quantity': item['quantity'] ?? 1,
                                  }),
                                ),
                              );

                            } else if (value == 'remove') {
                              await wishlistProvider.removeFromWishlist(
                                userId: authProvider.userId!,
                                productId: item['productId'],
                              );
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Removed from wishlist', style: GoogleFonts.poppins())),
                                );
                              }
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  const Icon(Icons.visibility_rounded),
                                  const SizedBox(width: 8),
                                  Text('View Details', style: GoogleFonts.poppins()),
                                ],
                              ),
                            ),

                            PopupMenuItem(
                              value: 'remove',
                              child: Row(
                                children: [
                                  const Icon(Icons.delete_rounded, color: Colors.red),
                                  const SizedBox(width: 8),
                                  Text('Remove', style: GoogleFonts.poppins(color: Colors.red)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
