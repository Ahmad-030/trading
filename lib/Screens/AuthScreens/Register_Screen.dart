import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../AppTheme/App_theme.dart';
import '../../Providers/Auth_provider.dart';
import 'Pending_approval_Screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_agreeToTerms) {
      _showErrorSnackBar('Please agree to Terms & Conditions');
      return;
    }

    setState(() => _isLoading = true);

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final result = await authProvider.register(
      email: _emailController.text.trim(),
      password: _passwordController.text,
      displayName: _nameController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      _showSuccessDialog();
    } else {
      _showErrorSnackBar(result['error'] ?? 'Registration failed');
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.buyGreen.withOpacity(0.2),
              ),
              child: const Icon(
                Iconsax.tick_circle,
                color: AppColors.buyGreen,
                size: 50,
              ),
            )
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 24),
            Text(
              'Registration Successful!',
              style: GoogleFonts.orbitron(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Your account is pending admin approval.\nAn OTP has been sent to the admin for verification.',
              style: GoogleFonts.rajdhani(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => const PendingApprovalScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGold,
                  foregroundColor: AppColors.primaryBlack,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'CONTINUE',
                  style: GoogleFonts.orbitron(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Iconsax.warning_2, color: AppColors.sellRed, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.rajdhani(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.cardBlack,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.sellRed.withOpacity(0.5)),
        ),
      ),
    );
  }

  void _showTermsAndConditionsDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TermsAndConditionsDialog(
        onAgreed: () {
          setState(() {
            _agreeToTerms = true;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Iconsax.arrow_left, color: AppColors.primaryGold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                _buildRegisterForm(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppGradients.primaryGradient,
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.3),
                blurRadius: 20,
                spreadRadius: 3,
              ),
            ],
          ),
          child: const Icon(
            Iconsax.user_add,
            size: 40,
            color: AppColors.primaryBlack,
          ),
        )
            .animate()
            .scale(
          begin: const Offset(0.5, 0.5),
          end: const Offset(1, 1),
          duration: 500.ms,
          curve: Curves.elasticOut,
        ),

        const SizedBox(height: 20),

        Text(
          'CREATE ACCOUNT',
          style: GoogleFonts.orbitron(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryGold,
            letterSpacing: 3,
          ),
        )
            .animate()
            .fadeIn(delay: 200.ms)
            .slideY(begin: 0.3, end: 0),

        const SizedBox(height: 8),

        Text(
          'Join us and start receiving AI trading signals',
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        )
            .animate()
            .fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Name field
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            icon: Iconsax.user,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              if (value.length < 2) {
                return 'Name must be at least 2 characters';
              }
              return null;
            },
          ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 16),

          // Email field
          _buildTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            icon: Iconsax.sms,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ).animate().fadeIn(delay: 500.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 16),

          // Password field
          _buildTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a strong password',
            icon: Iconsax.lock,
            isPassword: true,
            showPassword: _isPasswordVisible,
            onTogglePassword: () {
              setState(() => _isPasswordVisible = !_isPasswordVisible);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 16),

          // Confirm password field
          _buildTextField(
            controller: _confirmPasswordController,
            label: 'Confirm Password',
            hint: 'Re-enter your password',
            icon: Iconsax.lock_1,
            isPassword: true,
            showPassword: _isConfirmPasswordVisible,
            onTogglePassword: () {
              setState(() =>
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _passwordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ).animate().fadeIn(delay: 700.ms).slideX(begin: -0.2, end: 0),

          const SizedBox(height: 20),

          // Terms and conditions checkbox
          _buildTermsCheckbox()
              .animate()
              .fadeIn(delay: 800.ms),

          const SizedBox(height: 30),

          // Register button
          _buildRegisterButton()
              .animate()
              .fadeIn(delay: 900.ms)
              .slideY(begin: 0.3, end: 0),

          const SizedBox(height: 20),

          // Login link
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Already have an account? ',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Sign In',
                  style: GoogleFonts.rajdhani(
                    color: AppColors.primaryGold,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 1000.ms),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isPassword = false,
    bool showPassword = false,
    VoidCallback? onTogglePassword,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword && !showPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: GoogleFonts.rajdhani(
        color: AppColors.textPrimary,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primaryGold),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            showPassword ? Iconsax.eye : Iconsax.eye_slash,
            color: AppColors.textMuted,
          ),
          onPressed: onTogglePassword,
        )
            : null,
        filled: true,
        fillColor: AppColors.cardBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: AppColors.primaryGold,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.sellRed),
        ),
        labelStyle: GoogleFonts.rajdhani(color: AppColors.textSecondary),
        hintStyle: GoogleFonts.rajdhani(color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return GestureDetector(
      onTap: () {
        if (!_agreeToTerms) {
          _showTermsAndConditionsDialog();
        } else {
          setState(() => _agreeToTerms = false);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.cardBlack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _agreeToTerms
                ? AppColors.buyGreen.withOpacity(0.5)
                : AppColors.primaryGold.withOpacity(0.2),
            width: _agreeToTerms ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _agreeToTerms
                      ? AppColors.buyGreen
                      : AppColors.textMuted,
                  width: 2,
                ),
                color: _agreeToTerms
                    ? AppColors.buyGreen
                    : Colors.transparent,
                boxShadow: _agreeToTerms
                    ? [
                  BoxShadow(
                    color: AppColors.buyGreen.withOpacity(0.4),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ]
                    : null,
              ),
              child: _agreeToTerms
                  ? const Icon(
                Icons.check,
                size: 18,
                color: Colors.white,
              )
                  .animate()
                  .scale(duration: 200.ms, curve: Curves.elasticOut)
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      children: [
                        const TextSpan(text: 'I agree to the '),
                        TextSpan(
                          text: 'Terms & Conditions',
                          style: GoogleFonts.rajdhani(
                            color: AppColors.primaryGold,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _agreeToTerms
                        ? '✓ Terms accepted'
                        : 'Tap to read and accept',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: _agreeToTerms
                          ? AppColors.buyGreen
                          : AppColors.textMuted,
                      fontWeight: _agreeToTerms
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              _agreeToTerms ? Iconsax.tick_circle : Iconsax.arrow_right_3,
              color: _agreeToTerms
                  ? AppColors.buyGreen
                  : AppColors.primaryGold,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: _agreeToTerms
            ? AppGradients.primaryGradient
            : LinearGradient(
          colors: [
            AppColors.textMuted,
            AppColors.textMuted.withOpacity(0.8),
          ],
        ),
        boxShadow: _agreeToTerms
            ? [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ]
            : null,
      ),
      child: ElevatedButton(
        onPressed: (_isLoading || !_agreeToTerms) ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation(AppColors.primaryBlack),
          ),
        )
            : Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'CREATE ACCOUNT',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlack,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              Iconsax.arrow_right_3,
              color: AppColors.primaryBlack,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// TERMS AND CONDITIONS DIALOG WITH SWIPE TO AGREE
// ============================================================================

class TermsAndConditionsDialog extends StatefulWidget {
  final VoidCallback onAgreed;

  const TermsAndConditionsDialog({
    super.key,
    required this.onAgreed,
  });

  @override
  State<TermsAndConditionsDialog> createState() =>
      _TermsAndConditionsDialogState();
}

class _TermsAndConditionsDialogState extends State<TermsAndConditionsDialog> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;
  double _swipeProgress = 0.0;
  bool _isSwipeComplete = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 50) {
      if (!_hasScrolledToBottom) {
        setState(() {
          _hasScrolledToBottom = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onSwipeUpdate(double progress) {
    setState(() {
      _swipeProgress = progress.clamp(0.0, 1.0);
    });
  }

  void _onSwipeComplete() {
    setState(() {
      _isSwipeComplete = true;
    });

    // Haptic feedback could be added here

    Future.delayed(const Duration(milliseconds: 500), () {
      widget.onAgreed();
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Iconsax.document_text,
                    color: AppColors.primaryGold,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Terms & Conditions',
                        style: GoogleFonts.orbitron(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      Text(
                        'Please read carefully',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Iconsax.close_circle,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),

          // Scroll indicator
          if (!_hasScrolledToBottom)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.waitOrange.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.waitOrange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Iconsax.arrow_down,
                    color: AppColors.waitOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Scroll down to read all terms before agreeing',
                      style: GoogleFonts.rajdhani(
                        fontSize: 13,
                        color: AppColors.waitOrange,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .fadeIn()
                .then()
                .fadeOut(delay: 2000.ms),

          const SizedBox(height: 10),

          // Terms content
          Expanded(
            child: Scrollbar(
              controller: _scrollController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _buildTermsContent(),
              ),
            ),
          ),

          // Swipe to agree button
          _buildSwipeToAgreeButton(),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          '1. Acceptance of Terms',
          'By accessing and using the Trade Signals Pro application ("App"), you accept and agree to be bound by the terms and conditions of this agreement. If you do not agree to these terms, please do not use the App.',
        ),
        _buildSection(
          '2. Description of Service',
          'Trade Signals Pro provides AI-powered trading signals and market analysis for educational and informational purposes only. The signals generated by our AI system are based on technical analysis and should not be considered as financial advice.',
        ),
        _buildSection(
          '3. Risk Disclaimer',
          'Trading in financial markets involves substantial risk of loss and is not suitable for all investors. Past performance is not indicative of future results. The signals provided by this App do not guarantee profits and you may lose some or all of your invested capital. You should only trade with money you can afford to lose.',
        ),
        _buildSection(
          '4. No Financial Advice',
          'The information provided through this App is for general informational and educational purposes only. It is not intended to be and does not constitute financial advice, investment advice, trading advice, or any other advice. You should consult with a qualified financial advisor before making any investment decisions.',
        ),
        _buildSection(
          '5. User Responsibilities',
          'You are solely responsible for:\n• Your trading decisions and their outcomes\n• Maintaining the confidentiality of your account\n• All activities that occur under your account\n• Complying with all applicable laws and regulations in your jurisdiction',
        ),
        _buildSection(
          '6. Account Registration',
          'To use certain features of the App, you must register for an account. You agree to provide accurate, current, and complete information during registration. Account approval is subject to admin verification via OTP.',
        ),
        _buildSection(
          '7. Intellectual Property',
          'All content, features, and functionality of the App, including but not limited to text, graphics, logos, icons, and software, are the exclusive property of Trade Signals Pro and are protected by international copyright, trademark, and other intellectual property laws.',
        ),
        _buildSection(
          '8. Privacy Policy',
          'Your use of the App is also governed by our Privacy Policy. By using the App, you consent to the collection and use of your information as described in our Privacy Policy. We use Firebase for authentication and data storage.',
        ),
        _buildSection(
          '9. API Usage',
          'The App uses third-party APIs including Binance, Alpha Vantage, and AI services for market data and analysis. We are not responsible for any errors, delays, or inaccuracies in the data provided by these services.',
        ),
        _buildSection(
          '10. Limitation of Liability',
          'To the maximum extent permitted by law, Trade Signals Pro and its affiliates, officers, directors, employees, and agents shall not be liable for any indirect, incidental, special, consequential, or punitive damages, including but not limited to loss of profits, data, or trading losses, arising out of or relating to your use of the App.',
        ),
        _buildSection(
          '11. Indemnification',
          'You agree to indemnify and hold harmless Trade Signals Pro from any claims, damages, losses, liabilities, costs, and expenses arising out of or relating to your use of the App or your violation of these Terms.',
        ),
        _buildSection(
          '12. Modifications',
          'We reserve the right to modify these Terms at any time. Your continued use of the App after any such changes constitutes your acceptance of the new Terms.',
        ),
        _buildSection(
          '13. Termination',
          'We may terminate or suspend your account and access to the App at our sole discretion, without prior notice, for conduct that we believe violates these Terms or is harmful to other users or the App.',
        ),
        _buildSection(
          '14. Governing Law',
          'These Terms shall be governed by and construed in accordance with the laws of the jurisdiction in which the company operates, without regard to its conflict of law provisions.',
        ),
        _buildSection(
          '15. Contact Information',
          'If you have any questions about these Terms, please contact us at support@tradesignalspro.com',
        ),

        const SizedBox(height: 20),

        // Last updated
        Center(
          child: Text(
            'Last Updated: December 2024',
            style: GoogleFonts.rajdhani(
              fontSize: 12,
              color: AppColors.textMuted,
            ),
          ),
        ),

        const SizedBox(height: 100), // Extra space for scrolling
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeToAgreeButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          if (!_hasScrolledToBottom)
            Text(
              'Please scroll to the bottom to enable agreement',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            )
          else if (!_isSwipeComplete)
            Text(
              'Swipe right to agree to terms',
              style: GoogleFonts.rajdhani(
                fontSize: 12,
                color: AppColors.primaryGold,
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 12),

          // Swipe button
          _SwipeToAgreeButton(
            enabled: _hasScrolledToBottom && !_isSwipeComplete,
            progress: _swipeProgress,
            isComplete: _isSwipeComplete,
            onSwipeUpdate: _onSwipeUpdate,
            onSwipeComplete: _onSwipeComplete,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SWIPE TO AGREE BUTTON WIDGET
// ============================================================================

class _SwipeToAgreeButton extends StatefulWidget {
  final bool enabled;
  final double progress;
  final bool isComplete;
  final Function(double) onSwipeUpdate;
  final VoidCallback onSwipeComplete;

  const _SwipeToAgreeButton({
    required this.enabled,
    required this.progress,
    required this.isComplete,
    required this.onSwipeUpdate,
    required this.onSwipeComplete,
  });

  @override
  State<_SwipeToAgreeButton> createState() => _SwipeToAgreeButtonState();
}

class _SwipeToAgreeButtonState extends State<_SwipeToAgreeButton>
    with SingleTickerProviderStateMixin {
  double _dragPosition = 0;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final buttonWidth = MediaQuery.of(context).size.width - 80;
    final thumbSize = 56.0;
    final maxDrag = buttonWidth - thumbSize - 8;

    return Container(
      height: 64,
      width: buttonWidth,
      decoration: BoxDecoration(
        color: widget.isComplete
            ? AppColors.buyGreen.withOpacity(0.2)
            : widget.enabled
            ? AppColors.cardBlack
            : AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: widget.isComplete
              ? AppColors.buyGreen
              : widget.enabled
              ? AppColors.primaryGold.withOpacity(0.5)
              : AppColors.textMuted.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: widget.enabled && !widget.isComplete
            ? [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.2),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ]
            : null,
      ),
      child: Stack(
        children: [
          // Progress fill
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            width: _dragPosition + thumbSize + 4,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: widget.isComplete
                    ? [
                  AppColors.buyGreen.withOpacity(0.4),
                  AppColors.buyGreen.withOpacity(0.6),
                ]
                    : [
                  AppColors.primaryGold.withOpacity(0.2),
                  AppColors.primaryGold.withOpacity(0.4),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
          ),

          // Center text
          Center(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: widget.isComplete
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Iconsax.tick_circle,
                    color: AppColors.buyGreen,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'AGREED!',
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.buyGreen,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              )
                  .animate()
                  .scale(duration: 300.ms, curve: Curves.elasticOut)
                  : AnimatedBuilder(
                animation: _shimmerController,
                builder: (context, child) {
                  return ShaderMask(
                    shaderCallback: (bounds) {
                      return LinearGradient(
                        colors: widget.enabled
                            ? [
                          AppColors.textMuted,
                          AppColors.primaryGold,
                          AppColors.textMuted,
                        ]
                            : [
                          AppColors.textMuted,
                          AppColors.textMuted,
                          AppColors.textMuted,
                        ],
                        stops: [
                          (_shimmerController.value - 0.3).clamp(0.0, 1.0),
                          _shimmerController.value,
                          (_shimmerController.value + 0.3).clamp(0.0, 1.0),
                        ],
                      ).createShader(bounds);
                    },
                    child: Text(
                      widget.enabled
                          ? 'SWIPE TO AGREE >>>'
                          : 'READ TERMS FIRST',
                      style: GoogleFonts.orbitron(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 2,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // Draggable thumb
          if (!widget.isComplete)
            Positioned(
              left: 4 + _dragPosition,
              top: 4,
              child: GestureDetector(
                onHorizontalDragUpdate: widget.enabled
                    ? (details) {
                  setState(() {
                    _dragPosition += details.delta.dx;
                    _dragPosition = _dragPosition.clamp(0, maxDrag);
                    widget.onSwipeUpdate(_dragPosition / maxDrag);
                  });
                }
                    : null,
                onHorizontalDragEnd: widget.enabled
                    ? (details) {
                  if (_dragPosition >= maxDrag * 0.9) {
                    setState(() {
                      _dragPosition = maxDrag;
                    });
                    widget.onSwipeComplete();
                  } else {
                    setState(() {
                      _dragPosition = 0;
                    });
                    widget.onSwipeUpdate(0);
                  }
                }
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  width: thumbSize,
                  height: thumbSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: widget.enabled
                        ? AppGradients.primaryGradient
                        : LinearGradient(
                      colors: [
                        AppColors.textMuted,
                        AppColors.textMuted.withOpacity(0.8),
                      ],
                    ),
                    boxShadow: widget.enabled
                        ? [
                      BoxShadow(
                        color: AppColors.primaryGold.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                        : null,
                  ),
                  child: Icon(
                    Iconsax.arrow_right_3,
                    color: widget.enabled
                        ? AppColors.primaryBlack
                        : AppColors.surfaceBlack,
                    size: 24,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}