import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math';
import '../../providers/spring_auth_provider.dart';

import '../../providers/carbon_tracking_provider.dart';
import '../../providers/wishlist_provider.dart';
import '../../providers/product_view_provider.dart';
import '../../providers/eco_challenges_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/orders_provider.dart';
import '../../providers/cart_provider.dart';
import '../shopping/shopping_cart_screen.dart';
import '../shopping/product_catalog_screen.dart';
import '../admin/admin_dashboard_screen.dart';
import '../shopkeeper/shopkeeper_dashboard_screen.dart';
import '../shopping/product_detail_screen.dart';
import '../shopping/wishlist_screen.dart';
import '../user_eco_challenges_screen.dart';
import '../user_eco_discounts_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // Helper method to parse color string to Color object
  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return const Color(0xFFB5C7F7); // Default color
    }
    
    try {
      // Remove # if present
      String hex = colorString.startsWith('#') ? colorString.substring(1) : colorString;
      
      // Handle different hex formats
      if (hex.length == 6) {
        return Color(int.parse('FF$hex', radix: 16));
      } else if (hex.length == 8) {
        return Color(int.parse(hex, radix: 16));
      } else {
        return const Color(0xFFB5C7F7); // Default color
      }
    } catch (e) {
      print('Error parsing color: $colorString - $e');
      return const Color(0xFFB5C7F7); // Default color
    }
  }

  // Helper method to get icon from string
  IconData _getIconFromString(String? iconString) {
    if (iconString == null || iconString.isEmpty) {
      return Icons.shopping_bag_rounded; // Default icon
    }
    
    // Map of string to IconData
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

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  
  // Real-time data variables
  Timer? _realTimeTimer;
  double _carbonSaved = 2.4;
  int _productsViewed = 12;
  int _onlineUsers = 1247;
  double _todaysSavings = 156.80;
  int _nearbyStores = 8;
  final String _currentWeather = "Sunny 28°C";
  final List<String> _liveActivities = [
    "Sarah just bought organic cotton shirts",
    "GreenMart added 12 new eco products",
    "Mumbai saved 45kg CO₂ today",
    "New sustainable store opened nearby",
  ];
  int _activityIndex = 0;
  
  // New interactive features
  final bool _isNotificationsEnabled = true;
  final bool _isDarkMode = false;
  final int _ecoPoints = 1250;
  final int _streakDays = 7;
  

  
  // Eco challenges will be managed by EcoChallengesProvider
  
  // Live notifications
  final List<Map<String, dynamic>> _notifications = [
    {
      'title': '🎉 Flash Sale!',
      'message': '30% off on eco-friendly products',
      'color': const Color(0xFFF9E79F),
      'time': 'Now',
    },
    {
      'title': '🌱 Daily Goal',
      'message': 'You\'re 80% closer to your carbon goal!',
      'color': const Color(0xFFB5C7F7),
      'time': '5 min ago',
    },
  ];

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

    _fadeController.forward();
    _slideController.forward();
    // Remove continuous pulsing to improve performance
    // _pulseController.repeat(reverse: true);

    // Start real-time updates
    _startRealTimeUpdates();
  }

  void _startRealTimeUpdates() {
    _realTimeTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Update real-time data with realistic increments
          _carbonSaved += (Random().nextDouble() * 0.05);
          _productsViewed += Random().nextInt(2);
          _onlineUsers += Random().nextInt(10) - 5;
          _todaysSavings += (Random().nextDouble() * 2);
          _nearbyStores = 8 + Random().nextInt(3);
          
          // Cycle through activities
          _activityIndex = (_activityIndex + 1) % _liveActivities.length;
          
          // Occasionally add new notifications (reduced frequency)
          if (Random().nextDouble() < 0.2) {
            _addRandomNotification();
          }
        });
      }
    });
  }

  void _addRandomNotification() {
    List<Map<String, dynamic>> newNotifications = [
      {
        'title': '💚 Eco Achievement',
        'message': 'You saved 500g CO₂ this week!',
        'color': const Color(0xFFE8D5C4),
        'time': 'Just now',
      },
      {
        'title': '🚚 Order Update',
        'message': 'Your bamboo products are out for delivery',
        'color': const Color(0xFFD6EAF8),
        'time': 'Just now',
      },
      {
        'title': '🏪 New Store',
        'message': 'EcoMart opened 2km from your location',
        'color': const Color(0xFFF9E79F),
        'time': 'Just now',
      },
    ];
    
    if (_notifications.length < 5) {
      _notifications.insert(0, newNotifications[Random().nextInt(newNotifications.length)]);
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _realTimeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          color: const Color(0xFFB5C7F7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Enhanced Header with Live Status
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 32.0,
                      horizontal: 24.0,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB5C7F7),
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFFB5C7F7).withOpacity(0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.eco_rounded,
                                  size: 30,
                                  color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Consumer<SpringAuthProvider>(
                                    builder: (context, authProvider, child) {
                                      return Text(
                                        'Hello, ${authProvider.userName ?? 'User'}!\nWelcome to EcoBazaarX.',
                                        style: GoogleFonts.poppins(
                                          fontSize: 26,
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF22223B),
                                          height: 1.2,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                            // Live Notification Bell
                            Consumer<SettingsProvider>(
                              builder: (context, settingsProvider, child) {
                                if (!settingsProvider.pushNotificationsEnabled) {
                                  return const SizedBox.shrink(); // Hide notification bell if disabled
                                }
                                
                                return Stack(
                                  children: [
                                    IconButton(
                                      onPressed: () => _showNotifications(),
                                      icon: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF9E79F),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.notifications_rounded,
                                          color: Color(0xFF22223B),
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    if (_notifications.isNotEmpty)
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                  ],
                                );
                              },
                            ),
                            const SizedBox(width: 8),
                            // Settings Button
                            IconButton(
                              onPressed: () => Navigator.pushNamed(context, '/settings'),
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8D5C4),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.settings_rounded,
                                  color: Color(0xFF22223B),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: () async {
                                final authProvider = Provider.of<SpringAuthProvider>(
                                  context,
                                  listen: false,
                                );
                                await authProvider.logout();
                                if (mounted) {
                                  Navigator.pushReplacementNamed(context, '/login');
                                }
                              },
                              icon: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB5C7F7),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  color: Color(0xFF22223B),
                                  size: 20,
                                ),
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),
                  ),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search eco-friendly products...',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: const Color(0xFFB5C7F7),
                          ),
                          suffixIcon: IconButton(
                            onPressed: () {
                              _showSearchFilters();
                            },
                            icon: Icon(
                              Icons.filter_list_rounded,
                              color: const Color(0xFFB5C7F7),
                            ),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                        onTap: () {
                          _navigateToShopping();
                        },
                        readOnly: true,
                      ),
                    ),
                  ),



                  // Live Community Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Row(
                      children: [
                        Text(
                          'Live Community',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '$_onlineUsers online',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Real-time Impact Tracker
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.08),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Mumbai\'s Impact Today',
                                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                              ),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Carbon Saved: ${(_carbonSaved * 50).toStringAsFixed(1)} kg',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFFB5C7F7),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Community Goal: ${((_carbonSaved * 50) / 1000 * 100).toStringAsFixed(1)}% complete',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          LinearProgressIndicator(
                            value: (_carbonSaved * 50) / 1000,
                            backgroundColor: const Color(0xFFF7F6F2),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFFB5C7F7),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Enhanced Shopping Call-to-Action
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      width: double.infinity,
                      height: 120,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF4CAF50),
                            const Color(0xFF2E7D32),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => _navigateToShopping(),
                          borderRadius: BorderRadius.circular(24),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '🛍️ Start Shopping',
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Discover eco-friendly products',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.white.withOpacity(0.95),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.arrow_forward_rounded,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Enhanced Quick Actions with Real-time Features
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Consumer<CarbonTrackingProvider>(
                            builder: (context, carbonProvider, child) {
                              return _PastelActionCard(
                                icon: Icons.eco_rounded,
                                label: 'Carbon Saved',
                                color: const Color(0xFFF9E79F),
                                onTap: () => _showCarbonSavedDetails(carbonProvider),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.track_changes_rounded,
                            label: 'Track Impact',
                            color: const Color(0xFFD6EAF8),
                            onTap: () => _showImpactTracker(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.eco_rounded,
                            label: 'Daily Tips',
                            color: const Color(0xFFB5C7F7),
                            onTap: () => _showEcoTips(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Second row of action cards
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.people_rounded,
                            label: 'Community',
                            color: const Color(0xFFE8D5C4),
                            onTap: () => _showCommunityUpdates(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Role-based View Orders button - only show for shopkeepers
                        Consumer<SpringAuthProvider>(
                          builder: (context, authProvider, child) {
                            if (authProvider.userRole == UserRole.shopkeeper) {
                              return Expanded(
                                child: _PastelActionCard(
                                  icon: Icons.shopping_bag_rounded,
                                  label: 'View Orders',
                                  color: const Color(0xFFF9E79F),
                                  onTap: () => _showShopkeeperOrders(),
                                ),
                              );
                            } else {
                              // For customers, show a different action
                              return Expanded(
                                child: _PastelActionCard(
                                  icon: Icons.favorite_rounded,
                                  label: 'Wishlist',
                                  color: const Color(0xFFF9E79F),
                                  onTap: () => _navigateToWishlist(),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.visibility_rounded,
                            label: 'Product Views',
                            color: const Color(0xFFB5C7F7),
                            onTap: () => _showProductViews(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Third row - Eco Challenges
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.emoji_events,
                            label: 'Eco Challenges',
                            color: const Color(0xFFD6EAF8),
                            onTap: () => _navigateToEcoChallenges(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.local_offer,
                            label: 'Eco Discounts',
                            color: const Color(0xFFFFB6C1),
                            onTap: () => _navigateToEcoDiscounts(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _PastelActionCard(
                            icon: Icons.leaderboard,
                            label: 'Leaderboard',
                            color: const Color(0xFFF9E79F),
                            onTap: () => _showLeaderboard(),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Trending Products Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      'Trending Now',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 240, // Increased height to prevent overflow
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 5,
                      itemBuilder: (context, index) {
                        return _buildTrendingProductCard(index);
                      },
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Wishlist Section
                  Consumer2<WishlistProvider, SpringAuthProvider>(
                    builder: (context, wishlistProvider, authProvider, child) {
                      if (!authProvider.isAuthenticated || authProvider.userId == null) {
                        return const SizedBox.shrink(); // Don't show wishlist if not logged in
                      }

                      final wishlistItems = wishlistProvider.wishlistItems.take(3).toList(); // Show only first 3 items
                      
                      if (wishlistItems.isEmpty) {
                        return const SizedBox.shrink(); // Don't show section if no items
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Row(
                              children: [
                                Text(
                                  'My Wishlist',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF22223B),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => _showWishlist(),
                                  child: Text(
                                    'View All',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFB5C7F7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: wishlistItems.length,
                              itemBuilder: (context, index) {
                                return _buildWishlistCard(wishlistItems[index]);
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  ),

                  // Recently Viewed Section
                  Consumer<ProductViewProvider>(
                    builder: (context, productViewProvider, child) {
                      final recentlyViewed = productViewProvider.getRecentlyViewed(3);
                      
                      if (recentlyViewed.isEmpty) {
                        return const SizedBox.shrink(); // Don't show section if no items
                      }

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18.0),
                            child: Row(
                              children: [
                                Text(
                                  'Recently Viewed',
                                  style: GoogleFonts.poppins(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF22223B),
                                  ),
                                ),
                                const Spacer(),
                                TextButton(
                                  onPressed: () => _showRecentlyViewed(),
                                  child: Text(
                                    'View All',
                                    style: GoogleFonts.poppins(
                                      color: const Color(0xFFB5C7F7),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          SizedBox(
                            height: 200,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: recentlyViewed.length,
                              itemBuilder: (context, index) {
                                return _buildRecentlyViewedCard(recentlyViewed[index]);
                              },
                            ),
                          ),
                          const SizedBox(height: 28),
                        ],
                      );
                    },
                  ),

                  // Eco Points & Streak Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFB5C7F7),
                                  const Color(0xFFB5C7F7).withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFB5C7F7).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.stars_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Eco Points',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Consumer<EcoChallengesProvider>(
                                  builder: (context, challengesProvider, child) {
                                    return Text(
                                      '${challengesProvider.totalEcoPoints}',
                                      style: GoogleFonts.poppins(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    );
                                  },
                                ),
                                Text(
                                  'Level ${(_ecoPoints / 100).floor()}',
                                  style: GoogleFonts.poppins(
                                    color: Colors.white.withOpacity(0.8),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  const Color(0xFFF9E79F),
                                  const Color(0xFFF9E79F).withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFFF9E79F).withOpacity(0.3),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.local_fire_department_rounded,
                                      color: const Color(0xFF22223B),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Streak',
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF22223B),
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  '$_streakDays days',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF22223B),
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'Keep it up! 🔥',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF22223B).withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Settings & Preferences Section removed

                  const SizedBox(height: 28),

                  // Role-based Dashboard Button
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: Consumer<SpringAuthProvider>(
                      builder: (context, authProvider, child) {
                        if (authProvider.userRole == null) {
                          return const SizedBox.shrink();
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: () {
                                _handleRoleSpecificAction(
                                  authProvider.userRole!,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _getRoleSpecificColor(
                                  authProvider.userRole!,
                                ),
                                foregroundColor: const Color(0xFF22223B),
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getRoleSpecificIcon(authProvider.userRole!),
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    _getRoleSpecificButtonText(
                                      authProvider.userRole!,
                                    ),
                                    style: GoogleFonts.poppins(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
      // Enhanced Floating Action Button for Shopping
      floatingActionButton: Stack(
        children: [
          FloatingActionButton.extended(
            onPressed: () => _navigateToShopping(),
            backgroundColor: const Color(0xFFB5C7F7),
            icon: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
            ),
            label: Text(
              'Shop Now',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            elevation: 8,
          ),
          if (_productsViewed > 5)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${Random().nextInt(9) + 1}',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Real-time refresh function
  Future<void> _refreshData() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _carbonSaved += Random().nextDouble() * 0.5;
      _productsViewed += Random().nextInt(5);
      _todaysSavings += Random().nextDouble() * 20;
      _onlineUsers += Random().nextInt(100) - 50;
    });
  }

  // Enhanced navigation methods
  void _navigateToShopping() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildShoppingOptionsModal(),
    );
  }

  void _navigateToWishlist() {
    Navigator.pushNamed(context, '/wishlist');
  }

  Widget _buildShoppingOptionsModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F2),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          
          // Header
    
          
          const SizedBox(height: 20),
          
          // Shopping Categories
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Shopping Actions
                  Text(
                    'Quick Actions',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickShoppingCard(
                          'Browse All\nProducts',
                          Icons.grid_view_rounded,
                          const Color(0xFFB5C7F7),
                          () => _navigateToAllProducts(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildQuickShoppingCard(
                          'View Cart\n& Checkout',
                          Icons.shopping_cart_rounded,
                          const Color(0xFFF9E79F),
                          () => _navigateToCart(),
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Categories Section
                  Text(
                    'Shop by Category',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Category Grid
                  SizedBox(
                    height: 70,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _buildCategoryCard(
                          'Organic Food',
                          Icons.restaurant_rounded,
                          const Color(0xFFE8D5C4),
                          '250+ items',
                        ),
                        _buildCategoryCard(
                          'Eco Clothing',
                          Icons.checkroom_rounded,
                          const Color(0xFFD6EAF8),
                          '180+ items',
                        ),
                        _buildCategoryCard(
                          'Home & Garden',
                          Icons.home_rounded,
                          const Color(0xFFF9E79F),
                          '320+ items',
                        ),
                        _buildCategoryCard(
                          'Personal Care',
                          Icons.spa_rounded,
                          const Color(0xFFB5C7F7),
                          '150+ items',
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Special Offers
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D5C4).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: const Color(0xFFE8D5C4).withOpacity(0.3),
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D5C4).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.local_offer_rounded,
                            color: Color(0xFFE8D5C4),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Special Eco Deals',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Get up to 40% off on eco-friendly products today!',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: const Color(0xFF22223B).withOpacity(0.7),
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8D5C4),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.pop(context);
                                _navigateToOffers();
                              },
                              borderRadius: BorderRadius.circular(20),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Text(
                                  'View Offers',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF22223B),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickShoppingCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: const Color(0xFF22223B),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon, Color color, String itemCount) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _navigateToCategory(title);
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: color,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: const Color(0xFF22223B),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    itemCount,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      color: color.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



  // Enhanced shopping navigation methods
  void _navigateToAllProducts() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ProductCatalogScreen(),
      ),
    );
  }

  void _navigateToOffers() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShoppingCartScreen(),
      ),
    );
  }

  void _navigateToCategory(String category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          category,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.construction_rounded,
              size: 48,
              color: const Color(0xFFB5C7F7),
            ),
            const SizedBox(height: 16),
            Text(
              'This category is coming soon! We\'re adding more eco-friendly products.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _navigateToCart();
            },
            child: Text(
              'Browse Cart Instead',
              style: GoogleFonts.poppins(
                color: const Color(0xFFB5C7F7),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ShoppingCartScreen(),
      ),
    );
  }

  void _navigateToEcoChallenges() {
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final userId = authProvider.userId ?? 'guest';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserEcoChallengesScreen(userId: userId),
      ),
    );
  }

  void _navigateToEcoDiscounts() {
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    final userId = authProvider.userId ?? 'guest';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserEcoDiscountsScreen(userId: userId),
      ),
    );
  }

  void _showMyRewards() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE8D5C4),
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'My Eco Rewards',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFA500)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.eco, color: Colors.white, size: 40),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total Eco Points',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                              Text(
                                '1,250 Points',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView(
                        children: [
                          _buildRewardItem('5% Off Next Purchase', '100 Points', Icons.discount, Colors.green),
                          _buildRewardItem('10% Off Electronics', '200 Points', Icons.devices, Colors.blue),
                          _buildRewardItem('Free Shipping', '150 Points', Icons.local_shipping, Colors.orange),
                          _buildRewardItem('15% Off Eco Products', '300 Points', Icons.eco, Colors.green[700]!),
                          _buildRewardItem('Special Member Badge', '500 Points', Icons.badge, Colors.purple),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRewardItem(String title, String points, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Redeem for $points',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('$title redeemed!')),
              );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Redeem',
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showLeaderboard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            // Simple Header like Add Product Admin
            Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                children: [
                  // Handle
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Eco Leaderboard',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF22223B),
                          size: 24,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Statistics Cards Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildLeaderboardStatCard(
                            'Your Rank',
                            '#1',
                            Icons.workspace_premium,
                            const Color(0xFFFFB6C1),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLeaderboardStatCard(
                            'Total Points',
                            '3,250',
                            Icons.stars_rounded,
                            const Color(0xFFF9E79F),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildLeaderboardStatCard(
                            'This Week',
                            '+380',
                            Icons.trending_up_rounded,
                            const Color(0xFF8BC34A),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Top 3 Section with Professional Cards
                    Text(
                      'Top Performers',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Top 3 Cards
                    _buildTopPerformerCard(
                      1, 'You', '3,250', '🏆',
                      const Color(0xFFFFB6C1),
                      isUser: true,
                    ),
                    const SizedBox(height: 12),
                    _buildTopPerformerCard(
                      2, 'Sarah K.', '2,890', '🥈',
                      const Color(0xFFD6EAF8),
                    ),
                    const SizedBox(height: 12),
                    _buildTopPerformerCard(
                      3, 'Mike R.', '2,670', '🥉',
                      const Color(0xFFF9E79F),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Other Rankings Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Other Rankings',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC34A).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Live Rankings',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF8BC34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Regular Rankings List
                    ...List.generate(5, (index) {
                      final rankings = [
                        {'name': 'Emma L.', 'points': '2,450', 'change': '+12'},
                        {'name': 'John D.', 'points': '2,320', 'change': '-5'},
                        {'name': 'Lisa M.', 'points': '2,180', 'change': '+28'},
                        {'name': 'Tom W.', 'points': '2,050', 'change': '+15'},
                        {'name': 'Anna P.', 'points': '1,920', 'change': '-8'},
                      ];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildRankingCard(
                          index + 4,
                          rankings[index]['name']!,
                          rankings[index]['points']!,
                          rankings[index]['change']!,
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPodiumPosition(int position, String name, String points, Color color) {
    double height = position == 1 ? 80 : position == 2 ? 60 : 50;
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              position.toString(),
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                points,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(int position, String name, String points, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                'points',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // New Modern Leaderboard Widgets
  Widget _buildLeaderboardStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPerformerCard(int position, String name, String points, String emoji, Color color, {bool isUser = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: isUser ? Border.all(color: color, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position Badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    if (isUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'YOU',
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Rank #$position',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          
          // Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  points,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'points',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankingCard(int position, String name, String points, String change) {
    bool isPositive = change.startsWith('+');
    Color changeColor = isPositive ? const Color(0xFF8BC34A) : Colors.red;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Position
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                position.toString(),
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Name
          Expanded(
            child: Text(
              name,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF22223B),
              ),
            ),
          ),
          
          // Points and Change
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                points,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: changeColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      size: 12,
                      color: changeColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      change,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: changeColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Add item to cart
  void _addToCart(Map<String, dynamic> item, CartProvider cartProvider, SpringAuthProvider authProvider) async {
    // Simple add to cart - you'll handle the backend integration
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${item['productName'] ?? 'Item'} added to cart!',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Show notifications bottom sheet
  void _showNotifications() {
    // Check if notifications are enabled in settings
    final settingsProvider = Provider.of<SettingsProvider>(context, listen: false);
    
    if (!settingsProvider.pushNotificationsEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Notifications are disabled. Enable them in Settings.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
          action: SnackBarAction(
            label: 'Settings',
            textColor: Colors.white,
            onPressed: () => Navigator.pushNamed(context, '/settings'),
          ),
        ),
      );
      return;
    }
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Live Notifications',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _notifications.clear();
                      });
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.clear_all),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _notifications.length,
                itemBuilder: (context, index) {
                  final notification = _notifications[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: notification['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.notifications_rounded,
                            color: notification['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                notification['title'],
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                              Text(
                                notification['message'],
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          notification['time'],
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show carbon saved details
  void _showCarbonSavedDetails(CarbonTrackingProvider carbonProvider) {
    final stats = carbonProvider.environmentalImpactStats;
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Your Carbon Impact',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Total Carbon Saved Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            size: 48,
                            color: Colors.green[600],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${carbonProvider.totalCarbonSaved.toStringAsFixed(1)} kg CO₂',
                            style: GoogleFonts.poppins(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[700],
                            ),
                          ),
                          Text(
                            'Total Carbon Saved',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Environmental Impact Stats
                    Text(
                      'Environmental Impact',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    _buildEnvironmentalImpactCard(
                      'Equivalent to planting',
                      '${stats['treesEquivalent'].toStringAsFixed(0)} trees',
                      Icons.forest_rounded,
                      Colors.green,
                    ),
                    
                    _buildEnvironmentalImpactCard(
                      'Car travel avoided',
                      '${stats['carKmEquivalent'].toStringAsFixed(1)} km',
                      Icons.directions_car_rounded,
                      Colors.blue,
                    ),
                    
                    _buildEnvironmentalImpactCard(
                      'Electricity saved',
                      '${stats['electricityEquivalent'].toStringAsFixed(1)} kWh',
                      Icons.electric_bolt_rounded,
                      Colors.orange,
                    ),
                    
                    _buildEnvironmentalImpactCard(
                      'Water saved',
                      '${(carbonProvider.totalCarbonSaved * 1000).toStringAsFixed(0)} L',
                      Icons.water_drop_rounded,
                      Colors.cyan,
                    ),
                    
                    _buildEnvironmentalImpactCard(
                      'Waste reduced',
                      '${(carbonProvider.totalCarbonSaved * 2).toStringAsFixed(1)} kg',
                      Icons.delete_sweep_rounded,
                      Colors.purple,
                    ),
                    
                    _buildEnvironmentalImpactCard(
                      'Air quality improved',
                      '${(carbonProvider.totalCarbonSaved * 50).toStringAsFixed(0)} m³',
                      Icons.air_rounded,
                      Colors.teal,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Detailed Environmental Breakdown
                    Text(
                      'Environmental Breakdown',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.analytics_rounded,
                                color: Colors.green[600],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Impact Analysis',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildImpactRow('CO₂ Emissions Reduced', '${carbonProvider.totalCarbonSaved.toStringAsFixed(1)} kg', Colors.green),
                          _buildImpactRow('Energy Consumption Saved', '${(carbonProvider.totalCarbonSaved * 2.5).toStringAsFixed(1)} kWh', Colors.orange),
                          _buildImpactRow('Water Usage Reduced', '${(carbonProvider.totalCarbonSaved * 1000).toStringAsFixed(0)} L', Colors.blue),
                          _buildImpactRow('Waste Diverted', '${(carbonProvider.totalCarbonSaved * 2).toStringAsFixed(1)} kg', Colors.purple),
                          _buildImpactRow('Air Pollution Avoided', '${(carbonProvider.totalCarbonSaved * 0.5).toStringAsFixed(1)} kg', Colors.red),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Monthly and Yearly Stats
                    Text(
                      'Time-based Impact',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: _buildTimeBasedCard(
                            'This Month',
                            '${carbonProvider.currentMonthCarbonSaved.toStringAsFixed(1)} kg',
                            Icons.calendar_month_rounded,
                            const Color(0xFFB5C7F7),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTimeBasedCard(
                            'This Year',
                            '${carbonProvider.currentYearCarbonSaved.toStringAsFixed(1)} kg',
                            Icons.calendar_today_rounded,
                            const Color(0xFFF9E79F),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Purchases
                    if (carbonProvider.recentPurchases.isNotEmpty) ...[
                      Text(
                        'Recent Eco Purchases',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      ...carbonProvider.recentPurchases.take(3).map((purchase) => 
                        _buildRecentPurchaseCard(purchase)
                      ),
                    ],
                    
                    const SizedBox(height: 24),
                    
                    // Load Sample Data Button (for testing)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          carbonProvider.loadSampleData();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sample carbon data loaded!', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('Load Sample Data', style: GoogleFonts.poppins()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB5C7F7),
                          side: BorderSide(color: const Color(0xFFB5C7F7)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactCard(String title, String value, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeBasedCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPurchaseCard(CarbonPurchase purchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart_rounded, color: Colors.green, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${purchase.orderId}',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${purchase.totalAmount.toStringAsFixed(0)} • ${purchase.totalCarbonSaved.toStringAsFixed(1)} kg CO₂ saved',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${purchase.timestamp.day}/${purchase.timestamp.month}/${purchase.timestamp.year}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactRow(String title, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(String title, String value, double progress, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
              const Spacer(),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard(CarbonPurchase purchase) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_cart_rounded, color: Colors.green, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Order #${purchase.orderId}',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${purchase.totalAmount.toStringAsFixed(0)} • ${purchase.totalCarbonSaved.toStringAsFixed(1)} kg CO₂',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${purchase.timestamp.day}/${purchase.timestamp.month}',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipCategory(String title, List<String> tips, IconData icon, Color color) {
    return Container(
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
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: tips.map((tip) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        tip,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Show product views
  void _showProductViews() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Recently Viewed Products',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // View Statistics
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFB5C7F7).withOpacity(0.8),
                            const Color(0xFFD6EAF8).withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFB5C7F7).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.visibility_rounded,
                            size: 48,
                            color: const Color(0xFF22223B),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'View Statistics',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '0 products viewed today',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // View Categories
                    Text(
                      'Most Viewed Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Container(
                      padding: const EdgeInsets.all(20),
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
                      child: Column(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No Category Data Yet',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Browse products to see category analytics',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _navigateToShopping();
                        },
                        icon: const Icon(Icons.shopping_cart_rounded),
                        label: Text('Continue Shopping', style: GoogleFonts.poppins()),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB5C7F7),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildCategoryViewCard(String category, int viewCount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            category,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            '$viewCount views',
            style: GoogleFonts.poppins(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'clothing':
        return Icons.checkroom_rounded;
      case 'accessories':
        return Icons.shopping_bag_rounded;
      case 'electronics':
        return Icons.devices_rounded;
      case 'personal care':
        return Icons.face_rounded;
      case 'food & beverages':
        return Icons.restaurant_rounded;
      case 'home & garden':
        return Icons.home_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'clothing':
        return const Color(0xFFB5C7F7);
      case 'accessories':
        return const Color(0xFFF9E79F);
      case 'electronics':
        return const Color(0xFFD6EAF8);
      case 'personal care':
        return const Color(0xFFE8D5C4);
      case 'food & beverages':
        return Colors.green;
      case 'home & garden':
        return Colors.orange;
      default:
        return const Color(0xFFB5C7F7);
    }
  }

  Widget _buildRealChallengeCard(EcoChallenge challenge) {
    return Container(
      width: 260,
      height: 160,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: challenge.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    challenge.icon,
                    color: challenge.color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        challenge.reward,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: challenge.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                // Delete Button
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey[600],
                    size: 18,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(challenge);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Challenge',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              challenge.description,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '${challenge.currentProgress}/${challenge.targetValue} ${challenge.targetUnit}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                    ],
                  ),
                ),
                if (challenge.isCompleted)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Completed!',
                      style: GoogleFonts.poppins(
                        fontSize: 9,
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            LinearProgressIndicator(
              value: challenge.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  void _showEcoChallenges() {
    // Force initialize challenges if empty
    final challengesProvider = Provider.of<EcoChallengesProvider>(context, listen: false);
    challengesProvider.forceInitialize();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Eco Challenges',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<EcoChallengesProvider>(
                builder: (context, challengesProvider, child) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        
                        // Overview Stats
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFB5C7F7).withOpacity(0.8),
                                const Color(0xFFD6EAF8).withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFB5C7F7).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.emoji_events_rounded,
                                size: 48,
                                color: const Color(0xFF22223B),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Challenge Overview',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  _buildChallengeStat('Active', '${challengesProvider.getActiveChallengesCount()}', Icons.play_circle_rounded),
                                  _buildChallengeStat('Completed', '${challengesProvider.getCompletedChallengesCount()}', Icons.check_circle_rounded),
                                  _buildChallengeStat('Points', '${challengesProvider.totalEcoPoints}', Icons.stars_rounded),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Active Challenges
                        Text(
                          'Active Challenges',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        ...challengesProvider.activeChallenges.map((challenge) => 
                          _buildDetailedChallengeCard(challenge, challengesProvider)
                        ),
                        
                        const SizedBox(height: 24),
                        
                        // Completed Challenges
                        if (challengesProvider.completedChallenges.isNotEmpty) ...[
                          Text(
                            'Completed Challenges',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          ...challengesProvider.completedChallenges.map((challenge) => 
                            _buildCompletedChallengeCard(challenge)
                          ),
                          
                          const SizedBox(height: 24),
                        ],
                        
                        // Action Buttons
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () {
                                  final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
                                  final userId = authProvider.isAuthenticated ? authProvider.userId! : 'demo_user';
                                  challengesProvider.loadSampleProgress(userId);
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Sample challenge progress loaded!', style: GoogleFonts.poppins()),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.refresh_rounded),
                                label: Text('Load Sample', style: GoogleFonts.poppins()),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFFB5C7F7),
                                  side: BorderSide(color: const Color(0xFFB5C7F7)),
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _showAddChallengeDialog(context, challengesProvider),
                                icon: const Icon(Icons.add_rounded),
                                label: Text('Add Challenge', style: GoogleFonts.poppins()),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFB5C7F7),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeStat(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedChallengeCard(EcoChallenge challenge, EcoChallengesProvider provider) {
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: challenge.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    challenge.icon,
                    color: challenge.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      Text(
                        challenge.category,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: challenge.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    challenge.reward,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: challenge.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete Button
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: Colors.grey[600],
                    size: 20,
                  ),
                  onSelected: (value) {
                    if (value == 'delete') {
                      _showDeleteConfirmation(challenge);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Delete Challenge',
                            style: GoogleFonts.poppins(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              challenge.description,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progress',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[500],
                        ),
                      ),
                      Text(
                        '${challenge.currentProgress}/${challenge.targetValue} ${challenge.targetUnit}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                    ],
                  ),
                ),
                                  TextButton(
                    onPressed: () {
                      final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
                      final userId = authProvider.isAuthenticated ? authProvider.userId! : 'demo_user';
                      provider.updateProgress(challenge.id, 1, userId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Progress updated!', style: GoogleFonts.poppins()),
                          backgroundColor: challenge.color,
                        ),
                      );
                    },
                  child: Text(
                    'Update Progress',
                    style: GoogleFonts.poppins(
                      color: challenge.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: challenge.progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(challenge.color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedChallengeCard(EcoChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.green,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    challenge.title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  Text(
                    'Completed! +${challenge.reward}',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Delete Button
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Colors.grey[600],
                size: 20,
              ),
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteConfirmation(challenge);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.red, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Delete Challenge',
                        style: GoogleFonts.poppins(
                          color: Colors.red,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(EcoChallenge challenge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Challenge',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${challenge.title}"? This action cannot be undone.',
          style: GoogleFonts.poppins(
            color: Colors.grey[700],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
                      ElevatedButton(
              onPressed: () {
                final provider = Provider.of<EcoChallengesProvider>(context, listen: false);
                final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
                final userId = authProvider.isAuthenticated ? authProvider.userId! : 'demo_user';
                provider.deleteChallenge(challenge.id, userId);
                Navigator.pop(context);
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Challenge deleted successfully!', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showAddChallengeDialog(BuildContext context, EcoChallengesProvider provider) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final rewardController = TextEditingController();
    final targetValueController = TextEditingController();
    final targetUnitController = TextEditingController();
    final categoryController = TextEditingController();
    
    Color selectedColor = const Color(0xFFB5C7F7);
    IconData selectedIcon = Icons.eco_rounded;
    int selectedDuration = 7;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Add New Challenge',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Challenge Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: rewardController,
                        decoration: InputDecoration(
                          labelText: 'Reward (e.g., 500 Eco Points)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: targetValueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: 'Target Value',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: targetUnitController,
                        decoration: InputDecoration(
                          labelText: 'Target Unit (e.g., days, kg)',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: categoryController,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Color Selection
                Text(
                  'Select Color:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    const Color(0xFFB5C7F7),
                    const Color(0xFFF9E79F),
                    const Color(0xFFE8D5C4),
                    Colors.cyan,
                    Colors.orange,
                    Colors.green,
                    const Color(0xFFD6EAF8),
                    const Color(0xFFE8F5E8),
                  ].map((color) => GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selectedColor == color ? Colors.black : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                  )).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Icon Selection
                Text(
                  'Select Icon:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: 120,
                  child: SingleChildScrollView(
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Icons.eco_rounded,
                        Icons.recycling_rounded,
                        Icons.store_rounded,
                        Icons.water_drop_rounded,
                        Icons.electric_bolt_rounded,
                        Icons.restaurant_rounded,
                        Icons.no_drinks_rounded,
                        Icons.directions_bike_rounded,
                        Icons.home_rounded,
                        Icons.shopping_bag_rounded,
                        Icons.self_improvement_rounded,
                        Icons.fitness_center_rounded,
                        Icons.park_rounded,
                        Icons.forest_rounded,
                        Icons.agriculture_rounded,
                        Icons.solar_power_rounded,
                        Icons.wind_power_rounded,
                        Icons.volunteer_activism_rounded,
                        Icons.psychology_rounded,
                        Icons.spa_rounded,
                        Icons.local_florist_rounded,
                        Icons.eco_rounded,
                        Icons.cleaning_services_rounded,
                        Icons.handyman_rounded,
                        Icons.construction_rounded,
                      ].map((icon) => GestureDetector(
                        onTap: () => setState(() => selectedIcon = icon),
                        child: Container(
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: selectedIcon == icon ? selectedColor.withOpacity(0.1) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedIcon == icon ? selectedColor : Colors.grey[300]!,
                              width: selectedIcon == icon ? 2 : 1,
                            ),
                          ),
                          child: Icon(
                            icon,
                            color: selectedIcon == icon ? selectedColor : Colors.grey[700],
                            size: 22,
                          ),
                        ),
                      )).toList(),
                    ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Duration Selection
                Text(
                  'Challenge Duration:',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<int>(
                  initialValue: selectedDuration,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: [7, 14, 21, 30].map((days) => DropdownMenuItem(
                    value: days,
                    child: Text('$days days'),
                  )).toList(),
                  onChanged: (value) => setState(() => selectedDuration = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: GoogleFonts.poppins(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (titleController.text.isNotEmpty &&
                    descriptionController.text.isNotEmpty &&
                    rewardController.text.isNotEmpty &&
                    targetValueController.text.isNotEmpty &&
                    targetUnitController.text.isNotEmpty &&
                    categoryController.text.isNotEmpty) {
                  
                  final now = DateTime.now();
                  final newChallenge = EcoChallenge(
                    id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                    title: titleController.text,
                    description: descriptionController.text,
                    reward: rewardController.text,
                    color: selectedColor,
                    icon: selectedIcon,
                    targetValue: int.parse(targetValueController.text),
                    targetUnit: targetUnitController.text,
                    startDate: now,
                    endDate: now.add(Duration(days: selectedDuration)),
                    category: categoryController.text,
                  );
                  
                  print('About to add challenge: ${newChallenge.title}');
                  provider.addCustomChallenge(newChallenge);
                  print('Challenge added, closing dialog');
                  Navigator.pop(context);
                  
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('New challenge added successfully!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please fill all fields!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5C7F7),
                foregroundColor: Colors.white,
              ),
              child: Text('Add Challenge', style: GoogleFonts.poppins()),
            ),
          ],
        ),
      ),
    );
  }

  // Show impact tracker
  void _showImpactTracker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Impact Tracker',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Real-time Impact Overview
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFD6EAF8).withOpacity(0.8),
                                const Color(0xFFB5C7F7).withOpacity(0.6),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFD6EAF8).withOpacity(0.3)),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.track_changes_rounded,
                                size: 48,
                                color: const Color(0xFF22223B),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Real-time Impact',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${carbonProvider.totalCarbonSaved.toStringAsFixed(1)} kg CO₂ saved',
                                style: GoogleFonts.poppins(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Key Metrics
                    Text(
                      'Key Metrics',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        return Column(
                          children: [
                            _buildImpactMetric('Carbon Saved', '${carbonProvider.totalCarbonSaved.toStringAsFixed(1)} kg', Icons.eco_rounded, Colors.green),
                            _buildImpactMetric('Money Saved', '₹${_todaysSavings.toStringAsFixed(0)}', Icons.savings_rounded, const Color(0xFFB5C7F7)),
                            _buildImpactMetric('Products Viewed', _productsViewed.toString(), Icons.visibility_rounded, const Color(0xFFF9E79F)),
                            _buildImpactMetric('Community Rank', '#${Random().nextInt(100) + 1}', Icons.leaderboard_rounded, const Color(0xFFE8D5C4)),
                            _buildImpactMetric('Eco Points', '$_ecoPoints', Icons.stars_rounded, Colors.amber),
                            _buildImpactMetric('Streak Days', '$_streakDays days', Icons.local_fire_department_rounded, Colors.orange),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Environmental Impact Breakdown
                    Text(
                      'Environmental Impact',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        final stats = carbonProvider.environmentalImpactStats;
                        return Column(
                          children: [
                            _buildEnvironmentalImpactCard(
                              'Trees Equivalent',
                              '${stats['treesEquivalent'].toStringAsFixed(0)} trees',
                              Icons.forest_rounded,
                              Colors.green,
                            ),
                            _buildEnvironmentalImpactCard(
                              'Car Travel Avoided',
                              '${stats['carKmEquivalent'].toStringAsFixed(1)} km',
                              Icons.directions_car_rounded,
                              Colors.blue,
                            ),
                            _buildEnvironmentalImpactCard(
                              'Electricity Saved',
                              '${stats['electricityEquivalent'].toStringAsFixed(1)} kWh',
                              Icons.electric_bolt_rounded,
                              Colors.orange,
                            ),
                            _buildEnvironmentalImpactCard(
                              'Water Saved',
                              '${(carbonProvider.totalCarbonSaved * 1000).toStringAsFixed(0)} L',
                              Icons.water_drop_rounded,
                              Colors.cyan,
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Progress Tracking
                    Text(
                      'Progress Tracking',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        return Column(
                          children: [
                            _buildProgressCard(
                              'Monthly Goal',
                              '${carbonProvider.currentMonthCarbonSaved.toStringAsFixed(1)} / 5.0 kg',
                              carbonProvider.currentMonthCarbonSaved / 5.0,
                              Icons.calendar_month_rounded,
                              const Color(0xFFB5C7F7),
                            ),
                            const SizedBox(height: 12),
                            _buildProgressCard(
                              'Yearly Goal',
                              '${carbonProvider.currentYearCarbonSaved.toStringAsFixed(1)} / 50.0 kg',
                              carbonProvider.currentYearCarbonSaved / 50.0,
                              Icons.calendar_today_rounded,
                              const Color(0xFFF9E79F),
                            ),
                          ],
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Recent Activity
                    Text(
                      'Recent Activity',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        if (carbonProvider.recentPurchases.isNotEmpty) {
                          return Column(
                            children: carbonProvider.recentPurchases.take(2).map((purchase) => 
                              _buildActivityCard(purchase)
                            ).toList(),
                          );
                        } else {
                          return Container(
                            padding: const EdgeInsets.all(20),
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
                            child: Column(
                              children: [
                                Icon(
                                  Icons.history_rounded,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No Recent Activity',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Start shopping eco-friendly products to see your impact!',
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey[500],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Load Sample Data Button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final carbonProvider = Provider.of<CarbonTrackingProvider>(context, listen: false);
                          carbonProvider.loadSampleData();
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Sample impact data loaded!', style: GoogleFonts.poppins()),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        icon: const Icon(Icons.refresh_rounded),
                        label: Text('Load Sample Data', style: GoogleFonts.poppins()),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFFB5C7F7),
                          side: BorderSide(color: const Color(0xFFB5C7F7)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactMetric(String title, String value, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                color: const Color(0xFF22223B),
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Show eco tips
  void _showEcoTips() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.9,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Daily Eco Tips',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                    color: Colors.grey[600],
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Today's Featured Tip
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFB5C7F7).withOpacity(0.8),
                            const Color(0xFFD6EAF8).withOpacity(0.6),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFB5C7F7).withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.lightbulb_rounded,
                            size: 48,
                            color: const Color(0xFF22223B),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Today\'s Featured Tip',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '🌱 Start your day with a plant-based meal!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reduces your carbon footprint by up to 2.5 kg CO₂ per day',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Tip Categories
                    Text(
                      'Tip Categories',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Shopping Tips
                    _buildTipCategory(
                      '🛒 Shopping Smart',
                      [
                        'Use reusable bags and containers',
                        'Choose products with minimal packaging',
                        'Buy in bulk to reduce packaging waste',
                        'Support local eco-friendly businesses',
                        'Look for organic and fair-trade labels',
                      ],
                      Icons.shopping_bag_rounded,
                      const Color(0xFFB5C7F7),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Home Tips
                    _buildTipCategory(
                      '🏠 Home & Energy',
                      [
                        'Switch to LED bulbs (saves 75% energy)',
                        'Unplug devices when not in use',
                        'Use cold water for laundry',
                        'Install low-flow showerheads',
                        'Compost kitchen waste',
                      ],
                      Icons.home_rounded,
                      const Color(0xFFF9E79F),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Transportation Tips
                    _buildTipCategory(
                      '🚗 Transportation',
                      [
                        'Walk or cycle for short distances',
                        'Use public transportation',
                        'Carpool with colleagues',
                        'Maintain your vehicle properly',
                        'Consider electric or hybrid vehicles',
                      ],
                      Icons.directions_car_rounded,
                      const Color(0xFFE8D5C4),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Food & Diet Tips
                    _buildTipCategory(
                      '🍽️ Food & Diet',
                      [
                        'Reduce meat consumption',
                        'Buy seasonal and local produce',
                        'Avoid food waste - plan meals',
                        'Grow your own herbs and vegetables',
                        'Use leftovers creatively',
                      ],
                      Icons.restaurant_rounded,
                      Colors.green,
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Water Conservation Tips
                    _buildTipCategory(
                      '💧 Water Conservation',
                      [
                        'Fix leaky faucets immediately',
                        'Take shorter showers',
                        'Collect rainwater for plants',
                        'Use a broom instead of hose',
                        'Install water-efficient appliances',
                      ],
                      Icons.water_drop_rounded,
                      Colors.cyan,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Weekly Challenge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.orange.withOpacity(0.1),
                            Colors.amber.withOpacity(0.1),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events_rounded,
                            size: 40,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'This Week\'s Challenge',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Go plastic-free for 7 days!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your progress and earn bonus eco points',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Challenge accepted! Track your progress in Impact Tracker.', style: GoogleFonts.poppins()),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                            icon: const Icon(Icons.check_rounded),
                            label: Text('Accept Challenge', style: GoogleFonts.poppins()),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Quick Actions
                    Text(
                      'Quick Actions',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToShopping();
                            },
                            icon: const Icon(Icons.shopping_cart_rounded),
                            label: Text('Shop Eco', style: GoogleFonts.poppins()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: const Color(0xFFB5C7F7),
                              side: BorderSide(color: const Color(0xFFB5C7F7)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(context);
                              _showImpactTracker();
                            },
                            icon: const Icon(Icons.track_changes_rounded),
                            label: Text('Track Impact', style: GoogleFonts.poppins()),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(color: Colors.green),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Role-specific helper methods
  Color _getRoleSpecificColor(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return const Color(0xFFB5C7F7);
      case UserRole.shopkeeper:
        return const Color(0xFFF9E79F);
      case UserRole.admin:
        return const Color(0xFFE8D5C4);
    }
  }

  IconData _getRoleSpecificIcon(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return Icons.shopping_cart_rounded;
      case UserRole.shopkeeper:
        return Icons.store_rounded;
      case UserRole.admin:
        return Icons.admin_panel_settings_rounded;
    }
  }

  // Show community updates
  void _showCommunityUpdates() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Community Activity',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 8,
                itemBuilder: (context, index) {
                  List<Map<String, dynamic>> activities = [
                    {
                      'user': 'Sarah K.',
                      'action': 'saved 2.3 kg CO2 by buying organic cotton',
                      'time': '${index + 1}m ago',
                      'icon': Icons.eco_rounded,
                      'color': Colors.green,
                    },
                    {
                      'user': 'Mike R.',
                      'action': 'purchased a bamboo water bottle',
                      'time': '${index + 3}m ago',
                      'icon': Icons.water_drop_rounded,
                      'color': const Color(0xFFB5C7F7),
                    },
                    {
                      'user': 'Emma W.',
                      'action': 'achieved 100 eco-points milestone!',
                      'time': '${index + 5}m ago',
                      'icon': Icons.stars_rounded,
                      'color': const Color(0xFFF9E79F),
                    },
                    {
                      'user': 'Alex T.',
                      'action': 'shared an eco-tip with the community',
                      'time': '${index + 7}m ago',
                      'icon': Icons.lightbulb_rounded,
                      'color': const Color(0xFFE8D5C4),
                    },
                  ];
                  
                  final activity = activities[index % activities.length];
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: activity['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            activity['icon'],
                            color: activity['color'],
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF22223B),
                                    fontSize: 14,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: activity['user'],
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ),
                                    TextSpan(text: ' ${activity['action']}'),
                                  ],
                                ),
                              ),
                              Text(
                                _getTimeAgoFromDateTime(activity['time']),
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[500],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.favorite_rounded,
                          color: Colors.red[300],
                          size: 16,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Show search filters
  void _showSearchFilters() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Search Filters',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildFilterChip('🌱 Organic', const Color(0xFFB5C7F7)),
                    const SizedBox(height: 12),
                    _buildFilterChip('♻️ Recycled', const Color(0xFFF9E79F)),
                    const SizedBox(height: 12),
                    _buildFilterChip('🌿 Biodegradable', const Color(0xFFD6EAF8)),
                    const SizedBox(height: 12),
                    _buildFilterChip('💚 Sustainable', const Color(0xFFE8D5C4)),
                    const Spacer(),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Cancel',
                              style: GoogleFonts.poppins(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _navigateToShopping();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFB5C7F7),
                            ),
                            child: Text(
                              'Apply',
                              style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const Spacer(),
          Icon(
            Icons.check_circle_outline_rounded,
            color: color,
          ),
        ],
      ),
    );
  }

  // Product interaction method
  void _onProductTap(Map<String, dynamic> product) {
    try {
      // Format product data for ProductDetailScreen
      final formattedProduct = {
        'id': product['id'] ?? product['name'],
        'name': product['name'] ?? 'Unknown Product',
        'description': product['description'] ?? 'Eco-friendly ${(product['name']?.toString() ?? 'product').toLowerCase()}',
        'price': _parsePrice(product['price']),
        'rating': product['rating'] ?? 4.5,
        'discount': product['discount'],
        'color': product['color'] ?? '#B5C7F7',
        'icon': product['icon'] ?? 'shopping_bag_rounded',
        'category': _getProductCategory(product),
        'carbonFootprint': _getProductCarbonFootprint(product),
        'waterSaved': product['waterSaved'] ?? 0.0,
        'energySaved': product['energySaved'] ?? 0.0,
        'wasteReduced': product['wasteReduced'] ?? 0.0,
        'treesEquivalent': product['treesEquivalent'] ?? 0.0,
        'material': product['material'] ?? 'Eco-friendly material',
        'image': product['image'],
      };

      // Track product view
      final productViewProvider = Provider.of<ProductViewProvider>(context, listen: false);
      productViewProvider.addProductView(formattedProduct);
      
      // Navigate to product detail screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ProductDetailScreen(product: formattedProduct),
        ),
      );
    } catch (e) {
      print('Error navigating to product detail: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error showing product details: ${e.toString()}',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Helper method to parse price string to double
  double _parsePrice(dynamic price) {
    if (price is double) return price;
    if (price is int) return price.toDouble();
    if (price is String) {
      // Remove ₹ symbol and commas, then parse
      String cleanPrice = price.replaceAll('₹', '').replaceAll(',', '').trim();
      return double.tryParse(cleanPrice) ?? 0.0;
    }
    return 0.0;
  }

  // Build trending product cards
  Widget _buildTrendingProductCard(int index) {
    List<Map<String, dynamic>> products = [
      {
        'id': 'organic-cotton-tshirt',
        'name': 'Organic Cotton T-Shirt',
        'description': 'Made from 100% organic cotton, this comfortable t-shirt is perfect for everyday wear while being environmentally friendly.',
        'price': 899.0,
        'discount': '20% OFF',
        'rating': '4.8',
        'color': '#B5C7F7',
        'icon': 'checkroom_rounded',
        'category': 'Clothing',
        'carbonFootprint': 2.5,
      },
      {
        'id': 'bamboo-water-bottle',
        'name': 'Bamboo Water Bottle',
        'description': 'Sustainable bamboo water bottle that keeps your drinks cold for hours while reducing plastic waste.',
        'price': 599.0,
        'discount': '15% OFF',
        'rating': '4.9',
        'color': '#D6EAF8',
        'icon': 'water_drop_rounded',
        'category': 'Kitchen',
        'carbonFootprint': 1.8,
      },
      {
        'id': 'reusable-shopping-bag',
        'name': 'Reusable Shopping Bag',
        'description': 'Durable and stylish reusable shopping bag made from recycled materials.',
        'price': 299.0,
        'discount': 'NEW',
        'rating': '4.7',
        'color': '#E8D5C4',
        'icon': 'shopping_bag_rounded',
        'category': 'Lifestyle',
        'carbonFootprint': 0.5,
      },
      {
        'id': 'eco-friendly-soap',
        'name': 'Eco-Friendly Soap',
        'description': 'Natural soap bar made with organic ingredients and packaged in biodegradable materials.',
        'price': 199.0,
        'discount': '25% OFF',
        'rating': '4.6',
        'color': '#F9E79F',
        'icon': 'spa_rounded',
        'category': 'Personal Care',
        'carbonFootprint': 0.3,
      },
      {
        'id': 'solar-phone-charger',
        'name': 'Solar Phone Charger',
        'description': 'Portable solar charger that harnesses renewable energy to charge your devices on the go.',
        'price': 1299.0,
        'discount': 'HOT',
        'rating': '4.9',
        'color': '#B5C7F7',
        'icon': 'solar_power_rounded',
        'category': 'Electronics',
        'carbonFootprint': 1.2,
      },
    ];

    final product = products[index % products.length];

    return GestureDetector(
      onTap: () => _onProductTap(product),
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image/Icon Section
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  color: _parseColor(product['color']).withOpacity(0.2),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Icon(
                        _getIconFromString(product['icon']),
                        color: _parseColor(product['color']),
                        size: 40,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          product['discount'] ?? 'NEW',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    // Wishlist button
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Consumer2<WishlistProvider, SpringAuthProvider>(
                        builder: (context, wishlistProvider, authProvider, child) {
                          final isInWishlist = wishlistProvider.isInWishlist(product['id']);
                          final currentUserId = authProvider.isAuthenticated ? authProvider.userId : null;
                          
                          return GestureDetector(
                            onTap: () async {
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
                                  productId: product['id'],
                                );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Removed from wishlist',
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
                                  productId: product['id'],
                                  productName: product['name'] ?? 'Unknown Product',
                                  price: product['price'] ?? 0.0,
                                  imageUrl: product['imageUrl'] ?? '',
                                  category: product['category'] ?? 'General',
                                );
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Added to wishlist',
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                                      ),
                                      backgroundColor: Colors.green[300],
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                isInWishlist ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                                color: isInWishlist ? Colors.red : Colors.grey[600],
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Product Details Section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product['name'] ?? 'Unknown Product',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                          color: const Color(0xFF22223B),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            product['rating'] ?? '4.5',
                            style: GoogleFonts.poppins(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      // Environmental Impact
                      Row(
                        children: [
                          Icon(
                            Icons.eco_rounded,
                            size: 8,
                            color: Colors.green[600],
                          ),
                          const SizedBox(width: 1),
                          Text(
                            '${product['carbonFootprint']?.toStringAsFixed(1) ?? '0.0'} kg CO₂',
                            style: GoogleFonts.poppins(
                              fontSize: 7,
                              color: Colors.green[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '₹${(product['price'] ?? 0.0).toStringAsFixed(0)}',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              color: _parseColor(product['color']),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              _showSnackBar('Cart functionality will be implemented');
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: _parseColor(product['color']).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Icon(
                                Icons.add_shopping_cart_rounded,
                                color: _parseColor(product['color']),
                                size: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
    String _getRoleSpecificButtonText(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Start Shopping';
      case UserRole.shopkeeper:
        return 'Manage Inventory';
      case UserRole.admin:
        return 'Admin Panel';
    }
  }

  void _handleRoleSpecificAction(UserRole role) {
    switch (role) {
      case UserRole.customer:
        _navigateToShopping();
        break;
      case UserRole.shopkeeper:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ShopkeeperDashboardScreen(),
          ),
        );
        break;
      case UserRole.admin:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminDashboardScreen(),
          ),
        );
        break;
    }
  }

  // New helper methods for enhanced functionality
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFB5C7F7),
        duration: const Duration(seconds: 2),
      ),
    );
  }



  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered':
      case 'completed':
        return Colors.green;
      case 'in transit':
      case 'shipped':
        return const Color(0xFFB5C7F7);
      case 'processing':
      case 'pending':
        return const Color(0xFFF9E79F);
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: challenge['color'].withOpacity(0.2),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  challenge['icon'],
                  color: challenge['color'],
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      challenge['title'],
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    Text(
                      challenge['reward'],
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: challenge['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            challenge['description'],
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progress',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  Text(
                    '${(challenge['progress'] * 100).toInt()}%',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: challenge['color'],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: challenge['progress'],
                backgroundColor: challenge['color'].withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(challenge['color']),
              ),
            ],
          ),
        ],
      ),
    );
  }





  Widget _buildSettingsCard(String title, String subtitle, IconData icon, Color color, VoidCallback onTap, {Widget? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }









  void _showNotificationSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          'Notification Settings',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildNotificationOption('Order Updates', true),
            _buildNotificationOption('Eco Tips', true),
            _buildNotificationOption('New Products', false),
            _buildNotificationOption('Community Updates', true),
            _buildNotificationOption('Special Offers', false),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(color: const Color(0xFFB5C7F7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String title, bool isEnabled) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: const Color(0xFF22223B),
            ),
          ),
          Switch(
            value: isEnabled,
            onChanged: (value) {
              // Handle notification toggle
            },
            activeThumbColor: const Color(0xFFB5C7F7),
          ),
        ],
      ),
    );
  }

  void _showEcoProfile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Eco Profile',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Consumer<CarbonTrackingProvider>(
                      builder: (context, carbonProvider, child) {
                        return _buildProfileMetric('Total Carbon Saved', '${carbonProvider.totalCarbonSaved.toStringAsFixed(1)} kg');
                      },
                    ),
                    _buildProfileMetric('Eco Points', '$_ecoPoints'),
                    _buildProfileMetric('Current Streak', '$_streakDays days'),
                    _buildProfileMetric('Total Orders', '0'),
                    Consumer<WishlistProvider>(
                      builder: (context, wishlistProvider, child) {
                        return _buildProfileMetric('Wishlist Items', '${wishlistProvider.totalItems}');
                      },
                    ),
                    _buildProfileMetric('Challenges Completed', '2'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileMetric(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF22223B),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFB5C7F7),
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSupport() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Help & Support',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildHelpOption('FAQ', Icons.question_answer_rounded),
                    _buildHelpOption('Contact Support', Icons.support_agent_rounded),
                    _buildHelpOption('Report Issue', Icons.bug_report_rounded),
                    _buildHelpOption('Privacy Policy', Icons.privacy_tip_rounded),
                    _buildHelpOption('Terms of Service', Icons.description_rounded),
                    _buildHelpOption('About EcoBazaarX', Icons.info_rounded),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHelpOption(String title, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: _buildSettingsCard(
        title,
        'Tap to view $title',
        icon,
        const Color(0xFFD6EAF8),
        () => _showSnackBar('$title feature coming soon!'),
      ),
    );
  }

  





  // Helper method to determine product category
  String _getProductCategory(Map<String, dynamic> product) {
    String name = (product['name']?.toString() ?? 'unknown').toLowerCase();
    String iconString = product['icon']?.toString() ?? 'shopping_bag_rounded';
    
    if (name.contains('cotton') || name.contains('tshirt') || name.contains('clothing') || 
        iconString == 'checkroom_rounded') {
      return 'Clothing';
    } else if (name.contains('bamboo') || name.contains('water') || name.contains('bottle') || 
               iconString == 'water_drop_rounded') {
      return 'Home & Garden';
    } else if (name.contains('bag') || name.contains('shopping') || 
               iconString == 'shopping_bag_rounded') {
      return 'Accessories';
    } else if (name.contains('soap') || name.contains('personal') || 
               iconString == 'spa_rounded') {
      return 'Personal Care';
    } else if (name.contains('solar') || name.contains('charger') || 
               iconString == 'solar_power_rounded') {
      return 'Electronics';
    } else if (name.contains('honey') || name.contains('organic') || 
               iconString == 'restaurant_rounded') {
      return 'Food & Beverages';
    } else {
      return 'Other';
    }
  }

  // Helper method to calculate carbon footprint
  double _getProductCarbonFootprint(Map<String, dynamic> product) {
    String name = (product['name']?.toString() ?? 'unknown').toLowerCase();
    String iconString = product['icon']?.toString() ?? 'shopping_bag_rounded';
    
    if (name.contains('cotton') || name.contains('tshirt') || name.contains('clothing') || 
        iconString == 'checkroom_rounded') {
      return 2.5; // kg CO2 saved per clothing item
    } else if (name.contains('bamboo') || name.contains('water') || name.contains('bottle') || 
               iconString == 'water_drop_rounded') {
      return 1.8; // kg CO2 saved per reusable bottle
    } else if (name.contains('bag') || name.contains('shopping') || 
               iconString == 'shopping_bag_rounded') {
      return 1.2; // kg CO2 saved per reusable bag
    } else if (name.contains('soap') || name.contains('personal') || 
               iconString == 'spa_rounded') {
      return 0.8; // kg CO2 saved per eco soap
    } else if (name.contains('solar') || name.contains('charger') || 
               iconString == 'solar_power_rounded') {
      return 3.5; // kg CO2 saved per solar charger
    } else if (name.contains('honey') || name.contains('organic') || 
               iconString == 'restaurant_rounded') {
      return 1.5; // kg CO2 saved per organic food item
    } else {
      return 1.0; // Default carbon footprint
    }
  }

  // Shopkeeper Orders Management
  void _showShopkeeperOrders() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildShopkeeperOrdersModal(),
    );
  }

  Widget _buildShopkeeperOrdersModal() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Color(0xFFF7F6F2),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.symmetric(vertical: 16),
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Text(
                  'Shopkeeper Orders 📦',
                  style: GoogleFonts.poppins(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Orders Summary
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: _buildOrderStatCard(
                    'Pending',
                    '12',
                    Icons.pending_rounded,
                    const Color(0xFFFFB74D),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOrderStatCard(
                    'Processing',
                    '8',
                    Icons.sync_rounded,
                    const Color(0xFF64B5F6),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildOrderStatCard(
                    'Completed',
                    '45',
                    Icons.check_circle_rounded,
                    const Color(0xFF81C784),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Orders List
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Orders Header
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        Text(
                          'Recent Orders',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E8),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '₹12,450',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Orders List
                  Expanded(
                    child: Consumer<OrdersProvider>(
                      builder: (context, ordersProvider, child) {
                        final orders = ordersProvider.getFormattedAllOrders();
                        return ordersProvider.isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : orders.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.shopping_bag_outlined,
                                          size: 64,
                                          color: Colors.grey[400],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          'No orders yet',
                                          style: GoogleFonts.poppins(
                                            fontSize: 18,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'Orders will appear here when customers place them',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    padding: const EdgeInsets.symmetric(horizontal: 20),
                                    itemCount: orders.length,
                                    itemBuilder: (context, index) {
                                      final order = orders[index];
                                      return _buildOrderItemFromData(order, index);
                                    },
                                  );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildOrderStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF22223B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItemFromData(Map<String, dynamic> order, int index) {
    final status = order['status'] ?? 'Unknown';
    final statusColor = _getStatusColor(status);
    final orderNumber = order['id'] ?? 'Unknown';
    final customerName = order['orderData']?['userName'] ?? 'Unknown Customer';
    final amount = double.tryParse(order['amount']?.toString().replaceAll('₹', '') ?? '0') ?? 0.0;
    final items = (order['orderData']?['items'] as List<dynamic>?)?.length.toString() ?? '0';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          // Order Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.shopping_bag_rounded,
              color: statusColor,
              size: 20,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Order Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        orderNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status.substring(0, status.length > 6 ? 6 : status.length),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  customerName,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: const Color(0xFF22223B).withOpacity(0.7),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      '$items items',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: const Color(0xFF22223B).withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${amount.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 8),
          
          // Action Button
          Container(
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showOrderDetails(index),
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Text(
                    status == 'Completed' ? 'View' : 'Update',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetails(int orderIndex) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Order Details',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order: ORD-${(2024000 + orderIndex).toString()}'),
            const SizedBox(height: 8),
            Text('Customer: ${['Priya Sharma', 'Rahul Kumar', 'Anjali Patel', 'Vikram Singh', 'Meera Reddy'][orderIndex % 5]}'),
            const SizedBox(height: 8),
            Text('Amount: ₹${(1200 + (orderIndex * 150)).toStringAsFixed(0)}'),
            const SizedBox(height: 8),
            Text('Status: ${['Pending', 'Processing', 'Completed'][orderIndex % 3]}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getTimeAgoFromDateTime(dynamic timeValue) {
    DateTime dateTime;
    
    // Handle both DateTime objects and String timestamps
    if (timeValue is DateTime) {
      dateTime = timeValue;
    } else if (timeValue is String) {
      try {
        dateTime = DateTime.parse(timeValue);
      } catch (e) {
        // If parsing fails, return a fallback message
        return 'Recently';
      }
    } else {
      // If it's neither DateTime nor String, return fallback
      return 'Recently';
    }
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
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

  // Helper method to convert Color to hex string
  String _colorToString(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }

  // Helper method to convert IconData to string
  String _iconToString(IconData icon) {
    // Map common icons to their string representations
    final iconMap = {
      Icons.shopping_bag_rounded: 'shopping_bag_rounded',
      Icons.checkroom_rounded: 'checkroom_rounded',
      Icons.water_drop_rounded: 'water_drop_rounded',
      Icons.solar_power_rounded: 'solar_power_rounded',
      Icons.brush_rounded: 'brush_rounded',
      Icons.spa_rounded: 'spa_rounded',
      Icons.book_rounded: 'book_rounded',
      Icons.face_rounded: 'face_rounded',
      Icons.fitness_center_rounded: 'fitness_center_rounded',
      Icons.local_florist_rounded: 'local_florist_rounded',
      Icons.local_cafe_rounded: 'local_cafe_rounded',
      Icons.eco_rounded: 'eco_rounded',
      Icons.recycling_rounded: 'recycling_rounded',
      Icons.park_rounded: 'park_rounded',
      Icons.forest_rounded: 'forest_rounded',
      Icons.local_drink_rounded: 'local_drink_rounded',
      Icons.directions_bus_rounded: 'directions_bus_rounded',
      Icons.directions_walk_rounded: 'directions_walk_rounded',
      Icons.restaurant_rounded: 'restaurant_rounded',
      Icons.lightbulb_rounded: 'lightbulb_rounded',
      Icons.store_rounded: 'store_rounded',
    };
    
    return iconMap[icon] ?? 'shopping_bag_rounded';
  }

  // Show wishlist screen
  void _showWishlist() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const WishlistScreen(),
      ),
    );
  }

  // Show recently viewed screen
  void _showRecentlyViewed() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Color(0xFFF7F6F2),
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(32),
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.5),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  Text(
                    'Recently Viewed Products',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF22223B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Consumer<ProductViewProvider>(
                builder: (context, productViewProvider, child) {
                  final recentlyViewed = productViewProvider.viewedProducts;
                  
                  if (recentlyViewed.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.visibility_off_rounded,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No Products Viewed Yet',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Start browsing products to see them here!',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  
                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: recentlyViewed.length,
                    itemBuilder: (context, index) {
                      final product = recentlyViewed[index];
                      return _buildRecentlyViewedListItem(product);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build recently viewed card for dashboard
  Widget _buildRecentlyViewedCard(ProductView product) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: product.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product.icon,
              color: product.color,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.name,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '₹${product.price.toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: product.color,
            ),
          ),
          const SizedBox(height: 8),
                            GestureDetector(
                    onTap: () {
                      // Navigate to product detail (no need to pop since we're not in a modal)
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(product: {
                            'id': product.productId,
                            'name': product.name,
                            'description': product.description,
                            'price': product.price,
                            'color': _colorToString(product.color),
                            'icon': _iconToString(product.icon),
                            'category': product.category,
                            'carbonFootprint': 1.0,
                            'waterSaved': 0.0,
                            'energySaved': 0.0,
                            'wasteReduced': 0.0,
                            'treesEquivalent': 0.0,
                            'material': 'Eco-friendly material',
                            'rating': product.rating,
                            'quantity': 10, // Add default quantity
                          }),
                        ),
                      );
                    },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: product.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: product.color.withOpacity(0.3),
                ),
              ),
              child: Text(
                'View Details',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: product.color,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build recently viewed list item for modal
  Widget _buildRecentlyViewedListItem(ProductView product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: product.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              product.icon,
              color: product.color,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.description,
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
                    Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      product.rating.toStringAsFixed(1),
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₹${product.price.toStringAsFixed(0)}',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: product.color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build wishlist card
  Widget _buildWishlistCard(Map<String, dynamic> item) {
    return Container(
      width: 160,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _parseColor(item['productColor']).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIconFromString(item['productIcon']),
                  color: _parseColor(item['productColor']),
                  size: 20,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
                  final wishlistProvider = Provider.of<WishlistProvider>(context, listen: false);
                  
                  if (authProvider.isAuthenticated && authProvider.userId != null) {
                    await wishlistProvider.removeFromWishlist(
                      userId: authProvider.userId!,
                      productId: item['productId'],
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Removed from wishlist', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Icon(
                  Icons.close_rounded,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            (item['productName']?.toString() ?? 'Unknown Product'),
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            '₹${_parseDouble(item['productPrice']).toStringAsFixed(0)}',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _parseColor(item['productColor']),
            ),
          ),
          const SizedBox(height: 8),
          // Add to Cart functionality
          Row(
            children: [
              Consumer2<CartProvider, SpringAuthProvider>(
                builder: (context, cartProvider, authProvider, child) {
                  return GestureDetector(
                    onTap: () => _addToCart(item, cartProvider, authProvider),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: _parseColor(item['productColor']).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        Icons.add_shopping_cart_rounded,
                        color: _parseColor(item['productColor']),
                        size: 14,
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(product: {
                        'id': item['productId']?.toString() ?? 'unknown',
                        'name': item['productName']?.toString() ?? 'Unknown Product',
                        'description': item['productDescription']?.toString() ?? 'Eco-friendly product',
                        'price': _parseDouble(item['productPrice']),
                        'color': item['productColor'] is String ? item['productColor'] : _colorToString(_parseColor(item['productColor'])),
                        'icon': item['productIcon'] is String ? item['productIcon'] : _iconToString(_getIconFromString(item['productIcon'])),
                        'category': item['productCategory']?.toString() ?? 'General',
                        'carbonFootprint': _parseDouble(item['carbonFootprint'] ?? 1.0),
                        'waterSaved': _parseDouble(item['waterSaved'] ?? 0.0),
                        'energySaved': _parseDouble(item['energySaved'] ?? 0.0),
                        'wasteReduced': _parseDouble(item['wasteReduced'] ?? 0.0),
                        'treesEquivalent': _parseDouble(item['treesEquivalent'] ?? 0.0),
                        'material': item['material']?.toString() ?? 'Eco-friendly material',
                        'rating': _parseDouble(item['rating'] ?? 4.5),
                        'quantity': _parseDouble(item['quantity'] ?? 10.0),
                      }),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _parseColor(item['productColor']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: _parseColor(item['productColor']).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    'Details',
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: _parseColor(item['productColor']),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PastelActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PastelActionCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF22223B), size: 28),
            const SizedBox(height: 10),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
