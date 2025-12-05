import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../../AppTheme/App_theme.dart';
import 'login_screen.dart';

class PendingApprovalScreen extends StatefulWidget {
  const PendingApprovalScreen({super.key});

  @override
  State<PendingApprovalScreen> createState() => _PendingApprovalScreenState();
}

class _PendingApprovalScreenState extends State<PendingApprovalScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // Animated waiting icon
              _buildWaitingIcon(),

              const SizedBox(height: 40),

              // Title
              Text(
                'PENDING APPROVAL',
                style: GoogleFonts.orbitron(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                  letterSpacing: 3,
                ),
              )
                  .animate()
                  .fadeIn(delay: 300.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 16),

              // Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Your account registration has been received.\nPlease wait for admin approval to access the trading signals.',
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              )
                  .animate()
                  .fadeIn(delay: 500.ms),

              const SizedBox(height: 40),

              // Info cards
              _buildInfoCards(),

              const Spacer(),

              // Back to login button
              _buildBackToLoginButton()
                  .animate()
                  .fadeIn(delay: 800.ms)
                  .slideY(begin: 0.3, end: 0),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingIcon() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.cardBlack,
            border: Border.all(
              color: AppColors.waitOrange.withOpacity(0.5),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.waitOrange
                    .withOpacity(0.2 + _pulseController.value * 0.2),
                blurRadius: 30 + _pulseController.value * 20,
                spreadRadius: 5 + _pulseController.value * 10,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Iconsax.timer_1,
              size: 60,
              color: AppColors.waitOrange,
            ),
          ),
        );
      },
    )
        .animate(onPlay: (c) => c.repeat())
        .rotate(
      begin: 0,
      end: 0.02,
      duration: const Duration(seconds: 2),
    )
        .then()
        .rotate(
      begin: 0.02,
      end: -0.02,
      duration: const Duration(seconds: 2),
    )
        .then()
        .rotate(
      begin: -0.02,
      end: 0,
      duration: const Duration(seconds: 2),
    );
  }

  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          icon: Iconsax.sms,
          title: 'OTP Sent to Admin',
          description: 'A verification code has been sent to the administrator',
          color: AppColors.info,
        ).animate().fadeIn(delay: 600.ms).slideX(begin: -0.2, end: 0),

        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Iconsax.verify,
          title: 'Verification Process',
          description: 'Admin will verify your account within 24 hours',
          color: AppColors.warning,
        ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.2, end: 0),

        const SizedBox(height: 12),

        _buildInfoCard(
          icon: Iconsax.notification,
          title: 'Get Notified',
          description: 'You will receive an email once approved',
          color: AppColors.buyGreen,
        ).animate().fadeIn(delay: 800.ms).slideX(begin: -0.2, end: 0),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.15),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.rajdhani(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: GoogleFonts.rajdhani(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackToLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: () {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        },
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.primaryGold, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Iconsax.arrow_left, color: AppColors.primaryGold),
            const SizedBox(width: 12),
            Text(
              'BACK TO LOGIN',
              style: GoogleFonts.orbitron(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}