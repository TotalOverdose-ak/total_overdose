import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/local_eco_discounts_service.dart';

class AdminEcoDiscountsScreen extends StatefulWidget {
  const AdminEcoDiscountsScreen({super.key});

  @override
  State<AdminEcoDiscountsScreen> createState() => _AdminEcoDiscountsScreenState();
}

class _AdminEcoDiscountsScreenState extends State<AdminEcoDiscountsScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late TabController _tabController;
  
  List<dynamic> _allDiscounts = [];
  Map<String, dynamic> _discountStats = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _tabController = TabController(length: 2, vsync: this);
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
      final discounts = await LocalEcoDiscountsService.getAllDiscounts();
      final stats = await LocalEcoDiscountsService.getDiscountStatistics();
      
      setState(() {
        _allDiscounts = discounts;
        _discountStats = stats;
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
        backgroundColor: const Color(0xFFF7F6F2),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Eco Discounts Management',
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
                              'Discount Management',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF22223B),
                              ),
                            ),
                            Text(
                              'Manage eco rewards and discounts',
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
                            color: const Color(0xFFFFB6C1).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFFB6C1).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                (_discountStats['totalDiscounts'] ?? 0).toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFB6C1),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Total',
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
                            color: const Color(0xFF8BC34A).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8BC34A).withOpacity(0.3),
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                (_discountStats['activeDiscounts'] ?? 0).toString(),
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF8BC34A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Active',
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
                                (_discountStats['totalUsage'] ?? 0).toString(),
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
                  Tab(text: 'All Discounts'),
                  Tab(text: 'Analytics'),
                ],
              ),
            ),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildDiscountsTab(),
                  _buildAnalyticsTab(),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDiscountDialog(),
        backgroundColor: const Color(0xFFFFB6C1),
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'New Discount',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDiscountsTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _allDiscounts.length,
      itemBuilder: (context, index) {
        final discount = _allDiscounts[index];
        return _buildDiscountCard(discount);
      },
    );
  }

  Widget _buildDiscountCard(Map<String, dynamic> discount) {
    final bool isActive = discount['isActive'] ?? false;
    final DateTime validUntil = DateTime.fromMillisecondsSinceEpoch(discount['validUntil']);
    final bool isExpired = DateTime.now().isAfter(validUntil);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isActive && !isExpired 
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
          // Header Row
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isActive && !isExpired
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
                        color: isActive && !isExpired
                          ? const Color(0xFF8BC34A).withOpacity(0.2)
                          : Colors.grey.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        isExpired ? 'EXPIRED' : (isActive ? 'ACTIVE' : 'INACTIVE'),
                        style: GoogleFonts.poppins(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: isExpired ? Colors.red : (isActive ? const Color(0xFF8BC34A) : Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) => _handleDiscountAction(value, discount),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 8),
                        Text('Edit'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'toggle',
                    child: Row(
                      children: [
                        Icon(Icons.visibility, size: 20),
                        SizedBox(width: 8),
                        Text('Toggle Status'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
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
          
          // Discount Info
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
                        '${discount['usedCount']}/${discount['usageLimit']}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFF9E79F),
                        ),
                      ),
                      Text(
                        'Used',
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
        ],
      ),
    );
  }

  Widget _buildAnalyticsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discount Analytics',
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
                Icon(Icons.analytics_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Discount Analytics Dashboard',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Detailed usage analytics and performance metrics will be displayed here',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreateDiscountDialog() {
    showDialog(
      context: context,
      builder: (context) => const CreateDiscountDialog(),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  void _handleDiscountAction(String action, Map<String, dynamic> discount) {
    switch (action) {
      case 'edit':
        _editDiscount(discount);
        break;
      case 'toggle':
        _toggleDiscountStatus(discount);
        break;
      case 'delete':
        _deleteDiscount(discount);
        break;
    }
  }

  void _editDiscount(Map<String, dynamic> discount) {
    showDialog(
      context: context,
      builder: (context) => EditDiscountDialog(discount: discount),
    ).then((result) {
      if (result == true) {
        _loadData();
      }
    });
  }

  Future<void> _toggleDiscountStatus(Map<String, dynamic> discount) async {
    try {
      await LocalEcoDiscountsService.toggleDiscountStatus(discount['id'].toString());
      _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Discount ${discount['isActive'] ? 'deactivated' : 'activated'} successfully!'),
          backgroundColor: const Color(0xFF8BC34A),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating discount: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteDiscount(Map<String, dynamic> discount) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Discount',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to delete "${discount['title']}"? This action cannot be undone.',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await LocalEcoDiscountsService.deleteDiscount(discount['id'].toString());
        _loadData();
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discount deleted successfully!'),
            backgroundColor: Color(0xFF8BC34A),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting discount: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class CreateDiscountDialog extends StatefulWidget {
  const CreateDiscountDialog({super.key});

  @override
  State<CreateDiscountDialog> createState() => _CreateDiscountDialogState();
}

class _CreateDiscountDialogState extends State<CreateDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountValueController = TextEditingController();
  final _minPointsController = TextEditingController();
  final _minOrderController = TextEditingController();
  final _maxDiscountController = TextEditingController();
  final _usageLimitController = TextEditingController();
  final _validDaysController = TextEditingController();
  
  String _discountType = 'percentage';
  List<String> _selectedCategories = ['All'];
  bool _isLoading = false;

  final List<String> _categories = [
    'All',
    'Eco-Friendly',
    'Sustainable',
    'Green Living',
    'Organic',
    'Recyclable',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minPointsController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    _validDaysController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
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
                      child: const Icon(
                        Icons.local_offer,
                        color: Color(0xFFFFB6C1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Create New Discount',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Discount Title',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Discount Type and Value
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                initialValue: _discountType,
                                decoration: InputDecoration(
                                  labelText: 'Discount Type',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.percent),
                                ),
                                items: const [
                                  DropdownMenuItem(value: 'percentage', child: Text('Percentage')),
                                  DropdownMenuItem(value: 'fixed', child: Text('Fixed Amount')),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _discountType = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _discountValueController,
                                decoration: InputDecoration(
                                  labelText: _discountType == 'percentage' ? 'Percentage (%)' : 'Amount (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: Icon(_discountType == 'percentage' ? Icons.percent : Icons.currency_rupee),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Min Points and Min Order
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minPointsController,
                                decoration: InputDecoration(
                                  labelText: 'Min Eco Points',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.eco),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _minOrderController,
                                decoration: InputDecoration(
                                  labelText: 'Min Order Amount (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.shopping_cart),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Max Discount and Usage Limit
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _maxDiscountController,
                                decoration: InputDecoration(
                                  labelText: 'Max Discount (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.money_off),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _usageLimitController,
                                decoration: InputDecoration(
                                  labelText: 'Usage Limit',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.people),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Valid Days
                        TextFormField(
                          controller: _validDaysController,
                          decoration: InputDecoration(
                            labelText: 'Valid for (days)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.calendar_today),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter validity period';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _createDiscount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB6C1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Create Discount',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Future<void> _createDiscount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final validDays = int.parse(_validDaysController.text);
      
      final discountData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'discountType': _discountType,
        'discountValue': double.parse(_discountValueController.text),
        'minEcoPoints': int.parse(_minPointsController.text),
        'minOrderAmount': double.parse(_minOrderController.text),
        'maxDiscountAmount': double.parse(_maxDiscountController.text),
        'usageLimit': int.parse(_usageLimitController.text),
        'validFrom': now.millisecondsSinceEpoch,
        'validUntil': now.add(Duration(days: validDays)).millisecondsSinceEpoch,
        'isActive': true,
        'applicableCategories': _selectedCategories,
      };

      final success = await LocalEcoDiscountsService.createDiscount(discountData);
      
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discount created successfully!'),
            backgroundColor: Color(0xFF8BC34A),
          ),
        );
      } else {
        throw Exception('Failed to create discount');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating discount: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

class EditDiscountDialog extends StatefulWidget {
  final Map<String, dynamic> discount;
  
  const EditDiscountDialog({super.key, required this.discount});

  @override
  State<EditDiscountDialog> createState() => _EditDiscountDialogState();
}

class _EditDiscountDialogState extends State<EditDiscountDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountValueController;
  late TextEditingController _minPointsController;
  late TextEditingController _minOrderController;
  late TextEditingController _maxDiscountController;
  late TextEditingController _usageLimitController;
  
  late String _discountType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    
    _titleController = TextEditingController(text: widget.discount['title'] ?? '');
    _descriptionController = TextEditingController(text: widget.discount['description'] ?? '');
    _discountValueController = TextEditingController(text: widget.discount['discountValue']?.toString() ?? '');
    _minPointsController = TextEditingController(text: widget.discount['minEcoPoints']?.toString() ?? '');
    _minOrderController = TextEditingController(text: widget.discount['minOrderAmount']?.toString() ?? '');
    _maxDiscountController = TextEditingController(text: widget.discount['maxDiscountAmount']?.toString() ?? '');
    _usageLimitController = TextEditingController(text: widget.discount['usageLimit']?.toString() ?? '');
    
    _discountType = widget.discount['discountType'] ?? 'percentage';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountValueController.dispose();
    _minPointsController.dispose();
    _minOrderController.dispose();
    _maxDiscountController.dispose();
    _usageLimitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        child: Container(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
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
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFFFFB6C1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Edit Discount',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Form Fields
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Title
                        TextFormField(
                          controller: _titleController,
                          decoration: InputDecoration(
                            labelText: 'Discount Title',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.title),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a title';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: const Icon(Icons.description),
                          ),
                          maxLines: 2,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a description';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Discount Value
                        TextFormField(
                          controller: _discountValueController,
                          decoration: InputDecoration(
                            labelText: _discountType == 'percentage' ? 'Percentage (%)' : 'Amount (₹)',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            prefixIcon: Icon(_discountType == 'percentage' ? Icons.percent : Icons.currency_rupee),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        
                        // Min Points and Min Order
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _minPointsController,
                                decoration: InputDecoration(
                                  labelText: 'Min Eco Points',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.eco),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _minOrderController,
                                decoration: InputDecoration(
                                  labelText: 'Min Order (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.shopping_cart),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        // Max Discount and Usage Limit
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _maxDiscountController,
                                decoration: InputDecoration(
                                  labelText: 'Max Discount (₹)',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.money_off),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _usageLimitController,
                                decoration: InputDecoration(
                                  labelText: 'Usage Limit',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                                  prefixIcon: const Icon(Icons.people),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (int.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateDiscount,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFB6C1),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Update Discount',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
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
      ),
    );
  }

  Future<void> _updateDiscount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final discountData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'discountValue': double.parse(_discountValueController.text),
        'minEcoPoints': int.parse(_minPointsController.text),
        'minOrderAmount': double.parse(_minOrderController.text),
        'maxDiscountAmount': double.parse(_maxDiscountController.text),
        'usageLimit': int.parse(_usageLimitController.text),
      };

      final success = await LocalEcoDiscountsService.updateDiscount(
        widget.discount['id'].toString(),
        discountData,
      );
      
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Discount updated successfully!'),
            backgroundColor: Color(0xFF8BC34A),
          ),
        );
      } else {
        throw Exception('Failed to update discount');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating discount: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}