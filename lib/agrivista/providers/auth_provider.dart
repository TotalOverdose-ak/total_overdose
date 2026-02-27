import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Simple local auth provider for farmer onboarding.
/// Uses SharedPreferences — no backend needed, works offline.
class AuthProvider extends ChangeNotifier {
  // ── Keys ──────────────────────────────────────────────────────────────────
  static const _keyLoggedIn = 'auth_logged_in';
  static const _keyFirstLaunch = 'auth_first_launch';
  static const _keyName = 'auth_farmer_name';
  static const _keyPhone = 'auth_phone';
  static const _keyVillage = 'auth_village';
  static const _keyPin = 'auth_pin';

  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoggedIn = false;
  bool _isFirstLaunch = true;
  bool _isInitialized = false;
  String _farmerName = '';
  String _phone = '';
  String _village = '';

  // ── Getters ───────────────────────────────────────────────────────────────
  bool get isLoggedIn => _isLoggedIn;
  bool get isFirstLaunch => _isFirstLaunch;
  bool get isInitialized => _isInitialized;
  String get farmerName => _farmerName;
  String get phone => _phone;
  String get village => _village;

  // ── Initialize (call once on app start) ───────────────────────────────────
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _isLoggedIn = prefs.getBool(_keyLoggedIn) ?? false;
    _isFirstLaunch = prefs.getBool(_keyFirstLaunch) ?? true;
    _farmerName = prefs.getString(_keyName) ?? '';
    _phone = prefs.getString(_keyPhone) ?? '';
    _village = prefs.getString(_keyVillage) ?? '';
    _isInitialized = true;
    notifyListeners();
  }

  // ── Mark language selected (first launch complete) ────────────────────────
  Future<void> completeLanguageSelection() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
    _isFirstLaunch = false;
    notifyListeners();
  }

  // ── Signup ────────────────────────────────────────────────────────────────
  Future<bool> signup({
    required String name,
    required String phone,
    required String village,
    required String pin,
  }) async {
    if (name.trim().isEmpty || phone.length != 10 || pin.length != 4) {
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyName, name.trim());
    await prefs.setString(_keyPhone, phone.trim());
    await prefs.setString(_keyVillage, village.trim());
    await prefs.setString(_keyPin, pin);
    await prefs.setBool(_keyLoggedIn, true);
    await prefs.setBool(_keyFirstLaunch, false);

    _farmerName = name.trim();
    _phone = phone.trim();
    _village = village.trim();
    _isLoggedIn = true;
    _isFirstLaunch = false;
    notifyListeners();
    return true;
  }

  // ── Login ─────────────────────────────────────────────────────────────────
  Future<bool> login({required String phone, required String pin}) async {
    final prefs = await SharedPreferences.getInstance();
    final savedPhone = prefs.getString(_keyPhone) ?? '';
    final savedPin = prefs.getString(_keyPin) ?? '';

    if (phone.trim() == savedPhone && pin == savedPin) {
      await prefs.setBool(_keyLoggedIn, true);
      _isLoggedIn = true;
      _farmerName = prefs.getString(_keyName) ?? '';
      _phone = savedPhone;
      _village = prefs.getString(_keyVillage) ?? '';
      notifyListeners();
      return true;
    }
    return false;
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyLoggedIn, false);
    _isLoggedIn = false;
    notifyListeners();
  }
}
