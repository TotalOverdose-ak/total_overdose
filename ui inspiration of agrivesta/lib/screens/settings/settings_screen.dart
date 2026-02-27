import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/spring_auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isEditingProfile = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    _nameController.text = authProvider.userName ?? '';
    _loadPhoneAndAddress();
  }

  Future<void> _loadPhoneAndAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _phoneController.text = prefs.getString('userPhone') ?? '';
      _addressController.text = prefs.getString('userAddress') ?? '';
    } catch (e) {
      print('Error loading phone and address: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: Text(
          'Settings & Preferences',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF22223B)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Section
                _buildSectionHeader('Profile', Icons.person_rounded),
                _buildProfileCard(),
                const SizedBox(height: 24),

                // Notifications Section
                _buildSectionHeader('Notifications', Icons.notifications_rounded),
                _buildNotificationSettings(settingsProvider),
                const SizedBox(height: 24),

                // Privacy & Security Section
                _buildSectionHeader('Privacy & Security', Icons.security_rounded),
                _buildPrivacySettings(settingsProvider),
                const SizedBox(height: 24),

                // App Preferences Section
                _buildSectionHeader('App Preferences', Icons.settings_rounded),
                _buildAppPreferences(settingsProvider),
                const SizedBox(height: 24),

                // Sync Section
                _buildSectionHeader('Sync', Icons.cloud_sync_rounded),
                _buildSyncSettings(settingsProvider),
                const SizedBox(height: 24),


                // Logout Button
                _buildLogoutButton(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            color: const Color(0xFFB5C7F7),
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF22223B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    final authProvider = Provider.of<SpringAuthProvider>(context);
    
    return Container(
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
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: const Color(0xFFB5C7F7),
                child: Text(
                  _getInitials(authProvider.userName ?? 'User'),
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authProvider.userName ?? 'User',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                    ),
                    Text(
                      authProvider.userEmail ?? 'user@example.com',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      '${authProvider.getRoleDisplayName(authProvider.userRole ?? UserRole.customer)} • 1250 Points',
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: const Color(0xFFB5C7F7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_phoneController.text.isNotEmpty)
                      Text(
                        '📱 ${_phoneController.text}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    if (_addressController.text.isNotEmpty)
                      Text(
                        '📍 ${_addressController.text}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _isEditingProfile = !_isEditingProfile;
                  });
                },
                icon: Icon(
                  _isEditingProfile ? Icons.close_rounded : Icons.edit_rounded,
                  color: const Color(0xFFB5C7F7),
                ),
              ),
            ],
          ),
          if (_isEditingProfile) ...[
            const SizedBox(height: 20),
            _buildProfileEditForm(),
          ],
        ],
      ),
    );
  }

  Widget _buildProfileEditForm() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Full Name',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.person_rounded, color: Color(0xFFB5C7F7)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.phone_rounded, color: Color(0xFFB5C7F7)),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: _addressController,
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Address',
              labelStyle: GoogleFonts.poppins(color: Colors.grey[600]),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              prefixIcon: const Icon(Icons.location_on_rounded, color: Color(0xFFB5C7F7)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB5C7F7),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        'Save Changes',
                        style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                        ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your name'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save to SharedPreferences for immediate access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPhone', _phoneController.text.trim());
      await prefs.setString('userAddress', _addressController.text.trim());
      
      // Update auth provider if name changed
      final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
      if (authProvider.userName != _nameController.text.trim()) {
      final result = await authProvider.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
      );

      if (result['success']) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message']),
            backgroundColor: Colors.red,
          ),
        );
      }
      } else {
        // Just show success message for phone/address update
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
      setState(() {
        _isEditingProfile = false;
      });
      
      // Refresh the UI
      setState(() {});
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Widget _buildNotificationSettings(SettingsProvider provider) {
    return Container(
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
          
          
          // Individual Notification Settings
          _buildEnhancedNotificationTile(
            'Push Notifications',
            'Receive notifications about orders, offers, and updates',
            Icons.notifications_active_rounded,
            provider.pushNotificationsEnabled,
            (value) => _toggleNotification(provider, 'pushNotifications', value),
            isMainNotification: false,
          ),
          _buildDivider(),
          _buildEnhancedNotificationTile(
            'Order Updates',
            'Get notified about order status changes',
            Icons.shopping_bag_rounded,
            provider.orderNotificationsEnabled,
            (value) => _toggleNotification(provider, 'orderNotifications', value),
            isMainNotification: false,
          ),
          _buildDivider(),
          _buildEnhancedNotificationTile(
            'Eco Tips & Challenges',
            'Daily eco-friendly tips and challenge reminders',
            Icons.eco_rounded,
            provider.ecoTipsEnabled,
            (value) => _toggleNotification(provider, 'ecoTips', value),
            isMainNotification: false,
          ),
          _buildDivider(),
          _buildEnhancedNotificationTile(
            'Promotional Offers',
            'Receive offers and discounts from eco-friendly stores',
            Icons.local_offer_rounded,
            provider.promotionalNotificationsEnabled,
            (value) => _toggleNotification(provider, 'promotionalNotifications', value),
            isMainNotification: false,
          ),
          _buildDivider(),
          _buildEnhancedNotificationTile(
            'Carbon Tracking Updates',
            'Weekly carbon footprint reports and achievements',
            Icons.trending_up_rounded,
            provider.carbonTrackingEnabled,
            (value) => _toggleNotification(provider, 'carbonTracking', value),
            isMainNotification: false,
          ),

          

        ],
      ),
    );
  }

  Widget _buildEnhancedNotificationTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
    {required bool isMainNotification}
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: value 
              ? (isMainNotification ? Colors.green.withOpacity(0.1) : const Color(0xFFB5C7F7).withOpacity(0.1))
              : Colors.grey.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: value 
              ? (isMainNotification ? Colors.green : const Color(0xFFB5C7F7))
              : Colors.grey,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: value ? const Color(0xFF22223B) : Colors.grey[600],
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: value ? Colors.grey[600] : Colors.grey[400],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: isMainNotification ? Colors.green : const Color(0xFFB5C7F7),
        activeTrackColor: isMainNotification ? Colors.green.withOpacity(0.3) : const Color(0xFFB5C7F7).withOpacity(0.3),
      ),
    );
  }



  



  Widget _buildPrivacySettings(SettingsProvider provider) {
    return Container(
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
          _buildSettingTile(
            'Location Services',
            'Allow app to access your location for nearby stores',
            Icons.location_on_rounded,
            provider.locationEnabled,
            (value) => provider.setLocationEnabled(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Data Collection',
            'Allow app to collect usage data for improvements',
            Icons.data_usage_rounded,
            provider.dataCollectionEnabled,
            (value) => provider.setDataCollection(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Biometric Login',
            'Use fingerprint or face ID for quick login',
            Icons.fingerprint_rounded,
            provider.biometricEnabled,
            (value) => provider.setBiometricEnabled(value),
          ),
        ],
      ),
    );
  }

  Widget _buildAppPreferences(SettingsProvider provider) {
    return Container(
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
          _buildSettingTile(
            'Dark Mode',
            'Use dark theme for better visibility in low light',
            Icons.dark_mode_rounded,
            provider.darkModeEnabled,
            (value) => provider.setDarkMode(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Auto Save',
            'Automatically save your preferences and settings',
            Icons.save_rounded,
            provider.autoSaveEnabled,
            (value) => provider.setAutoSave(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Haptic Feedback',
            'Feel vibrations when interacting with the app',
            Icons.vibration_rounded,
            provider.hapticFeedbackEnabled,
            (value) => provider.setHapticFeedback(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncSettings(SettingsProvider provider) {
    return Container(
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
          _buildSettingTile(
            'Auto Sync',
            'Automatically sync your settings across devices',
            Icons.cloud_sync_rounded,
            provider.autoSync,
            (value) => provider.setAutoSync(value),
          ),
          _buildDivider(),
          _buildSettingTile(
            'Offline Mode',
            'Use app without internet connection',
            Icons.offline_bolt_rounded,
            provider.offlineMode,
            (value) => provider.setOfflineMode(value),
          ),
        ],
      ),
    );
  }



  Widget _buildSettingTile(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFB5C7F7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFB5C7F7),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF22223B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFB5C7F7),
        activeTrackColor: const Color(0xFFB5C7F7).withOpacity(0.3),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFB5C7F7).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: const Color(0xFFB5C7F7),
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF22223B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.poppins(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios_rounded,
        color: Color(0xFFB5C7F7),
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      indent: 72,
      endIndent: 16,
      color: Color(0xFFF0F0F0),
    );
  }


  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => _showLogoutConfirmation(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Logout',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: Colors.grey[700],
          ),
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
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text('Logout', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _logout() {
    final authProvider = Provider.of<SpringAuthProvider>(context, listen: false);
    authProvider.logout();
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final names = name.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  // Helper methods for notifications


  void _toggleNotification(SettingsProvider provider, String type, bool value) {
    // Show loading state
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 12),
            Text('Updating ${type.replaceAll(RegExp(r'([A-Z])'), ' \$1').toLowerCase()}...'),
          ],
        ),
        duration: const Duration(seconds: 1),
        backgroundColor: const Color(0xFFB5C7F7),
      ),
    );

    // Update the setting
    switch (type) {
      case 'pushNotifications':
        provider.setPushNotifications(value);
        break;
      case 'orderNotifications':
        provider.setOrderNotifications(value);
        break;
      case 'ecoTips':
        provider.setEcoTips(value);
        break;
      case 'promotionalNotifications':
        provider.setPromotionalNotifications(value);
        break;
      case 'carbonTracking':
        provider.setCarbonTracking(value);
        break;
    }

    // Show success message
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${type.replaceAll(RegExp(r'([A-Z])'), ' \$1').toLowerCase()} ${value ? 'enabled' : 'disabled'} successfully!',
            ),
            backgroundColor: value ? Colors.green : Colors.orange,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    });
  }




  void _showNotificationPermissionInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Notification Permissions',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To receive notifications from EcoBazaarX:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 12),
            _buildPermissionStep(
              '1',
              'Ensure system notifications are enabled for the app',
              Icons.notifications_rounded,
            ),
            _buildPermissionStep(
              '2',
              'Check that the app has notification permissions',
              Icons.security_rounded,
            ),
            _buildPermissionStep(
              '3',
              'Make sure your device is not in Do Not Disturb mode',
              Icons.do_not_disturb_rounded,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_rounded,
                    color: Colors.blue,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can manage notification permissions in your device settings under Apps > EcoBazaarX > Notifications.',
              style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Got it',
              style: GoogleFonts.poppins(color: const Color(0xFFB5C7F7)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionStep(String number, String description, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFFB5C7F7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
          style: GoogleFonts.poppins(
                  fontSize: 12,
            fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Icon(
            icon,
            color: const Color(0xFFB5C7F7),
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              description,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open link'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

