import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/store_provider.dart';
import '../screens/auth/login_screen.dart';

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _initialized = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    if (_initialized) return;
    
    try {
      print('AppInitializer: Starting app initialization...');
      
      // Use post-frame callback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // Get providers without triggering rebuilds
        final productProvider = context.read<ProductProvider>();
        final storeProvider = context.read<StoreProvider>();
        
        // Initialize providers that don't require authentication
        print('AppInitializer: Initializing ProductProvider...');
        await productProvider.initializeProducts();
        
        print('AppInitializer: Initializing StoreProvider...');
        await storeProvider.initializeStores();
        
        print('AppInitializer: App initialization completed successfully');
        
        if (mounted) {
          _initialized = true;
          setState(() {
            _isLoading = false;
          });
        }
      });
    } catch (error) {
      print('AppInitializer: Error during initialization: $error');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8FAFF),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EcoBazaarX',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2196F3),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Initializing app...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
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
    
    // Once initialized, show the login screen
    return const LoginScreen();
  }
}
