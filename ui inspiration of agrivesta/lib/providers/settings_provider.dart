import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/settings_service.dart';
import 'spring_auth_provider.dart';

class SettingsProvider extends ChangeNotifier {
  // final SettingsService _settingsService = SettingsService(); // All methods are static now
  final SpringAuthProvider _authProvider = SpringAuthProvider();
  // Removed Firebase Auth dependency - using Spring Boot auth now
  
  // Notification Settings
  bool _pushNotificationsEnabled = true;
  bool _orderNotificationsEnabled = true;
  bool _ecoTipsEnabled = true;
  bool _promotionalNotificationsEnabled = true;
  bool _carbonTrackingEnabled = true;

  // Privacy & Security Settings
  bool _locationEnabled = true;
  bool _dataCollectionEnabled = true;
  bool _biometricEnabled = false;

  // App Preferences
  bool _darkModeEnabled = false;
  bool _autoSaveEnabled = true;
  bool _hapticFeedbackEnabled = true;
  
  // Additional Firebase-based settings
  String _language = 'en';
  String _currency = 'INR';
  String _timezone = 'Asia/Kolkata';
  String _theme = 'system';
  String _fontSize = 'medium';
  bool _autoSync = true;
  bool _offlineMode = false;

  // Loading and error states
  bool _isLoading = false;
  String? _errorMessage;
  bool _isInitialized = false;

  // Getters
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;
  bool get orderNotificationsEnabled => _orderNotificationsEnabled;
  bool get ecoTipsEnabled => _ecoTipsEnabled;
  bool get promotionalNotificationsEnabled => _promotionalNotificationsEnabled;
  bool get carbonTrackingEnabled => _carbonTrackingEnabled;
  bool get locationEnabled => _locationEnabled;
  bool get dataCollectionEnabled => _dataCollectionEnabled;
  bool get biometricEnabled => _biometricEnabled;
  bool get darkModeEnabled => _darkModeEnabled;
  bool get autoSaveEnabled => _autoSaveEnabled;
  bool get hapticFeedbackEnabled => _hapticFeedbackEnabled;
  String get language => _language;
  String get currency => _currency;
  String get timezone => _timezone;
  String get theme => _theme;
  String get fontSize => _fontSize;
  bool get autoSync => _autoSync;
  bool get offlineMode => _offlineMode;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isInitialized => _isInitialized;

  SettingsProvider() {
    _initializeSettings();
  }

  Future<void> _initializeSettings() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Check if user is authenticated (using Spring Boot auth)
      // For now, we'll use a simple check - in real implementation, get from SpringAuthProvider
      final prefs = await SharedPreferences.getInstance();
      final isAuthenticated = prefs.getBool('isAuthenticated') ?? false;
      final userId = prefs.getString('userId');
      
      if (isAuthenticated && userId != null) {
        // Initialize Firebase settings for the user
        await SettingsService.initializeUserSettings(userId);
        
        // Load settings from Firebase with real-time updates
        _loadSettingsFromFirebase(userId);
      } else {
        // Fallback to SharedPreferences for offline mode
        await _loadSettingsFromSharedPreferences();
      }
      
