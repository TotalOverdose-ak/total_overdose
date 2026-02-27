import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../theme/app_colors.dart';
import 'main_navigation_screen.dart';

/// Signup screen for new farmers.
/// Fields: Name, Phone, Village, PIN, Confirm PIN
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _villageController = TextEditingController();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePin = true;
  bool _obscureConfirm = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _villageController.dispose();
    _pinController.dispose();
    _confirmPinController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final auth = context.read<AuthProvider>();
    final success = await auth.signup(
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      village: _villageController.text.trim(),
      pin: _pinController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
        (route) => false,
      );
    } else {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<LanguageProvider>().tr('signup_failed')),
          backgroundColor: AppColors.riskHigh,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.homeGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),

                    // ── Header ──────────────────────────────────────────
                    Text('🧑‍🌾', style: GoogleFonts.poppins(fontSize: 48)),
                    const SizedBox(height: 6),
                    Text(
                      lang.tr('signup_title'),
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      lang.tr('signup_subtitle'),
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // ── Signup Card ─────────────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name
                            _buildField(
                              controller: _nameController,
                              label: lang.tr('farmer_name'),
                              hint: lang.tr('farmer_name_hint'),
                              icon: Icons.person_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return lang.tr('name_error');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Phone
                            _buildField(
                              controller: _phoneController,
                              label: lang.tr('phone_number'),
                              hint: '9876543210',
                              icon: Icons.phone_android_rounded,
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (v) {
                                if (v == null || v.trim().length != 10) {
                                  return lang.tr('phone_error');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Village
                            _buildField(
                              controller: _villageController,
                              label: lang.tr('village'),
                              hint: lang.tr('village_hint'),
                              icon: Icons.location_on_rounded,
                            ),
                            const SizedBox(height: 14),

                            // PIN
                            _buildField(
                              controller: _pinController,
                              label: lang.tr('pin'),
                              hint: '••••',
                              icon: Icons.lock_rounded,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscure: _obscurePin,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePin
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.textLight,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePin = !_obscurePin),
                              ),
                              letterSpacing: 8,
                              validator: (v) {
                                if (v == null || v.length != 4) {
                                  return lang.tr('pin_error');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            // Confirm PIN
                            _buildField(
                              controller: _confirmPinController,
                              label: lang.tr('confirm_pin'),
                              hint: '••••',
                              icon: Icons.lock_outline_rounded,
                              keyboardType: TextInputType.number,
                              maxLength: 4,
                              obscure: _obscureConfirm,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: AppColors.textLight,
                                ),
                                onPressed: () => setState(
                                  () => _obscureConfirm = !_obscureConfirm,
                                ),
                              ),
                              letterSpacing: 8,
                              validator: (v) {
                                if (v == null || v.length != 4) {
                                  return lang.tr('pin_error');
                                }
                                if (v != _pinController.text) {
                                  return lang.tr('pin_mismatch');
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            // Signup button
                            SizedBox(
                              height: 52,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleSignup,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  elevation: 3,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : Text(
                                        lang.tr('signup_btn'),
                                        style: GoogleFonts.poppins(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ── Login Link ──────────────────────────────────────
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                          children: [
                            TextSpan(text: '${lang.tr('already_account')} '),
                            TextSpan(
                              text: lang.tr('login_link'),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Reusable input builder ────────────────────────────────────────────────
  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
    bool obscure = false,
    double letterSpacing = 0,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      obscureText: obscure,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryGreen),
        suffixIcon: suffixIcon,
        counterText: '',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryGreen, width: 2),
        ),
      ),
      style: GoogleFonts.poppins(fontSize: 16, letterSpacing: letterSpacing),
      validator: validator,
    );
  }
}
