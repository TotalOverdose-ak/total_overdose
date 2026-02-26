import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/orders_provider.dart';
import 'dart:math';

class AdminOrderTrackingScreen extends StatefulWidget {
  const AdminOrderTrackingScreen({super.key});

  @override
  State<AdminOrderTrackingScreen> createState() => _AdminOrderTrackingScreenState();
}

class _AdminOrderTrackingScreenState extends State<AdminOrderTrackingScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late TabController _tabController;
  
  List<Map<String, dynamic>> _allOrders = [];
  List<Map<String, dynamic>> _pendingOrders = [];
  List<Map<String, dynamic>> _shippedOrders = [];
  List<Map<String, dynamic>> _deliveredOrders = [];
  
  bool _isLoading = true;
  bool _useBackend = true; // Toggle to use backend or sample data

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
    _fadeController.forward();
  }

  // Load orders from backend
  Future<void> _loadOrders() async {
    if (!_useBackend) {
      _loadSampleData();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      print('🔄 Loading orders from backend...');
      final ordersProvider = Provider.of<OrdersProvider>(context, listen: false);
      
      // Load all orders from backend
      await ordersProvider.loadAllOrders(limit: 200);
      
      final allOrders = ordersProvider.allOrders;
      print('✅ Loaded ${allOrders.length} orders from backend');

      setState(() {
        _allOrders = allOrders;
        _pendingOrders = allOrders.where((order) => 
          (order['status']?.toString().toUpperCase() ?? '') == 'PENDING'
        ).toList();
        _shippedOrders = allOrders.where((order) => 
          (order['status']?.toString().toUpperCase() ?? '') == 'SHIPPED'
        ).toList();
        _deliveredOrders = allOrders.where((order) => 
          (order['status']?.toString().toUpperCase() ?? '') == 'DELIVERED'
        ).toList();
        _isLoading = false;
      });

      print('📊 Orders breakdown:');
      print('   Total: ${_allOrders.length}');
      print('   Pending: ${_pendingOrders.length}');
      print('   Shipped: ${_shippedOrders.length}');
      print('   Delivered: ${_deliveredOrders.length}');
    } catch (e) {
      print('❌ Error loading orders from backend: $e');
      // Fallback to sample data
      _loadSampleData();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadSampleData() {
    // Sample order data - in real app this would come from backend
    final sampleOrders = [
      {
        'id': 'ORD001',
        'customerName': 'Akash Kumar',
        'customerEmail': 'akash@example.com',
        'customerPhone': '+91-9876543210',
        'shopkeeperName': 'EcoMart Store',
        'shopkeeperEmail': 'ecomart@store.com',
        'productName': 'Bamboo Water Bottle',
        'productPrice': 599.0,
        'quantity': 2,
        'totalAmount': 1198.0,
        'orderDate': '2025-09-14T10:30:00',
        'status': 'PENDING',
        'trackingId': 'TRK${Random().nextInt(1000000)}',
        'estimatedDelivery': '2025-09-18',
        'isEcoFriendly': true,
        'ecoDiscount': 10.0,
        'category': 'Eco Products'
      },
      {
        'id': 'ORD002',
        'customerName': 'Priya Singh',
        'customerEmail': 'priya@example.com',
        'customerPhone': '+91-9876543211',
        'shopkeeperName': 'Green Life Store',
        'shopkeeperEmail': 'greenlife@store.com',
        'productName': 'Organic Cotton T-Shirt',
        'productPrice': 899.0,
        'quantity': 1,
        'totalAmount': 809.1, // After 10% eco discount
        'orderDate': '2025-09-14T11:15:00',
        'status': 'SHIPPED',
        'trackingId': 'TRK${Random().nextInt(1000000)}',
        'estimatedDelivery': '2025-09-17',
        'isEcoFriendly': true,
        'ecoDiscount': 10.0,
        'category': 'Clothing'
      },
      {
        'id': 'ORD003',
        'customerName': 'Rahul Sharma',
        'customerEmail': 'rahul@example.com',
        'customerPhone': '+91-9876543212',
        'shopkeeperName': 'Tech Hub',
        'shopkeeperEmail': 'techhub@store.com',
        'productName': 'Wireless Headphones',
        'productPrice': 2999.0,
        'quantity': 1,
        'totalAmount': 2999.0,
        'orderDate': '2025-09-14T12:45:00',
        'status': 'DELIVERED',
        'trackingId': 'TRK${Random().nextInt(1000000)}',
        'estimatedDelivery': '2025-09-16',
        'isEcoFriendly': false,
        'ecoDiscount': 0.0,
        'category': 'Electronics'
      },
      {
        'id': 'ORD004',
        'customerName': 'Sneha Patel',
        'customerEmail': 'sneha@example.com',
        'customerPhone': '+91-9876543213',
        'shopkeeperName': 'EcoMart Store',
        'shopkeeperEmail': 'ecomart@store.com',
        'productName': 'Solar Power Bank',
        'productPrice': 1599.0,
        'quantity': 1,
        'totalAmount': 1439.1, // After 10% eco discount
        'orderDate': '2025-09-14T14:20:00',
        'status': 'SHIPPED',
        'trackingId': 'TRK${Random().nextInt(1000000)}',
        'estimatedDelivery': '2025-09-19',
        'isEcoFriendly': true,
        'ecoDiscount': 10.0,
        'category': 'Electronics'
      },
      {
        'id': 'ORD005',
        'customerName': 'Vikash Gupta',
        'customerEmail': 'vikash@example.com',
        'customerPhone': '+91-9876543214',
        'shopkeeperName': 'Green Life Store',
        'shopkeeperEmail': 'greenlife@store.com',
        'productName': 'Reusable Shopping Bags Set',
        'productPrice': 299.0,
        'quantity': 3,
        'totalAmount': 807.3, // After 10% eco discount
        'orderDate': '2025-09-14T15:10:00',
        'status': 'PENDING',
        'trackingId': 'TRK${Random().nextInt(1000000)}',
        'estimatedDelivery': '2025-09-20',
        'isEcoFriendly': true,
        'ecoDiscount': 10.0,
        'category': 'Eco Products'
      },
    ];

    setState(() {
      _allOrders = sampleOrders;
      _pendingOrders = sampleOrders.where((order) => order['status'] == 'PENDING').toList();
      _shippedOrders = sampleOrders.where((order) => order['status'] == 'SHIPPED').toList();
      _deliveredOrders = sampleOrders.where((order) => order['status'] == 'DELIVERED').toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F6F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Order Tracking Dashboard',
          style: GoogleFonts.poppins(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF22223B)),
            onPressed: _loadSampleData,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Column(
          children: [
            // Stats Header
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB5C7F7), Color(0xFFD6EAF8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _allOrders.length.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Total Orders',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _pendingOrders.length.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Pending',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          _allOrders.where((o) => o['isEcoFriendly'] == true).length.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Eco Orders',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Tab Bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF22223B),
                unselectedLabelColor: Colors.grey[600],
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
                indicator: BoxDecoration(
                  color: const Color(0xFFB5C7F7).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'All Orders'),
                  Tab(text: 'Pending'),
                  Tab(text: 'Shipped'),
                  Tab(text: 'Delivered'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildOrdersList(_allOrders),
                        _buildOrdersList(_pendingOrders),
                        _buildOrdersList(_shippedOrders),
                        _buildOrdersList(_deliveredOrders),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList(List<Map<String, dynamic>> orders) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No orders found',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'] as String;
    Color statusColor = _getStatusColor(status);
    IconData statusIcon = _getStatusIcon(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: order['isEcoFriendly'] 
            ? Border.all(color: const Color(0xFFD6EAF8).withOpacity(0.5), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFD6EAF8).withOpacity(0.12),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Order ID and Status
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Order ${order['id']}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          if (order['isEcoFriendly'])
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'ECO',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),
                      Text(
                        status,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'ID: ${order['trackingId']}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer Info
                Row(
                  children: [
                    const Icon(Icons.person, color: Color(0xFFB5C7F7), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer: ${order['customerName']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          Text(
                            '${order['customerEmail']} • ${order['customerPhone']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Shopkeeper Info
                Row(
                  children: [
                    const Icon(Icons.store, color: Color(0xFF4CAF50), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store: ${order['shopkeeperName']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          Text(
                            order['shopkeeperEmail'],
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Product Info
                Row(
                  children: [
                    const Icon(Icons.shopping_bag, color: Color(0xFFFF9800), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order['productName'],
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          Text(
                            'Qty: ${order['quantity']} • ${order['category']}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Price Info
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Price: ₹${order['productPrice'].toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey[700],
                              ),
                            ),
                            if (order['isEcoFriendly'] && order['ecoDiscount'] > 0)
                              Text(
                                'Eco Discount: ${order['ecoDiscount']}%',
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'Total: ₹${order['totalAmount'].toStringAsFixed(2)}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          if (order['isEcoFriendly'] && order['ecoDiscount'] > 0)
                            Text(
                              'Saved: ₹${(order['productPrice'] * order['quantity'] - order['totalAmount']).toStringAsFixed(2)}',
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Delivery Info
                Row(
                  children: [
                    const Icon(Icons.local_shipping, color: Color(0xFF9C27B0), size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Expected Delivery: ${order['estimatedDelivery']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _showTrackingDetails(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: statusColor,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        'Track',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'PENDING':
        return Colors.orange;
      case 'SHIPPED':
        return Colors.blue;
      case 'DELIVERED':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'PENDING':
        return Icons.pending;
      case 'SHIPPED':
        return Icons.local_shipping;
      case 'DELIVERED':
        return Icons.check_circle;
      default:
        return Icons.shopping_bag;
    }
  }

  void _showTrackingDetails(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFB5C7F7),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.track_changes, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    'Order Tracking',
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
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tracking ID: ${order['trackingId']}',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Order: ${order['productName']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                          Text(
                            'Customer: ${order['customerName']}',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: _buildTrackingTimeline(order),
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

  Widget _buildTrackingTimeline(Map<String, dynamic> order) {
    final status = order['status'] as String;
    final steps = [
      {'title': 'Order Placed', 'completed': true},
      {'title': 'Order Confirmed', 'completed': true},
      {'title': 'In Transit', 'completed': status == 'SHIPPED' || status == 'DELIVERED'},
      {'title': 'Out for Delivery', 'completed': status == 'DELIVERED'},
      {'title': 'Delivered', 'completed': status == 'DELIVERED'},
    ];

    return ListView.builder(
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final step = steps[index];
        final isCompleted = step['completed'] as bool;
        final isLast = index == steps.length - 1;

        return Row(
          children: [
            Column(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(Icons.check, color: Colors.white, size: 12)
                      : null,
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 40,
                    color: isCompleted ? Colors.green : Colors.grey[300],
                  ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                step['title'] as String,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
                  color: isCompleted ? Colors.green : Colors.grey[600],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}