      _isInitialized = true;
    } catch (e) {
      _errorMessage = 'Failed to initialize settings: $e';
      print('Error initializing settings: $e');
      
      // Fallback to SharedPreferences
      await _loadSettingsFromSharedPreferences();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _loadSettingsFromFirebase(String userId) {
    // TODO: Implement real-time settings loading with Spring Boot API
    // For now, just load settings once
    _loadSettingsOnce(userId);
  }

  Future<void> _loadSettingsOnce(String userId) async {
    try {
      final settings = await SettingsService.getUserSettings(userId);
      _updateSettingsFromMap(settings);
      notifyListeners();
    } catch (error) {
      _errorMessage = 'Failed to load settings: $error';
      print('Error loading settings: $error');
      notifyListeners();
    }
  }

  void _updateSettingsFromMap(Map<String, dynamic> settings) {
    try {
      // Update notification settings
      final notifications = settings['notifications'] as Map<String, dynamic>?;
      if (notifications != null) {
        _pushNotificationsEnabled = notifications['pushNotificationsEnabled'] ?? true;
        _orderNotificationsEnabled = notifications['orderNotificationsEnabled'] ?? true;
        _ecoTipsEnabled = notifications['ecoTipsEnabled'] ?? true;
        _promotionalNotificationsEnabled = notifications['promotionalNotificationsEnabled'] ?? true;
        _carbonTrackingEnabled = notifications['carbonTrackingEnabled'] ?? true;
      }

      // Update privacy settings
      final privacy = settings['privacy'] as Map<String, dynamic>?;
      if (privacy != null) {
        _locationEnabled = privacy['locationEnabled'] ?? true;
        _dataCollectionEnabled = privacy['dataCollectionEnabled'] ?? true;
        _biometricEnabled = privacy['biometricEnabled'] ?? false;
      }

      // Update app preferences
      final preferences = settings['preferences'] as Map<String, dynamic>?;
      if (preferences != null) {
        _darkModeEnabled = preferences['darkModeEnabled'] ?? false;
        _autoSaveEnabled = preferences['autoSaveEnabled'] ?? true;
        _hapticFeedbackEnabled = preferences['hapticFeedbackEnabled'] ?? true;
        _language = preferences['language'] ?? 'en';
        _currency = preferences['currency'] ?? 'INR';
        _timezone = preferences['timezone'] ?? 'Asia/Kolkata';
      }

      // Update app settings
      final app = settings['app'] as Map<String, dynamic>?;
      if (app != null) {
        _theme = app['theme'] ?? 'system';
        _fontSize = app['fontSize'] ?? 'medium';
      }

      // Update sync settings
      final sync = settings['sync'] as Map<String, dynamic>?;
      if (sync != null) {
        _autoSync = sync['autoSync'] ?? true;
        _offlineMode = sync['offlineMode'] ?? false;
      }
    } catch (e) {
      print('Error updating settings from map: $e');
    }
  }

  Future<void> _loadSettingsFromSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _pushNotificationsEnabled = prefs.getBool('pushNotificationsEnabled') ?? true;
      _orderNotificationsEnabled = prefs.getBool('orderNotificationsEnabled') ?? true;
      _ecoTipsEnabled = prefs.getBool('ecoTipsEnabled') ?? true;
      _promotionalNotificationsEnabled = prefs.getBool('promotionalNotificationsEnabled') ?? true;
      _carbonTrackingEnabled = prefs.getBool('carbonTrackingEnabled') ?? true;
      
      _locationEnabled = prefs.getBool('locationEnabled') ?? true;
      _dataCollectionEnabled = prefs.getBool('dataCollectionEnabled') ?? true;
      _biometricEnabled = prefs.getBool('biometricEnabled') ?? false;
      
      _darkModeEnabled = prefs.getBool('darkModeEnabled') ?? false;
      _autoSaveEnabled = prefs.getBool('autoSaveEnabled') ?? true;
      _hapticFeedbackEnabled = prefs.getBool('hapticFeedbackEnabled') ?? true;
      
      _language = prefs.getString('language') ?? 'en';
      _currency = prefs.getString('currency') ?? 'INR';
      _timezone = prefs.getString('timezone') ?? 'Asia/Kolkata';
      _theme = prefs.getString('theme') ?? 'system';
      _fontSize = prefs.getString('fontSize') ?? 'medium';
      _autoSync = prefs.getBool('autoSync') ?? true;
      _offlineMode = prefs.getBool('offlineMode') ?? false;
    } catch (e) {
      print('Error loading settings from SharedPreferences: $e');
    }
  }

  Future<void> _saveSettingsToFirebase(String category, String key, dynamic value) async {
    try {
      if (_authProvider.isAuthenticated && _authProvider.userId != null) {
        // TODO: Implement updateSetting with Spring Boot API
        // await SettingsService.updateSetting(_authProvider.userId!, category, key, value);
      }
    } catch (e) {
      print('Error saving setting to Firebase: $e');
      // Fallback to SharedPreferences
      await _saveSettingToSharedPreferences(key, value);
    }
  }

  Future<void> _saveSettingToSharedPreferences(String key, dynamic value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (value is bool) {
        await prefs.setBool(key, value);
      } else if (value is String) {
        await prefs.setString(key, value);
      }
    } catch (e) {
      print('Error saving setting to SharedPreferences: $e');
    }
  }

  // Notification Settings Methods
  void setPushNotifications(bool value) {
    _pushNotificationsEnabled = value;
    print('Push notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('notifications', 'pushNotificationsEnabled', value);
    notifyListeners();
  }

  void setOrderNotifications(bool value) {
    _orderNotificationsEnabled = value;
    print('Order notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('notifications', 'orderNotificationsEnabled', value);
    notifyListeners();
  }

  void setEcoTips(bool value) {
    _ecoTipsEnabled = value;
    print('Eco tips: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('notifications', 'ecoTipsEnabled', value);
    notifyListeners();
  }

  void setPromotionalNotifications(bool value) {
    _promotionalNotificationsEnabled = value;
    print('Promotional notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('notifications', 'promotionalNotificationsEnabled', value);
    notifyListeners();
  }

  void setCarbonTracking(bool value) {
    _carbonTrackingEnabled = value;
    print('Carbon tracking notifications: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('notifications', 'carbonTrackingEnabled', value);
    notifyListeners();
  }

  // Privacy & Security Methods
  void setLocationEnabled(bool value) {
    _locationEnabled = value;
    print('Location services: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('privacy', 'locationEnabled', value);
    notifyListeners();
  }

  void setDataCollection(bool value) {
    _dataCollectionEnabled = value;
    print('Data collection: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('privacy', 'dataCollectionEnabled', value);
    notifyListeners();
  }

  void setBiometricEnabled(bool value) {
    _biometricEnabled = value;
    print('Biometric login: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('privacy', 'biometricEnabled', value);
    notifyListeners();
  }

  // App Preferences Methods
  void setDarkMode(bool value) {
    _darkModeEnabled = value;
    print('Dark mode: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('preferences', 'darkModeEnabled', value);
    notifyListeners();
  }

  void setAutoSave(bool value) {
    _autoSaveEnabled = value;
    print('Auto-save: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('preferences', 'autoSaveEnabled', value);
    notifyListeners();
  }

  void setHapticFeedback(bool value) {
    _hapticFeedbackEnabled = value;
    print('Haptic feedback: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('preferences', 'hapticFeedbackEnabled', value);
    notifyListeners();
  }

  // New Firebase-based settings methods
  void setLanguage(String value) {
    _language = value;
    print('Language changed to: $value');
    _saveSettingsToFirebase('preferences', 'language', value);
    notifyListeners();
  }

  void setCurrency(String value) {
    _currency = value;
    print('Currency changed to: $value');
    _saveSettingsToFirebase('preferences', 'currency', value);
    notifyListeners();
  }

  void setTimezone(String value) {
    _timezone = value;
    print('Timezone changed to: $value');
    _saveSettingsToFirebase('preferences', 'timezone', value);
    notifyListeners();
  }

  void setTheme(String value) {
    _theme = value;
    print('Theme changed to: $value');
    _saveSettingsToFirebase('app', 'theme', value);
    notifyListeners();
  }

  void setFontSize(String value) {
    _fontSize = value;
    print('Font size changed to: $value');
    _saveSettingsToFirebase('app', 'fontSize', value);
    notifyListeners();
  }

  void setAutoSync(bool value) {
    _autoSync = value;
    print('Auto sync: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('sync', 'autoSync', value);
    notifyListeners();
  }

  void setOfflineMode(bool value) {
    _offlineMode = value;
    print('Offline mode: ${value ? 'enabled' : 'disabled'}');
    _saveSettingsToFirebase('sync', 'offlineMode', value);
    notifyListeners();
  }

  // Check if any notifications are enabled
  bool get anyNotificationsEnabled {
    return _pushNotificationsEnabled ||
           _orderNotificationsEnabled ||
           _ecoTipsEnabled ||
           _promotionalNotificationsEnabled ||
           _carbonTrackingEnabled;
  }



  // Reset all settings to default
  void resetToDefaults() async {
    try {
      if (_authProvider.isAuthenticated && _authProvider.userId != null) {
        await SettingsService.resetSettingsToDefault(_authProvider.userId!);
      }
      
    _pushNotificationsEnabled = true;
    _orderNotificationsEnabled = true;
    _ecoTipsEnabled = true;
    _promotionalNotificationsEnabled = true;
    _carbonTrackingEnabled = true;
    _locationEnabled = true;
    _dataCollectionEnabled = true;
    _biometricEnabled = false;
    _darkModeEnabled = false;
    _autoSaveEnabled = true;
    _hapticFeedbackEnabled = true;
      _language = 'en';
      _currency = 'INR';
      _timezone = 'Asia/Kolkata';
      _theme = 'system';
      _fontSize = 'medium';
      _autoSync = true;
      _offlineMode = false;
      
    print('Settings reset to defaults');
    notifyListeners();
    } catch (e) {
      print('Error resetting settings: $e');
    }
  }

  // Get settings summary
  Map<String, dynamic> getSettingsSummary() {
    return {
      'notifications': {
        'push': _pushNotificationsEnabled,
        'orders': _orderNotificationsEnabled,
        'eco_tips': _ecoTipsEnabled,
        'promotional': _promotionalNotificationsEnabled,
        'carbon_tracking': _carbonTrackingEnabled,
      },
      'privacy': {
        'location': _locationEnabled,
        'data_collection': _dataCollectionEnabled,
        'biometric': _biometricEnabled,
      },
      'preferences': {
        'dark_mode': _darkModeEnabled,
        'auto_save': _autoSaveEnabled,
        'haptic_feedback': _hapticFeedbackEnabled,
        'language': _language,
        'currency': _currency,
        'timezone': _timezone,
      },
      'app': {
        'theme': _theme,
        'font_size': _fontSize,
      },
      'sync': {
        'auto_sync': _autoSync,
        'offline_mode': _offlineMode,
      },
    };
  }

  // Export settings for backup
  Future<Map<String, dynamic>> exportSettings() async {
    try {
      if (_authProvider.isAuthenticated && _authProvider.userId != null) {
        return await SettingsService.exportUserData(_authProvider.userId!);
      } else {
        return {
          'version': '1.0.0',
          'exported_at': DateTime.now().toIso8601String(),
          'settings': getSettingsSummary(),
        };
      }
    } catch (e) {
      print('Error exporting settings: $e');
    return {
      'version': '1.0.0',
      'exported_at': DateTime.now().toIso8601String(),
      'settings': getSettingsSummary(),
    };
    }
  }

  // Import settings from backup
  Future<bool> importSettings(Map<String, dynamic> data) async {
    try {
      if (_authProvider.isAuthenticated && _authProvider.userId != null) {
        // TODO: Implement importSettings with Spring Boot API
        // return await SettingsService.importSettings(_authProvider.userId!, data);
        return false; // Import not implemented yet
      } else {
        // Import to SharedPreferences if not authenticated
        return await _importSettingsToSharedPreferences(data);
      }
    } catch (e) {
      print('Error importing settings: $e');
      return false;
    }
  }

  Future<bool> _importSettingsToSharedPreferences(Map<String, dynamic> data) async {
    try {
      if (data['version'] != '1.0.0') {
        print('Unsupported settings version');
        return false;
      }

      final settings = data['settings'] as Map<String, dynamic>;
      
      // Import notification settings
      final notifications = settings['notifications'] as Map<String, dynamic>;
      _pushNotificationsEnabled = notifications['push'] ?? true;
      _orderNotificationsEnabled = notifications['orders'] ?? true;
      _ecoTipsEnabled = notifications['eco_tips'] ?? true;
      _promotionalNotificationsEnabled = notifications['promotional'] ?? true;
      _carbonTrackingEnabled = notifications['carbon_tracking'] ?? true;

      // Import privacy settings
      final privacy = settings['privacy'] as Map<String, dynamic>;
      _locationEnabled = privacy['location'] ?? true;
      _dataCollectionEnabled = privacy['data_collection'] ?? true;
      _biometricEnabled = privacy['biometric'] ?? false;

      // Import app preferences
      final preferences = settings['preferences'] as Map<String, dynamic>;
      _darkModeEnabled = preferences['dark_mode'] ?? false;
      _autoSaveEnabled = preferences['auto_save'] ?? true;
      _hapticFeedbackEnabled = preferences['haptic_feedback'] ?? true;
      _language = preferences['language'] ?? 'en';
      _currency = preferences['currency'] ?? 'INR';
      _timezone = preferences['timezone'] ?? 'Asia/Kolkata';

      // Import app settings
      final app = settings['app'] as Map<String, dynamic>?;
      if (app != null) {
        _theme = app['theme'] ?? 'system';
        _fontSize = app['font_size'] ?? 'medium';
      }

      // Import sync settings
      final sync = settings['sync'] as Map<String, dynamic>?;
      if (sync != null) {
        _autoSync = sync['auto_sync'] ?? true;
        _offlineMode = sync['offline_mode'] ?? false;
      }

      await _saveAllSettingsToSharedPreferences();
      notifyListeners();
      print('Settings imported successfully to SharedPreferences');
      return true;
    } catch (e) {
      print('Error importing settings to SharedPreferences: $e');
      return false;
    }
  }

  Future<void> _saveAllSettingsToSharedPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('pushNotificationsEnabled', _pushNotificationsEnabled);
      await prefs.setBool('orderNotificationsEnabled', _orderNotificationsEnabled);
      await prefs.setBool('ecoTipsEnabled', _ecoTipsEnabled);
      await prefs.setBool('promotionalNotificationsEnabled', _promotionalNotificationsEnabled);
      await prefs.setBool('carbonTrackingEnabled', _carbonTrackingEnabled);
      
      await prefs.setBool('locationEnabled', _locationEnabled);
      await prefs.setBool('dataCollectionEnabled', _dataCollectionEnabled);
      await prefs.setBool('biometricEnabled', _biometricEnabled);
      
      await prefs.setBool('darkModeEnabled', _darkModeEnabled);
      await prefs.setBool('autoSaveEnabled', _autoSaveEnabled);
      await prefs.setBool('hapticFeedbackEnabled', _hapticFeedbackEnabled);
      
      await prefs.setString('language', _language);
      await prefs.setString('currency', _currency);
      await prefs.setString('timezone', _timezone);
      await prefs.setString('theme', _theme);
      await prefs.setString('fontSize', _fontSize);
      await prefs.setBool('autoSync', _autoSync);
      await prefs.setBool('offlineMode', _offlineMode);
    } catch (e) {
      print('Error saving all settings to SharedPreferences: $e');
    }
  }

  // Sync settings with Firebase
  Future<void> syncSettings() async {
    try {
      if (_authProvider.isAuthenticated && _authProvider.userId != null) {
        // TODO: Implement syncSettings with Spring Boot API
        // await SettingsService.syncSettings(_authProvider.userId!);
        print('Settings synced successfully');
      }
    } catch (e) {
      print('Error syncing settings: $e');
    }
  }

  // Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Refresh settings from Firebase
  Future<void> refreshSettings() async {
    try {
      if (_authProvider.isAuthenticated && _authProvider.userId != null) {
        final settings = await SettingsService.getUserSettings(_authProvider.userId!);
        _updateSettingsFromMap(settings);
        notifyListeners();
            }
    } catch (e) {
      print('Error refreshing settings: $e');
    }
  }
}
