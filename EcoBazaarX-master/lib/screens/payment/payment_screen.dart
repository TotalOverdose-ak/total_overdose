import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/payment_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/spring_auth_provider.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  String _selectedPaymentMethod = 'card';
  bool _saveCard = false;
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _pincodeController = TextEditingController();

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
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
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
                        const SizedBox(width: 16),
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9E79F),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFF9E79F).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.payment_rounded,
                            size: 30,
                            color: Color(0xFF22223B),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Payment Platform\nSecure & Fast',
                                style: GoogleFonts.poppins(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF22223B),
                                  height: 1.2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Order Summary
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      'Order Summary',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Order Details Card
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
                                'Eco Shopping Cart',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Icon(
                                Icons.shopping_cart_rounded,
                                color: const Color(0xFFB5C7F7),
                                size: 24,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildOrderItem('Organic Cotton T-Shirt', '1x', '₹899'),
                          _buildOrderItem('Bamboo Water Bottle', '2x', '₹1,198'),
                          _buildOrderItem('Reusable Shopping Bag', '1x', '₹299'),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Subtotal',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                '₹2,396',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Eco Discount (10%)',
                                style: GoogleFonts.poppins(
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                '-₹240',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Delivery',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                ),
                              ),
                              Text(
                                'Free',
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '₹2,156',
                                style: GoogleFonts.poppins(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFB5C7F7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Payment Methods
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      'Payment Methods',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Payment Method Options
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        _buildPaymentMethodCard(
                          'Credit/Debit Card',
                          Icons.credit_card_rounded,
                          const Color(0xFFB5C7F7),
                          'card',
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard(
                          'UPI Payment',
                          Icons.qr_code_rounded,
                          const Color(0xFFF9E79F),
                          'upi',
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard(
                          'Net Banking',
                          Icons.account_balance_rounded,
                          const Color(0xFFD6EAF8),
                          'netbanking',
                        ),
                        const SizedBox(height: 12),
                        _buildPaymentMethodCard(
                          'Digital Wallet',
                          Icons.wallet_rounded,
                          const Color(0xFFE8D5C4),
                          'wallet',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Card Details (if card is selected)
                  if (_selectedPaymentMethod == 'card') ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18.0),
                      child: Text(
                        'Card Details',
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
                      child: Container(
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
                          children: [
                            _buildCardField(
                              'Card Number',
                              '1234 5678 9012 3456',
                              Icons.credit_card_rounded,
                              _cardNumberController,
                            ),
                            const SizedBox(height: 16),
                            _buildCardField(
                              'Cardholder Name',
                              'John Doe',
                              Icons.person_rounded,
                              _nameController,
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildCardField(
                                    'Expiry',
                                    'MM/YY',
                                    Icons.calendar_today_rounded,
                                    _expiryController,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildCardField(
                                    'CVV',
                                    '123',
                                    Icons.lock_rounded,
                                    _cvvController,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Checkbox(
                                  value: _saveCard,
                                  onChanged: (value) {
                                    setState(() {
                                      _saveCard = value ?? false;
                                    });
                                  },
                                  activeColor: const Color(0xFFB5C7F7),
                                ),
                                Text(
                                  'Save card for future payments',
                                  style: GoogleFonts.poppins(
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],

                  // Security Features
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(20),
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
                            Icons.security_rounded,
                            color: const Color(0xFF22223B),
                            size: 28,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Secure Payment',
                                  style: GoogleFonts.poppins(
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF22223B),
                                  ),
                                ),
                                Text(
                                  'Your payment information is encrypted and secure',
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
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Shipping Address Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18.0),
                    child: Text(
                      'Shipping Address',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Address Form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Container(
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
                        children: [
                          _buildAddressField(
                            'Full Address',
                            'Enter your complete address',
                            Icons.location_on_rounded,
                            _addressController,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: _buildAddressField(
                                  'City',
                                  'Enter city',
                                  Icons.location_city_rounded,
                                  _cityController,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildAddressField(
                                  'Pincode',
                                  '000000',
                                  Icons.pin_drop_rounded,
                                  _pincodeController,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Pay Now Button
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      height: 64,
                      child: ElevatedButton(
                        onPressed: () => _processPayment(),
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
                              Icons.lock_rounded,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Pay ₹2,156 Securely',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(String name, String quantity, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '$name ($quantity)',
              style: GoogleFonts.poppins(
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            price,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    IconData icon,
    Color color,
    String value,
  ) {
    bool isSelected = _selectedPaymentMethod == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPaymentMethod = value;
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? color : Colors.grey.withOpacity(0.2),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF22223B),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF22223B),
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: color,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF22223B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFFB5C7F7)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFB5C7F7)),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F6F2),
          ),
          style: GoogleFonts.poppins(),
        ),
      ],
    );
  }

  Widget _buildAddressField(
    String label,
    String hint,
    IconData icon,
    TextEditingController controller,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: const Color(0xFF22223B),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF4CAF50)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFF4CAF50)),
            ),
            filled: true,
            fillColor: const Color(0xFFF7F6F2),
          ),
          style: GoogleFonts.poppins(),
          maxLines: label == 'Full Address' ? 3 : 1,
        ),
      ],
    );
  }

  void _processPayment() async {
    // Show loading dialog first
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(
              color: Color(0xFFB5C7F7),
            ),
            const SizedBox(height: 20),
            Text(
              'Processing Payment...',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF22223B),
              ),
            ),
          ],
        ),
      ),
    );

    try {
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
      
      // Get cart items
      final cartItems = cartProvider.cartItems.map((item) => {
        'productId': item['productId'],
        'productName': item['name'],
        'quantity': item['quantity'],
        'price': item['price'],
        'totalPrice': item['price'] * item['quantity'],
        'category': item['category'] ?? 'Other',
        'carbonFootprint': item['carbonFootprint'] ?? 0.0,
        'ecoPoints': 10, // Default eco points per item
      }).toList();

      // Calculate amounts
      final totalAmount = cartProvider.totalAmount;
      final taxAmount = totalAmount * 0.18; // 18% GST
      final shippingAmount = totalAmount > 1000 ? 0.0 : 100.0; // Free shipping above ₹1000
      final discountAmount = totalAmount * 0.10; // 10% discount
      final finalAmount = totalAmount + taxAmount + shippingAmount - discountAmount;

      // Create shipping and billing address (using user input)
      final shippingAddress = {
        'fullName': authProvider.userName ?? 'Customer',
        'phone': '+91-9876543210',
        'address': _addressController.text.isNotEmpty ? _addressController.text : '123 Main Street',
        'city': _cityController.text.isNotEmpty ? _cityController.text : 'Mumbai',
        'state': 'Maharashtra',
        'pincode': _pincodeController.text.isNotEmpty ? _pincodeController.text : '400001',
        'landmark': 'Near Station',
      };

      final billingAddress = {
        'fullName': authProvider.userName ?? 'Customer',
        'phone': '+91-9876543210',
        'address': _addressController.text.isNotEmpty ? _addressController.text : '123 Main Street',
        'city': _cityController.text.isNotEmpty ? _cityController.text : 'Mumbai',
        'state': 'Maharashtra',
        'pincode': _pincodeController.text.isNotEmpty ? _pincodeController.text : '400001',
      };

      // Create order in Firestore
      final orderResult = await PaymentService.createOrder(
        userId: authProvider.isAuthenticated ? authProvider.userId! : 'user123',
        userEmail: authProvider.userEmail ?? 'customer@example.com',
        userName: authProvider.userName ?? 'Customer',
        userPhone: '+91-0000000000', // Default phone number
        cartItems: cartItems,
        shippingAddress: shippingAddress,
        billingAddress: billingAddress,
        totalAmount: totalAmount,
        taxAmount: taxAmount,
        shippingAmount: shippingAmount,
        discountAmount: discountAmount,
        finalAmount: finalAmount,
        paymentMethod: _selectedPaymentMethod,
        deliveryNotes: 'Please deliver in the evening',
      );

      if (!orderResult['success']) {
        Navigator.pop(context); // Close loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(orderResult['message'], style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final orderId = orderResult['orderId'];

      // Simulate Razorpay payment
      final paymentResult = await PaymentService.simulateRazorpayPayment(
        amount: finalAmount,
        currency: 'INR',
        orderId: orderId,
      );

      // Process payment in Firestore
      final processResult = await PaymentService.processPayment(
        orderId: orderId,
        userId: authProvider.isAuthenticated ? authProvider.userId! : 'user123',
        paymentMethod: _selectedPaymentMethod,
        paymentGateway: 'razorpay',
        amount: finalAmount,
        gatewayResponse: paymentResult,
        failureReason: paymentResult['success'] ? null : paymentResult['failureReason'],
      );

      Navigator.pop(context); // Close loading dialog

      if (processResult['success']) {
        // Clear cart after successful payment
        final userId = authProvider.isAuthenticated ? authProvider.userId! : 'user123';
        await cartProvider.clearCart(userId);
        
        // Navigate to success screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentSuccessScreen(
              orderId: orderId,
              amount: '₹${finalAmount.toStringAsFixed(0)}',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(processResult['message'], style: GoogleFonts.poppins()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: ${e.toString()}', style: GoogleFonts.poppins()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
