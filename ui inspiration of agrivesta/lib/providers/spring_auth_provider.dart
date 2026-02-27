import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

enum UserRole { customer, shopkeeper, admin }

class SpringAuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _userEmail;
  String? _userName;
  UserRole? _userRole;
  String? _userId;
  String? _jwtToken;
  String? _refreshToken;

  // Static list to store all registered users (accessible by admin)
  // This will be populated from MySQL database via API calls
  static final List<Map<String, dynamic>> _allUsers = [];

  // Getters
  bool get isAuthenticated => _isAuthenticated;
  String? get userEmail => _userEmail;
  String? get userName => _userName;
  UserRole? get userRole => _userRole;
  String? get userId => _userId;
  String? get jwtToken => _jwtToken;
  String? get refreshToken => _refreshToken;
  
  // Getter for all users (for admin access)
  static List<Map<String, dynamic>> get allUsers => _allUsers;

  SpringAuthProvider() {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
    _userEmail = prefs.getString('userEmail');
    _userName = prefs.getString('userName');
    _userId = prefs.getString('userId');
    _jwtToken = prefs.getString('jwtToken');
    _refreshToken = prefs.getString('refreshToken');

    final roleString = prefs.getString('userRole');
    if (roleString != null) {
      _userRole = UserRole.values.firstWhere(
        (role) => role.toString() == roleString,
        orElse: () => UserRole.customer,
      );
    }

    // Validate token if exists
    if (_jwtToken != null && _isAuthenticated) {
      await _validateToken();
    }

    notifyListeners();
  }

  Future<void> _validateToken() async {
    try {
      final result = await ApiService.post('/auth/validate', authToken: _jwtToken);
      if (result['valid'] == true) {
        _isAuthenticated = true;
        _userId = result['userId'];
        _userEmail = result['email'];
        _userRole = _stringToUserRole(result['role']);
      } else {
        await logout();
      }
    } catch (e) {
      print('Token validation failed: $e');
      await logout();
    }
  }

  Future<Map<String, dynamic>> login(String email, String password, UserRole role) async {
    try {
      final result = await ApiService.authenticate(email, password, _userRoleToString(role));

      if (result['success'] == true) {
        _jwtToken = result['token'];
        _refreshToken = result['refreshToken'];
        _userId = result['userId'];
        _userEmail = email;
        _userName = result['userName'] ?? email.split('@')[0];
        _userRole = _stringToUserRole(result['userRole']);
        _isAuthenticated = true;

        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', true);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', _userName!);
        await prefs.setString('userRole', _userRole.toString());
        await prefs.setString('userId', _userId!);
        await prefs.setString('jwtToken', _jwtToken!);
        await prefs.setString('refreshToken', _refreshToken!);

        notifyListeners();

        return {
          'success': true,
          'message': 'Login successful!',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<Map<String, dynamic>> signup(
    String name,
    String email,
    String password,
    String confirmPassword,
    UserRole role,
  ) async {
    try {
      // Validate input
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        return {
          'success': false,
          'message': 'Please fill in all fields.',
        };
      }

      if (password != confirmPassword) {
        return {
          'success': false,
          'message': 'Passwords do not match.',
        };
      }

      if (password.length < 8) {
        return {
          'success': false,
          'message': 'Password must be at least 8 characters.',
        };
      }

      final result = await ApiService.register({
        'name': name,
        'email': email,
        'password': password,
        'confirmPassword': confirmPassword,
        'role': _userRoleToString(role),
      });

      if (result['success'] == true) {
        _userId = result['userId'];
        _userEmail = email;
        _userName = name;
        _userRole = role;
        _isAuthenticated = false; // User needs to login after signup

        // Save to local storage (no JWT tokens for signup)
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isAuthenticated', false);
        await prefs.setString('userEmail', email);
        await prefs.setString('userName', name);
        await prefs.setString('userRole', role.toString());
        await prefs.setString('userId', _userId!);

        notifyListeners();
        
        return {
          'success': true,
          'message': 'Registration successful! Please login to continue.',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  Future<void> logout() async {
    try {
      if (_jwtToken != null) {
        await ApiService.post('/auth/logout', authToken: _jwtToken);
      }
    } catch (e) {
      print('Logout API call failed: $e');
    }

    // Clear local data
    _isAuthenticated = false;
    _userEmail = null;
    _userName = null;
    _userRole = null;
    _userId = null;
    _jwtToken = null;
    _refreshToken = null;

    // Clear local storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isAuthenticated');
    await prefs.remove('userEmail');
    await prefs.remove('userName');
    await prefs.remove('userRole');
    await prefs.remove('userId');
    await prefs.remove('jwtToken');
    await prefs.remove('refreshToken');

    notifyListeners();
  }

  Future<bool> refreshAuthToken() async {
    try {
      if (_refreshToken == null) return false;

      final result = await ApiService.post('/auth/refresh', authToken: _refreshToken);
      
      if (result['success'] == true) {
        _jwtToken = result['token'];
        _refreshToken = result['refreshToken'];

        // Update local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwtToken', _jwtToken!);
        await prefs.setString('refreshToken', _refreshToken!);

        notifyListeners();
        return true;
      }
    } catch (e) {
      print('Token refresh failed: $e');
    }
    return false;
  }

  String _userRoleToString(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'customer';
      case UserRole.shopkeeper:
        return 'shopkeeper';
      case UserRole.admin:
        return 'admin';
    }
  }

  UserRole _stringToUserRole(String role) {
    switch (role.toLowerCase()) {
      case 'customer':
        return UserRole.customer;
      case 'shopkeeper':
        return UserRole.shopkeeper;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.customer;
    }
  }

  // Method to get display name for user role
  String getRoleDisplayName(UserRole role) {
    switch (role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.shopkeeper:
        return 'Shopkeeper';
      case UserRole.admin:
        return 'Admin';
    }
  }

  // Method to update user profile
  Future<Map<String, dynamic>> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    try {
      if (!_isAuthenticated || _jwtToken == null) {
        return {
          'success': false,
          'message': 'User not authenticated',
        };
      }

      final result = await ApiService.put(
        '/auth/profile',
        body: {
          'name': name,
          'phone': phone,
          'address': address,
        },
        authToken: _jwtToken,
      );

      if (result['success'] == true) {
        // Update local data
        _userName = name;
        
        // Save to local storage
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userName', name);
        await prefs.setString('userPhone', phone);
        await prefs.setString('userAddress', address);

        notifyListeners();
        
        return {
          'success': true,
          'message': 'Profile updated successfully!',
        };
      } else {
        return {
          'success': false,
          'message': result['message'] ?? 'Profile update failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }

  // Method to request password reset
  Future<Map<String, dynamic>> resetPassword(String email) async {
    try {
      if (email.isEmpty) {
        return {
          'success': false,
          'message': 'Email is required',
        };
      }

      final result = await ApiService.resetPassword(email.trim());

      return {
        'success': result['success'] == true,
        'message': result['message'] ?? 'Password reset request failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error. Please check your connection.',
      };
    }
  }
}
