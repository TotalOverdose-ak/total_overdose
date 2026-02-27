import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/local_eco_discounts_service.dart';
import '../services/local_eco_challenges_service.dart';

class UserEcoDiscountsScreen extends StatefulWidget {
  final String userId;
  
  const UserEcoDiscountsScreen({super.key, required this.userId});

  @override
  State<UserEcoDiscountsScreen> createState() => _UserEcoDiscountsScreenState();
}

class _UserEcoDiscountsScreenState extends State<UserEcoDiscountsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late TabController _tabController;
  
  List<Map<String, dynamic>> _availableDiscounts = [];
  List<Map<String, dynamic>> _eligibleDiscounts = [];
  List<Map<String, dynamic>> _usedDiscounts = [];
  int _userEcoPoints = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 3, vsync: this);
    _loadData();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Get user's eco points
      _userEcoPoints = await LocalEcoChallengesService.getTotalPointsEarned(widget.userId);
      
      // Get all active discounts
      final activeDiscounts = await LocalEcoDiscountsService.getActiveDiscounts();
      
      // Get eligible discounts for user (assuming minimum order of 500 for demo)
      final eligibleDiscounts = await LocalEcoDiscountsService.getEligibleDiscounts(
        widget.userId, 
        _userEcoPoints, 
        500.0
      );
      
      // Get user's discount usage history
      final discountHistory = await LocalEcoDiscountsService.getUserDiscountHistory(widget.userId);
      
      setState(() {
        _availableDiscounts = activeDiscounts;
        _eligibleDiscounts = eligibleDiscounts;
        _usedDiscounts = discountHistory;
      });
    } catch (e) {
      print('Error loading discount data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F6F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Eco Discounts',
          style: GoogleFonts.poppins(
            color: const Color(0xFF22223B),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF22223B)),
            onPressed: _loadData,
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeController,
        child: Column(
          children: [
            // Stats Header - Shopping Cart Style
            Container(
              margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD6EAF8).withOpacity(0.12),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFB6C1).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.local_offer_rounded,
                          color: Color(0xFFFFB6C1),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Eco Rewards',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF22223B),
                              ),
                            ),
                            Text(
                              'Redeem points for exclusive discounts',
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
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8BC34A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8BC34A).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _userEcoPoints.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8BC34A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Eco Points',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB6C1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFB6C1).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _eligibleDiscounts.length.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFB6C1),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Available',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9E79F).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFF9E79F).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                _usedDiscounts.length.toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFF9E79F),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Used',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  color: const Color(0xFF22223B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Tab Bar - Shopping Cart Style
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFD6EAF8).withOpacity(0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF22223B),
                unselectedLabelColor: Colors.grey[500],
                labelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                indicator: BoxDecoration(
                  color: const Color(0xFFFFB6C1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: 'Available'),
                  Tab(text: 'Eligible'),
                  Tab(text: 'Used'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildAvailableTab(),
                  _buildEligibleTab(),
                  _buildUsedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _availableDiscounts.length,
      itemBuilder: (context, index) {
        final discount = _availableDiscounts[index];
        return _buildDiscountCard(discount, false);
      },
    );
  }

  Widget _buildEligibleTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_eligibleDiscounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.card_giftcard, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Eligible Discounts',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Complete more eco challenges to unlock discounts!',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _eligibleDiscounts.length,
      itemBuilder: (context, index) {
        final discount = _eligibleDiscounts[index];
        return _buildDiscountCard(discount, true);
      },
    );
  }

  Widget _buildUsedTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_usedDiscounts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No Used Discounts',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your discount usage history will appear here',
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _usedDiscounts.length,
      itemBuilder: (context, index) {
        final usedDiscount = _usedDiscounts[index];
        return _buildUsedDiscountCard(usedDiscount);
      },
    );
  }

  Widget _buildDiscountCard(Map<String, dynamic> discount, bool isEligible) {
    final DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(discount['validUntil']);
    final bool isExpired = DateTime.now().isAfter(validUntil);
    final int remainingUses = (discount['usageLimit'] ?? 0) - (discount['usedCount'] ?? 0);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isEligible && !isExpired 
            ? const Color(0xFF8BC34A).withOpacity(0.3) 
            : Colors.grey.withOpacity(0.3),
        ),
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
          // Header Row - Cart Item Style
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isEligible && !isExpired
                      ? [const Color(0xFFFFB6C1), const Color(0xFFFFD6E7)]
                      : [Colors.grey[400]!, Colors.grey[300]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  discount['discountType'] == 'percentage' 
                    ? Icons.percent 
                    : Icons.money_off,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      discount['title'] ?? 'Unknown Discount',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: isEligible && !isExpired
                          ? const Color(0xFF8BC34A).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isExpired ? 'EXPIRED' : (isEligible ? 'ELIGIBLE' : 'LOCKED'),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.red : (isEligible ? const Color(0xFF8BC34A) : Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Description
          Text(
            discount['description'] ?? 'No description available',
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          
          // Discount Info - Cart Price Style
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F6F2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        discount['discountType'] == 'percentage' 
                          ? '${discount['discountValue']}%' 
                          : '₹${discount['discountValue']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFB6C1),
                        ),
                      ),
                      Text(
                        'Discount',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${discount['minEcoPoints'] ?? 0}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8BC34A),
                        ),
                      ),
                      Text(
                        'Min Points',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(width: 1, height: 30, color: Colors.grey[300]),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        remainingUses.toString(),
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF9E79F),
                        ),
                      ),
                      Text(
                        'Left',
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          if (isEligible && !isExpired) ...[
            const SizedBox(height: 12),
            // Use Button - Cart Add to Cart Style
            Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB6C1), Color(0xFFFFD6E7)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFFB6C1).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => _showDiscountDetails(discount),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(Icons.local_offer, color: Colors.white, size: 20),
                label: Text(
                  'View Details',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildUsedDiscountCard(Map<String, dynamic> usedDiscount) {
    final DateTime usedAt = DateTime.fromMillisecondsSinceEpoch(usedDiscount['usedAt']);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Discount Used',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF22223B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Used on ${_formatDate(usedAt)}',
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
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'USED',
              style: GoogleFonts.poppins(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDiscountDetails(Map<String, dynamic> discount) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFB6C1).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    discount['discountType'] == 'percentage' 
                      ? Icons.percent 
                      : Icons.money_off,
                    color: const Color(0xFFFFB6C1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        discount['title'] ?? 'Discount Details',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF22223B),
                        ),
                      ),
                      Text(
                        discount['description'] ?? '',
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
            const SizedBox(height: 20),
            
            // Terms
            Text(
              'Terms & Conditions:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• Minimum order amount: ₹${discount['minOrderAmount'] ?? 0}\n'
              '• Required eco points: ${discount['minEcoPoints'] ?? 0}\n'
              '• Maximum discount: ₹${discount['maxDiscountAmount'] ?? 0}\n'
              '• Valid until: ${_formatDate(DateTime.fromMillisecondsSinceEpoch(discount['validUntil']))}\n'
              '• Can be used once per user',
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB6C1),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Got it!',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}