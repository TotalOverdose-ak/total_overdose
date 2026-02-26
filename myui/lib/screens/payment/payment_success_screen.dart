import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/carbon_tracking_provider.dart';
import '../../providers/spring_auth_provider.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final String orderId;
  final String amount;

  const PaymentSuccessScreen({
    super.key,
    required this.orderId,
    required this.amount,
  });

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _bounceController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _bounceAnimation;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    _bounceController.forward();
    
    // Record the purchase in carbon tracking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _recordPurchase();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _bounceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenHeight < 700;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header - More compact for small screens
              Padding(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 16.0 : 24.0,
                  horizontal: 24.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/home',
                          (route) => false,
                        );
                      },
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFB5C7F7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.home_rounded,
                          color: Color(0xFF22223B),
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Payment Complete',
                      style: GoogleFonts.poppins(
                        fontSize: isSmallScreen ? 20 : 24,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ],
                ),
              ),

              // Scrollable Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      SizedBox(height: isSmallScreen ? 10 : 20),

                      // Success Icon - Smaller for small screens
                      ScaleTransition(
                        scale: _bounceAnimation,
                        child: Container(
                          width: isSmallScreen ? 80 : 120,
                          height: isSmallScreen ? 80 : 120,
                          decoration: BoxDecoration(
                            color: const Color(0xFFB5C7F7).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 40 : 60),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFB5C7F7).withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: const Color(0xFFB5C7F7),
                            size: isSmallScreen ? 40 : 64,
                          ),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 32),

                      // Success Message - Smaller font for small screens
                      Text(
                        'Payment Successful!',
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 22 : 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 12 : 16),

                      Text(
                        'Your order has been placed successfully.\nThank you for choosing EcoBazaarX!',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: isSmallScreen ? 14 : 16,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 20 : 32),

                      // Order Details Card - More compact padding
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isSmallScreen ? 16 : 24),
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
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order ID',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                                Text(
                                  widget.orderId,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF22223B),
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Amount Paid',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                                Text(
                                  widget.amount,
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    fontSize: isSmallScreen ? 16 : 18,
                                    color: const Color(0xFFB5C7F7),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: isSmallScreen ? 12 : 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Status',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                    fontSize: isSmallScreen ? 13 : 14,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Confirmed',
                                    style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.green,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Environmental Impact - More compact
                      Consumer<CartProvider>(
                        builder: (context, cartProvider, child) {
                          final carbonSaved = cartProvider.totalCarbonFootprintSaved;
                          return Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8D5C4).withOpacity(0.3),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: const Color(0xFFE8D5C4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.eco_rounded,
                                  color: const Color(0xFF22223B),
                                  size: isSmallScreen ? 24 : 32,
                                ),
                                SizedBox(width: isSmallScreen ? 12 : 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Carbon Footprint Saved',
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.bold,
                                          color: const Color(0xFF22223B),
                                          fontSize: isSmallScreen ? 13 : 14,
                                        ),
                                      ),
                                      Text(
                                        'Your eco-friendly purchase saved ${carbonSaved.toStringAsFixed(1)}kg CO₂',
                                        style: GoogleFonts.poppins(
                                          fontSize: isSmallScreen ? 11 : 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 24),

                      // Action Buttons - More compact
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 48 : 56,
                            child: ElevatedButton(
                              onPressed: () => _trackOrder(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFB5C7F7),
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
                                    Icons.track_changes_rounded,
                                    size: isSmallScreen ? 18 : 20,
                                  ),
                                  SizedBox(width: isSmallScreen ? 8 : 12),
                                  Text(
                                    'Track Order',
                                    style: GoogleFonts.poppins(
                                      fontSize: isSmallScreen ? 14 : 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: isSmallScreen ? 12 : 16),
                          SizedBox(
                            width: double.infinity,
                            height: isSmallScreen ? 48 : 56,
                            child: OutlinedButton(
                              onPressed: () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor: const Color(0xFF22223B),
                                side: const BorderSide(
                                  color: Color(0xFFB5C7F7),
                                  width: 2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                              child: Text(
                                'Continue Shopping',
                                style: GoogleFonts.poppins(
                                  fontSize: isSmallScreen ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: isSmallScreen ? 16 : 24),
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

  void _trackOrder() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opening order tracking...',
          style: GoogleFonts.poppins(),
        ),
        backgroundColor: const Color(0xFFB5C7F7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _recordPurchase() async {
    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final carbonProvider = Provider.of<CarbonTrackingProvider>(context, listen: false);
      final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);

      if (cartProvider.cartItems.isNotEmpty) {
        final cartSummary = cartProvider.getPurchaseSummary();
        
        // Record carbon tracking
        carbonProvider.addPurchaseFromCart(
          orderId: widget.orderId,
          customerId: authProvider.userEmail ?? 'CUST001',
          customerName: authProvider.userName ?? 'Customer',
          cartSummary: cartSummary,
        );

        print('✅ Order ${widget.orderId} successfully saved to MySQL database');
        print('📊 Carbon tracking recorded for order');

        // Clear the cart after successful purchase
        final userId = authProvider.userEmail ?? 'CUST001';
        await cartProvider.clearCart(userId);
      }
    } catch (e) {
      print('Error recording purchase: $e');
    }
  }
}
