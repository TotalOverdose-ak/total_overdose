import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
// import 'package:cloud_firestore/cloud_firestore.dart'; // DISABLED - Using Spring Boot Backend
import '../../providers/spring_auth_provider.dart';
import '../../providers/store_provider.dart';
import '../../providers/product_provider.dart';

class ShopkeeperDashboardScreen extends StatefulWidget {
  const ShopkeeperDashboardScreen({super.key});

  @override
  State<ShopkeeperDashboardScreen> createState() =>
      _ShopkeeperDashboardScreenState();
}

class _ShopkeeperDashboardScreenState extends State<ShopkeeperDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  int _ordersToday = 0;

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

    _fadeController.forward();
    _slideController.forward();
    
    _loadOrdersToday();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _loadOrdersToday() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    // DISABLED - Using Spring Boot Backend
    // FirebaseFirestore.instance
    //     .collection('orders')
    //     .where('orderDate', isGreaterThanOrEqualTo: startOfDay)
    //     .where('orderDate', isLessThan: endOfDay)
    //     .snapshots()
    //     .listen((snapshot) {
    //   if (mounted) {
    //     setState(() {
    //       _ordersToday = snapshot.docs.length;
    //     });
    //   }
    // });
    
    // TODO: Implement with Spring Boot API
    setState(() {
      _ordersToday = 0; // Placeholder value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 32.0,
                  horizontal: 24.0,
                ),
                child: Row(
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
                        Icons.store_rounded,
                        size: 30,
                        color: Color(0xFF22223B),
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
                                'My Store Dashboard\nHello, ${authProvider.userName ?? 'Shopkeeper'}!',
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
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF9E79F),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Color(0xFF22223B),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Quick Stats Cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _PastelStatCard(
                      title: 'Total Products',
                      value: '247',
                      color: const Color(0xFFB5C7F7),
                      icon: Icons.inventory_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Orders Today',
                      value: '$_ordersToday',
                      color: const Color(0xFFF9E79F),
                      icon: Icons.shopping_cart_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    _PastelStatCard(
                      title: 'Revenue',
                      value: '₹12.5K',
                      color: const Color(0xFFD6EAF8),
                      icon: Icons.currency_rupee_rounded,
                    ),
                    const SizedBox(width: 16),
                    _PastelStatCard(
                      title: 'Eco Rating',
                      value: '4.8★',
                      color: const Color(0xFFE8D5C4),
                      icon: Icons.eco_rounded,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Store Management
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Store Management',
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
                      child: _PastelActionCard(
                        icon: Icons.add_box_rounded,
                        label: 'Add Product',
                        color: const Color(0xFFF9E79F),
                        onTap: () => _showAddProduct(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.inventory_rounded,
                        label: 'Manage Stock',
                        color: const Color(0xFFB5C7F7),
                        onTap: () => _showManageStock(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.list_alt_rounded,
                        label: 'View Orders',
                        color: const Color(0xFFD6EAF8),
                        onTap: () => _showOrders(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.add_business_rounded,
                        label: 'Add Store',
                        color: const Color(0xFFB5C7F7),
                        onTap: () {
                          print('Add Store button clicked!');
                          _showAddStoreDialog(context);
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.store_rounded,
                        label: 'View Stores',
                        color: const Color(0xFFE8D5C4),
                        onTap: () => _showViewStores(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.analytics_rounded,
                        label: 'Store Analytics',
                        color: const Color(0xFFF9E79F),
                        onTap: () => _showStoreAnalytics(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Store Performance
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Store Performance',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Performance Overview Card
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
                      Text(
                        'This Month\'s Performance',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sales Growth: +24%',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFB5C7F7),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Customer Rating: 4.8/5',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 16),
                      LinearProgressIndicator(
                        value: 0.75,
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

              // Sustainability Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Sustainability Impact',
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
                      child: _PastelActionCard(
                        icon: Icons.eco_rounded,
                        label: 'Eco Products',
                        color: const Color(0xFFE8D5C4),
                        onTap: () => _showEcoProducts(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.analytics_rounded,
                        label: 'Impact Report',
                        color: const Color(0xFFD6EAF8),
                        onTap: () => _showImpactReport(context),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PastelActionCard(
                        icon: Icons.trending_up_rounded,
                        label: 'Improve Score',
                        color: const Color(0xFFF9E79F),
                        onTap: () => _showImprovementTips(context),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddProduct(context),
        backgroundColor: const Color(0xFFB5C7F7),
        child: const Icon(
          Icons.add,
          color: Color(0xFF22223B),
        ),
      ),
    );
  }

  // Shopkeeper action methods
  void _showAddProduct(BuildContext context) {
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
                    'Add New Product',
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
                child: _buildAddProductForm(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showManageStock(BuildContext context) {
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
                    'Manage My Products',
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
              child: _buildProductManagementList(),
            ),
          ],
        ),
      ),
    );
  }

  void _showOrders(BuildContext context) {
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
                    'Customer Orders',
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
              child: _buildOrdersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    // DISABLED - Using Spring Boot Backend
    // TODO: Implement with Spring Boot API
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Orders will be loaded from Spring Boot backend',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
    
    // Original Firestore code (commented out):
    // return StreamBuilder<QuerySnapshot>(
    //   stream: FirebaseFirestore.instance
    //       .collection('orders')
    //       .orderBy('createdAt', descending: true)
    //       .snapshots(),
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return const Center(
    //         child: CircularProgressIndicator(
    //           valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB5C7F7)),
    //         ),
    //       );
    //     }
    //
    //     if (snapshot.hasError) {
    //       return Center(
    //         child: Text(
    //           'Error loading orders: ${snapshot.error}',
    //           style: GoogleFonts.poppins(color: Colors.red),
    //         ),
    //       );
    //     }
    //
    //     if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
    //       return Center(
    //         child: Column(
    //           mainAxisAlignment: MainAxisAlignment.center,
    //           children: [
    //             Icon(
    //               Icons.shopping_cart_outlined,
    //               size: 64,
    //               color: Colors.grey[400],
    //             ),
    //             const SizedBox(height: 16),
    //             Text(
    //               'No orders yet',
    //               style: GoogleFonts.poppins(
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.w500,
    //                 color: Colors.grey[600],
    //               ),
    //             ),
    //             const SizedBox(height: 8),
    //             Text(
    //               'Orders from customers will appear here',
    //               style: GoogleFonts.poppins(
    //                 fontSize: 14,
    //                 color: Colors.grey[500],
    //               ),
    //             ),
    //           ],
    //         ),
    //       );
    //     }
    //
    //     final orders = snapshot.data!.docs;
    //     return ListView.builder(
    //       padding: const EdgeInsets.symmetric(horizontal: 24),
    //       itemCount: orders.length,
    //       itemBuilder: (context, index) {
    //         final order = orders[index].data() as Map<String, dynamic>;
    //         return _buildOrderCard(order);
    //       },
    //     );
    //   },
    // );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderId = order['orderId'] ?? 'N/A';
    final customerName = order['userName'] ?? 'Unknown Customer';
    final customerEmail = order['userEmail'] ?? 'N/A';
    final totalAmount = order['finalAmount'] ?? 0.0;
    final orderStatus = order['orderStatus'] ?? 'pending';
    final orderDate = order['orderDate'] != null 
        ? DateTime.parse(order['orderDate'].toString()) // DISABLED - Using Spring Boot Backend
        : DateTime.now();
    final items = order['items'] as List<dynamic>? ?? [];

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(orderStatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orderStatus.toUpperCase(),
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: _getStatusColor(orderStatus),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '₹${totalAmount.toStringAsFixed(2)}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Order #$orderId',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Customer: $customerName',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Email: $customerEmail',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Date: ${_formatDate(orderDate)}',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Items (${items.length}):',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            ...items.take(3).map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                '• ${item['name'] ?? 'Unknown Product'} (Qty: ${item['quantity'] ?? 1})',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            )),
            if (items.length > 3)
              Text(
                '... and ${items.length - 3} more items',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateOrderStatus(orderId, 'confirmed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB5C7F7),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Confirm',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _updateOrderStatus(orderId, 'shipped'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF9E79F),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Ship',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _updateOrderStatus(String orderId, String newStatus) async {
    try {
      // DISABLED - Using Spring Boot Backend
      // await FirebaseFirestore.instance
      //     .collection('orders')
      //     .doc(orderId)
      //     .update({
      //   'orderStatus': newStatus,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      
      // TODO: Implement with Spring Boot API
      print('Order status update will be implemented with Spring Boot backend');
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Order status updated to $newStatus', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFB5C7F7),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating order: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showUpdateStockDialog(BuildContext context, Map<String, dynamic> product) {
    final TextEditingController stockController = TextEditingController(
      text: product['quantity']?.toString() ?? '0',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Stock',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${product['name']}',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Text(
              'Current Stock: ${product['quantity'] ?? 0}',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'New Stock Quantity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.inventory_rounded),
              ),
            ),
          ],
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
            onPressed: () async {
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                await _updateProductStock(product['id'], newStock);
                Navigator.pop(context);
                Navigator.pop(context); // Close manage stock dialog
                _showManageStock(context); // Refresh the list
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please enter a valid stock quantity', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB5C7F7),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Update',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateProductStock(String productId, int newStock) async {
    try {
      // DISABLED - Using Spring Boot Backend
      // await FirebaseFirestore.instance
      //     .collection('products')
      //     .doc(productId)
      //     .update({
      //   'quantity': newStock,
      //   'updatedAt': FieldValue.serverTimestamp(),
      // });
      
      // TODO: Implement with Spring Boot API
      print('Stock update will be implemented with Spring Boot backend');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stock updated successfully!', style: GoogleFonts.poppins()),
          backgroundColor: const Color(0xFFB5C7F7),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating stock: $e', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showEcoProducts(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Eco Products...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFE8D5C4),
      ),
    );
  }

  void _showImpactReport(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Impact Report...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFD6EAF8),
      ),
    );
  }

  void _showImprovementTips(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening Improvement Tips...', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFF9E79F),
      ),
    );
  }

  // Store Management Methods
  void _showViewStores(BuildContext context) {
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
                    'My Stores',
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
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    _buildStoreInfoCard(),
                    const SizedBox(height: 20),
                    _buildStoreStatsCard(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showStoreAnalytics(BuildContext context) {
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
                    'Store Analytics',
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
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    // Store Performance Overview
                    Container(
                      width: double.infinity,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Store Performance',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildAnalyticsItem('Total Sales', '₹12.5K', Icons.currency_rupee_rounded, const Color(0xFFB5C7F7)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildAnalyticsItem('Orders', '18', Icons.shopping_cart_rounded, const Color(0xFFF9E79F)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildAnalyticsItem('Products', '247', Icons.inventory_rounded, const Color(0xFFD6EAF8)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildAnalyticsItem('Rating', '4.8★', Icons.star_rounded, const Color(0xFFE8D5C4)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Sustainability Impact
                    Container(
                      width: double.infinity,
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
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Sustainability Impact',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildAnalyticsItem('Carbon Saved', '2.4 kg', Icons.eco_rounded, Colors.green),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildAnalyticsItem('Eco Products', '85%', Icons.eco_rounded, const Color(0xFF4CAF50)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  // Helper methods for enhanced add store dialog
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFFB5C7F7), size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCheckbox(String title, String subtitle, bool value, IconData icon, ValueChanged<bool?> onChanged) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFFB5C7F7),
          ),
          const SizedBox(width: 12),
          Icon(icon, color: const Color(0xFFB5C7F7), size: 20),
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
        ],
      ),
    );
  }

  Widget _buildStorePreview(String name, String category, String status, String sustainabilityLevel) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFB5C7F7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.preview_rounded, color: const Color(0xFFB5C7F7), size: 20),
              const SizedBox(width: 8),
              Text(
                'Store Preview',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: const Color(0xFFB5C7F7),
                child: Text(
                  name[0].toUpperCase(),
                  style: const TextStyle(
                    color: Color(0xFF22223B),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    Text(
                      category,
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
                  color: status == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: status == 'Active' ? Colors.green : Colors.red,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.eco_rounded, color: Colors.green, size: 16),
              const SizedBox(width: 4),
              Text(
                'Sustainability: $sustainabilityLevel',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showAddStoreDialog(BuildContext context) {
    print('Shopkeeper Enhanced Add Store Dialog called!');
    
    // Controllers for form fields
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final addressController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final websiteController = TextEditingController();
    
    // Dropdown selections
    String selectedCategory = 'Food & Beverages';
    String selectedStatus = 'Active';
    String selectedOwnerType = 'Independent';
    String selectedSustainabilityLevel = 'High';
    String selectedVerificationStatus = 'Pending';
    
    // Additional settings
    bool isEcoCertified = false;
    bool hasDelivery = true;
    bool hasPickup = true;
    bool isPremium = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(Icons.add_business_rounded, color: const Color(0xFFB5C7F7), size: 28),
                const SizedBox(width: 12),
                Text('Add New Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Basic Information Section
                  _buildSectionHeader('Basic Information', Icons.store_rounded),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Store Name *',
                      border: OutlineInputBorder(),
                      hintText: 'Enter store name',
                      prefixIcon: Icon(Icons.store_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Store Description',
                      border: OutlineInputBorder(),
                      hintText: 'Describe the store and its offerings...',
                      prefixIcon: Icon(Icons.description_rounded),
                    ),
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  
                  // Category and Status Row
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category *',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.category_rounded),
                        ),
                        initialValue: selectedCategory,
                        items: const [
                          DropdownMenuItem(value: 'Food & Beverages', child: Text('Food & Beverages', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Clothing & Fashion', child: Text('Clothing & Fashion', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Electronics', child: Text('Electronics', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Home & Garden', child: Text('Home & Garden', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Personal Care', child: Text('Personal Care', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Books & Stationery', child: Text('Books & Stationery', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Sports & Fitness', child: Text('Sports & Fitness', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Automotive', child: Text('Automotive', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Health & Wellness', child: Text('Health & Wellness', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Education', child: Text('Education', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedCategory = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Status',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.info_rounded),
                        ),
                        initialValue: selectedStatus,
                        items: const [
                          DropdownMenuItem(value: 'Active', child: Text('Active', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Inactive', child: Text('Inactive', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Pending', child: Text('Pending', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Suspended', child: Text('Suspended', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedStatus = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Contact Information Section
                  _buildSectionHeader('Contact Information', Icons.contact_phone_rounded),
                  const SizedBox(height: 12),
                  
                  TextField(
                    controller: addressController,
                    decoration: const InputDecoration(
                      labelText: 'Store Address',
                      border: OutlineInputBorder(),
                      hintText: 'Enter store address',
                      prefixIcon: Icon(Icons.location_on_rounded),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(),
                            hintText: '+91 98765 43210',
                            prefixIcon: Icon(Icons.phone_rounded),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            hintText: 'store@example.com',
                            prefixIcon: Icon(Icons.email_rounded),
                          ),
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  TextField(
                    controller: websiteController,
                    decoration: const InputDecoration(
                      labelText: 'Website (Optional)',
                      border: OutlineInputBorder(),
                      hintText: 'https://www.storewebsite.com',
                      prefixIcon: Icon(Icons.language_rounded),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                  const SizedBox(height: 24),
                  
                  // Store Settings Section
                  _buildSectionHeader('Store Settings', Icons.settings_rounded),
                  const SizedBox(height: 12),
                  
                  Column(
                    children: [
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Owner Type',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                        initialValue: selectedOwnerType,
                        items: const [
                          DropdownMenuItem(value: 'Independent', child: Text('Independent Store', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Franchise', child: Text('Franchise', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Partner', child: Text('Partner Store', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedOwnerType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Sustainability Level',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.eco_rounded),
                        ),
                        initialValue: selectedSustainabilityLevel,
                        items: const [
                          DropdownMenuItem(value: 'High', child: Text('High', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Medium', child: Text('Medium', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Low', child: Text('Low', overflow: TextOverflow.ellipsis)),
                          DropdownMenuItem(value: 'Not Rated', child: Text('Not Rated', overflow: TextOverflow.ellipsis)),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedSustainabilityLevel = value!;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Verification Status',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.verified_rounded),
                    ),
                    initialValue: selectedVerificationStatus,
                    items: const [
                      DropdownMenuItem(value: 'Pending', child: Text('Pending', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Verified', child: Text('Verified', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Rejected', child: Text('Rejected', overflow: TextOverflow.ellipsis)),
                      DropdownMenuItem(value: 'Under Review', child: Text('Under Review', overflow: TextOverflow.ellipsis)),
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedVerificationStatus = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Features Section
                  _buildSectionHeader('Store Features', Icons.featured_play_list_rounded),
                  const SizedBox(height: 12),
                  
                  // Checkboxes for features
                  _buildFeatureCheckbox(
                    'Eco-Certified Store',
                    'Store has eco-friendly certification',
                    isEcoCertified,
                    Icons.eco_rounded,
                    (value) {
                      setState(() {
                        isEcoCertified = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  _buildFeatureCheckbox(
                    'Premium Store',
                    'High-end store with premium features',
                    isPremium,
                    Icons.star_rounded,
                    (value) {
                      setState(() {
                        isPremium = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  _buildFeatureCheckbox(
                    'Home Delivery',
                    'Store offers home delivery service',
                    hasDelivery,
                    Icons.delivery_dining_rounded,
                    (value) {
                      setState(() {
                        hasDelivery = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  _buildFeatureCheckbox(
                    'Pickup Available',
                    'Store offers pickup service',
                    hasPickup,
                    Icons.storefront_rounded,
                    (value) {
                      setState(() {
                        hasPickup = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  
                  // Store Preview
                  if (nameController.text.isNotEmpty)
                    _buildStorePreview(
                      nameController.text,
                      selectedCategory,
                      selectedStatus,
                      selectedSustainabilityLevel,
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Please enter a store name!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  final newStore = {
                    'name': nameController.text.trim(),
                    'category': selectedCategory,
                    'status': selectedStatus,
                    'ownerId': 'shopkeeper',
                    'ownerType': selectedOwnerType,
                    'description': descriptionController.text.trim().isNotEmpty 
                        ? descriptionController.text.trim() 
                        : 'A sustainable store offering eco-friendly products.',
                    'address': addressController.text.trim(),
                    'phone': phoneController.text.trim(),
                    'email': emailController.text.trim(),
                    'website': websiteController.text.trim(),
                    'sustainabilityLevel': selectedSustainabilityLevel,
                    'verificationStatus': selectedVerificationStatus,
                    'isEcoCertified': isEcoCertified,
                    'isPremium': isPremium,
                    'hasDelivery': hasDelivery,
                    'hasPickup': hasPickup,
                    'createdAt': DateTime.now().toIso8601String(),
                    'createdBy': 'shopkeeper',
                    'rating': 0.0,
                    'totalReviews': 0,
                    'products': 0,
                    'ordersToday': 0,
                    'revenue': 0.0,
                    'carbonSaved': 0.0,
                    'performance': 0.0,
                    'onlineUsers': 0,
                    'lastOrder': DateTime.now(),
                    'lastUpdated': DateTime.now(),
                  };

                  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                  
                  // Show loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('Adding store...', style: GoogleFonts.poppins()),
                        ],
                      ),
                      backgroundColor: Colors.blue,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                  
                  // Add store asynchronously
                  storeProvider.addStore(newStore).then((result) {
                    Navigator.pop(context);
                    
                    if (result['success']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.check_circle_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result['message'] ?? 'Store "${nameController.text.trim()}" added successfully!',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.green,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              Icon(Icons.error_rounded, color: Colors.white),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  result['message'] ?? 'Failed to add store!',
                                  style: GoogleFonts.poppins(),
                                ),
                              ),
                            ],
                          ),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 3),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }).catchError((error) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            Icon(Icons.error_rounded, color: Colors.white),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Error adding store: ${error.toString()}',
                                style: GoogleFonts.poppins(),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: Colors.red,
                        duration: const Duration(seconds: 3),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  });
                },
                icon: const Icon(Icons.add_business_rounded),
                label: Text('Add Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5C7F7),
                  foregroundColor: const Color(0xFF22223B),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStoreInfoCard() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final shopkeeperStores = storeProvider.getStoresByOwner('shopkeeper');
        
        if (shopkeeperStores.isEmpty) {
          return Container(
            width: double.infinity,
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
                  Icons.store_rounded,
                  size: 48,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No Store Found',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You haven\'t created any stores yet. Use "Add Store" to create your first store!',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        return Container(
          width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.store_rounded,
                    size: 32,
                    color: const Color(0xFFB5C7F7),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'My Stores (${shopkeeperStores.length})',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...shopkeeperStores.map((store) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFFB5C7F7),
                      child: Text(
                        (store['name'] as String?)?.isNotEmpty == true ? store['name'][0].toUpperCase() : 'S',
                        style: const TextStyle(
                          color: Color(0xFF22223B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store['name'],
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF22223B),
                            ),
                          ),
                          Text(
                            store['category'],
                            style: GoogleFonts.poppins(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            store['description'] ?? 'A sustainable store offering eco-friendly products.',
                            style: GoogleFonts.poppins(
                              color: Colors.grey[700],
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: store['status'] == 'Active' ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            store['status'],
                            style: TextStyle(
                              color: store['status'] == 'Active' ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Edit Store Button
                            GestureDetector(
                              onTap: () => _showEditStoreDialogShopkeeper(store),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFB5C7F7).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: const Color(0xFFB5C7F7),
                                  size: 16,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Delete Store Button
                            GestureDetector(
                              onTap: () => _showDeleteStoreDialogShopkeeper(store),
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  color: Colors.red,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              )),
              const SizedBox(height: 16),
            
            ],
          ),
        );
      },
    );
  }

  void _showEditStoreDialogShopkeeper(Map<String, dynamic> store) {
    final TextEditingController nameController = TextEditingController(text: store['name'] ?? '');
    final TextEditingController descriptionController = TextEditingController(text: store['description'] ?? '');
    final TextEditingController categoryController = TextEditingController(text: store['category'] ?? '');
    final TextEditingController locationController = TextEditingController(text: store['location'] ?? '');
    final TextEditingController ownerNameController = TextEditingController(text: store['ownerName'] ?? '');
    final TextEditingController ownerEmailController = TextEditingController(text: store['ownerEmail'] ?? '');
    final TextEditingController ownerPhoneController = TextEditingController(text: store['ownerPhone'] ?? '');
    final TextEditingController addressController = TextEditingController(text: store['address'] ?? '');
    
    String selectedCategory = store['category'] ?? 'Clothing';
    bool isActive = store['isActive'] ?? true;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.edit_rounded, color: const Color(0xFFB5C7F7), size: 28),
              const SizedBox(width: 12),
              Text('Edit My Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Update your store information:',
                  style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                
                // Store Name
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Store Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.store_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description
                TextField(
                  controller: descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.description_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Category Dropdown
                DropdownButtonFormField<String>(
                  initialValue: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.category_rounded),
                  ),
                  items: [
                    'Clothing',
                    'Accessories',
                    'Electronics',
                    'Personal Care',
                    'Food & Beverages',
                    'Home & Garden',
                    'Books',
                    'Sports',
                    'Beauty',
                    'Other'
                  ].map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  )).toList(),
                  onChanged: (value) {
                    setDialogState(() {
                      selectedCategory = value!;
                    });
                  },
                ),
                const SizedBox(height: 12),
                
                // Location
                TextField(
                  controller: locationController,
                  decoration: InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.location_on_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Owner Name
                TextField(
                  controller: ownerNameController,
                  decoration: InputDecoration(
                    labelText: 'Owner Name',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.person_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Owner Email
                TextField(
                  controller: ownerEmailController,
                  decoration: InputDecoration(
                    labelText: 'Owner Email',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.email_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Owner Phone
                TextField(
                  controller: ownerPhoneController,
                  decoration: InputDecoration(
                    labelText: 'Owner Phone',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.phone_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Address
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Address',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    prefixIcon: const Icon(Icons.home_rounded),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Active Status
                Row(
                  children: [
                    Icon(Icons.toggle_on_rounded, color: isActive ? Colors.green : Colors.grey),
                    const SizedBox(width: 12),
                    Text(
                      'Store Active',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Switch(
                      value: isActive,
                      onChanged: (value) {
                        setDialogState(() {
                          isActive = value;
                        });
                      },
                      activeThumbColor: const Color(0xFFB5C7F7),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: GoogleFonts.poppins()),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                  
                  final updateData = {
                    'name': nameController.text.trim(),
                    'description': descriptionController.text.trim(),
                    'category': selectedCategory,
                    'location': locationController.text.trim(),
                    'ownerName': ownerNameController.text.trim(),
                    'ownerEmail': ownerEmailController.text.trim(),
                    'ownerPhone': ownerPhoneController.text.trim(),
                    'address': addressController.text.trim(),
                    'isActive': isActive,
                    // 'updatedAt': FieldValue.serverTimestamp(), // DISABLED - Using Spring Boot Backend
                    'updatedAt': DateTime.now().toIso8601String(),
                  };
                  
                  final result = await storeProvider.updateStore(store['id'], updateData);
                  
                  Navigator.pop(context);
                  
                  if (result['success']) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Store "${store['name']}" updated successfully!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.green,
                        duration: const Duration(seconds: 3),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(result['message'] ?? 'Failed to update store!', style: GoogleFonts.poppins()),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error updating store: ${e.toString()}', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5C7F7),
                foregroundColor: Colors.white,
              ),
              child: Text('Update Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteStoreDialogShopkeeper(Map<String, dynamic> store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.delete_forever_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Text('Delete My Store', style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 20)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to permanently delete your store?',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Store: ${store['name']}',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    'Category: ${store['category']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Location: ${store['location']}',
                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '⚠️ This action cannot be undone. All store data will be permanently removed from the database.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.red[700]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final storeProvider = Provider.of<StoreProvider>(context, listen: false);
                final result = await storeProvider.deleteStore(store['id']);
                
                Navigator.pop(context);
                
                if (result['success']) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Store "${store['name']}" deleted successfully!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Failed to delete store!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting store: ${e.toString()}', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Delete Permanently', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreStatsCard() {
    return Consumer<StoreProvider>(
      builder: (context, storeProvider, child) {
        final shopkeeperStores = storeProvider.getStoresByOwner('shopkeeper');
        final store = shopkeeperStores.isNotEmpty ? shopkeeperStores.first : null;
        
        if (store == null) {
          return Container(
            width: double.infinity,
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
                Text(
                  'Store Statistics',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'No store data available',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }
        
        return Container(
          width: double.infinity,
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Store Statistics',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF22223B),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem('Products', '${store['products'] ?? 0}', Icons.inventory_rounded, const Color(0xFFB5C7F7)),
                  ),
                  Expanded(
                    child: _buildStatItem('Orders', '$_ordersToday', Icons.shopping_cart_rounded, const Color(0xFFF9E79F)),
                  ),
                  Expanded(
                    child: _buildStatItem('Revenue', '₹${((store['revenue'] ?? 0) / 1000).toStringAsFixed(1)}K', Icons.currency_rupee_rounded, const Color(0xFFD6EAF8)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStoreActionsCard(BuildContext context) {
    return Container(
      width: double.infinity,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  'Add Product',
                  Icons.add_box_rounded,
                  const Color(0xFFF9E79F),
                  () => _showAddProduct(context),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildActionButton(
                  'View Analytics',
                  Icons.analytics_rounded,
                  const Color(0xFFB5C7F7),
                  () => _showStoreAnalytics(context),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
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
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(String label, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF22223B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsItem(String label, String value, IconData icon, Color color) {
    return Column(
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
          label,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProductManagementList() {
    final shopkeeperProducts = Provider.of<ProductProvider>(context, listen: true)
        .allProducts
        .where((product) => 
            product['storeId'] == 'shopkeeper' || 
            product['storeName'] == 'My Store')
        .toList();
    
    if (shopkeeperProducts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No products yet',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first product to get started!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showAddProduct(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB5C7F7),
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Add Product',
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: shopkeeperProducts.length,
      itemBuilder: (context, index) {
        final product = shopkeeperProducts[index];
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: _parseColor(product['color']).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconFromString(product['icon']),
                      color: _parseColor(product['color']),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'],
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          product['category'],
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '₹${product['price'].toStringAsFixed(2)}',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _parseColor(product['color']),
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _showEditProduct(context, product);
                          break;
                        case 'stock':
                          _showUpdateStockDialog(context, product);
                          break;
                        case 'delete':
                          _showDeleteProductDialog(context, product);
                          break;
                        case 'toggle':
                          Provider.of<ProductProvider>(context, listen: false).toggleProductStatus(product['id']);
                          Navigator.pop(context);
                          _showManageStock(context);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: const Color(0xFFB5C7F7)),
                            const SizedBox(width: 8),
                            Text('Edit', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'stock',
                        child: Row(
                          children: [
                            Icon(Icons.inventory_rounded, color: const Color(0xFFD6EAF8)),
                            const SizedBox(width: 8),
                            Text('Update Stock', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'toggle',
                        child: Row(
                          children: [
                            Icon(
                              product['isActive'] == true ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFFF9E79F),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product['isActive'] == true ? 'Hide' : 'Show',
                              style: GoogleFonts.poppins(),
                            ),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            const SizedBox(width: 8),
                            Text('Delete', style: GoogleFonts.poppins()),
                          ],
                        ),
                      ),
                    ],
                    child: Icon(
                      Icons.more_vert,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildProductStat(
                      'Stock',
                      '${product['quantity']}',
                      Icons.inventory_rounded,
                      const Color(0xFFB5C7F7),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProductStat(
                      'Carbon',
                      '${product['carbonFootprint'] ?? 0} kg',
                      Icons.eco_rounded,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildProductStat(
                      'Status',
                      product['isActive'] == true ? 'Active' : 'Hidden',
                      Icons.circle,
                      product['isActive'] == true ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductStat(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  void _showEditProduct(BuildContext context, Map<String, dynamic> product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Edit product feature coming soon!', style: GoogleFonts.poppins()),
        backgroundColor: const Color(0xFFB5C7F7),
      ),
    );
  }

  void _showDeleteProductDialog(BuildContext context, Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Delete Product',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to PERMANENTLY delete "${product['name']}"?\n\n⚠️ This action will completely remove the product from the database and cannot be undone!',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final result = await Provider.of<ProductProvider>(context, listen: false).deleteProduct(product['id']);
                
                Navigator.pop(context); // Close dialog
                
                if (result['success']) {
                  _showManageStock(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Product deleted successfully!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(result['message'] ?? 'Failed to delete product!', style: GoogleFonts.poppins()),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } catch (e) {
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error deleting product: ${e.toString()}', style: GoogleFonts.poppins()),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete', style: GoogleFonts.poppins(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildAddProductForm() {
    // State variables - these will persist across rebuilds
    String? selectedCategory;
    String? selectedMaterial;
    Color? selectedColor;
    IconData? selectedIcon;
    
    return StatefulBuilder(
      builder: (context, setState) {
        // Initialize controllers
        final nameController = TextEditingController();
        final priceController = TextEditingController();
        final quantityController = TextEditingController();
        final descriptionController = TextEditingController();
        
        // Initialize selections only once
        selectedCategory ??= Provider.of<ProductProvider>(context, listen: false).availableCategories.first;
        selectedMaterial ??= Provider.of<ProductProvider>(context, listen: false).availableMaterials.first;
        selectedColor ??= Provider.of<ProductProvider>(context, listen: false).availableColors.first;
        selectedIcon ??= Provider.of<ProductProvider>(context, listen: false).availableIcons.first;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Product Name
            Text(
              'Product Name *',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: 'Enter product name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Category Selection
            Text(
              'Category *',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: Provider.of<ProductProvider>(context, listen: false).availableCategories.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Price and Quantity Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Price (₹) *',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0.00',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Quantity *',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: quantityController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: '0',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Material Selection
            Text(
              'Material *',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: DropdownButtonFormField<String>(
                initialValue: selectedMaterial,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
                items: Provider.of<ProductProvider>(context, listen: false).availableMaterials.map((material) {
                  return DropdownMenuItem(
                    value: material,
                    child: Text(material),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedMaterial = value!;
                  });
                },
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Description
            Text(
              'Description *',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe your eco-friendly product...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Color and Icon Selection
            StatefulBuilder(
              builder: (BuildContext context, StateSetter setAppearanceState) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Product Appearance',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // Color Selection
                    Text(
                      'Choose Color:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: Provider.of<ProductProvider>(context, listen: false).availableColors.map((color) {
                        return GestureDetector(
                          onTap: () {
                            setAppearanceState(() {
                              selectedColor = color;
                            });
                          },
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
                        );
                      }).toList(),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Icon Selection
                    Text(
                      'Choose Icon:',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 12,
                      children: Provider.of<ProductProvider>(context, listen: false).availableIcons.map((icon) {
                        return GestureDetector(
                          onTap: () {
                            setAppearanceState(() {
                              selectedIcon = icon;
                            });
                          },
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: selectedIcon == icon ? (selectedColor?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.2)) : Colors.grey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: selectedIcon == icon ? (selectedColor ?? Colors.blue) : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              icon,
                              color: selectedIcon == icon ? selectedColor : Colors.grey,
                              size: 24,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 30),
            
            // Add Product Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (nameController.text.isNotEmpty &&
                      priceController.text.isNotEmpty &&
                      quantityController.text.isNotEmpty &&
                      descriptionController.text.isNotEmpty) {
                    
                    // Convert Color to hex string and IconData to string
                    String colorHex = '#${(selectedColor?.value ?? Colors.blue.value).toRadixString(16).padLeft(8, '0')}';
                    String iconString = _getIconString(selectedIcon!);
                    
                    final newProduct = {
                      'name': nameController.text,
                      'category': selectedCategory,
                      'price': double.tryParse(priceController.text) ?? 0.0,
                      'quantity': int.tryParse(quantityController.text) ?? 0,
                      'material': selectedMaterial,
                      'description': descriptionController.text,
                      'color': colorHex,
                      'icon': iconString,
                      'storeId': 'shopkeeper',
                      'storeName': 'My Store',
                    };
                    
                    // Show loading indicator
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFB5C7F7)),
                          ),
                        );
                      },
                    );

                    try {
                      final result = await Provider.of<ProductProvider>(context, listen: false).addProduct(newProduct);
                      
                      // Hide loading indicator
                      Navigator.pop(context);
                      
                      if (result['success']) {
                        Navigator.pop(context); // Close the add product dialog
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Product "${nameController.text}" added successfully!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              result['message'] ?? 'Failed to add product!',
                              style: GoogleFonts.poppins(),
                            ),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    } catch (e) {
                      // Hide loading indicator
                      Navigator.pop(context);
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Error adding product: ${e.toString()}',
                            style: GoogleFonts.poppins(),
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please fill all required fields!',
                          style: GoogleFonts.poppins(),
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5C7F7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Add Product',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }
}

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
    };
    
    return iconMap[iconString] ?? Icons.shopping_bag_rounded;
  }

  // Helper method to convert IconData to string
  String _getIconString(IconData icon) {
    // Map of IconData to string
    final iconMap = {
      Icons.checkroom_rounded: 'checkroom_rounded',
      Icons.water_drop_rounded: 'water_drop_rounded',
      Icons.solar_power_rounded: 'solar_power_rounded',
      Icons.shopping_bag_rounded: 'shopping_bag_rounded',
      Icons.brush_rounded: 'brush_rounded',
      Icons.spa_rounded: 'spa_rounded',
      Icons.book_rounded: 'book_rounded',
      Icons.face_rounded: 'face_rounded',
      Icons.fitness_center_rounded: 'fitness_center_rounded',
      Icons.local_florist_rounded: 'local_florist_rounded',
      Icons.local_cafe_rounded: 'local_cafe_rounded',
    };
    
    return iconMap[icon] ?? 'shopping_bag_rounded';
  }

// Widget classes moved outside the main state class
class _PastelStatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;
  final IconData icon;

  const _PastelStatCard({
    required this.title,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: const Color(0xFF22223B), size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 18,
                color: const Color(0xFF22223B),
              ),
            ),
          ],
        ),
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
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

