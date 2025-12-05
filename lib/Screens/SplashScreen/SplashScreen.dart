import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:trading_signals_app/Screens/HomeScreens/HomeScreen.dart';

import '../../AppTheme/App_theme.dart';
import '../../Providers/Auth_provider.dart';
import '../AuthScreens/Login_Screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  String _loadingText = 'Initializing...';

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _checkAutoLoginAndNavigate();
  }

  Future<void> _checkAutoLoginAndNavigate() async {
    // Show splash for minimum time
    await Future.delayed(const Duration(milliseconds: 2000));

    if (!mounted) return;

    setState(() {
      _loadingText = 'Checking credentials...';
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // Try auto-login
    final autoLoginSuccess = await authProvider.checkAutoLogin();

    if (!mounted) return;

    setState(() {
      _loadingText = autoLoginSuccess ? 'Welcome back!' : 'Loading...';
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    // Navigate based on auth status - Simplified to only 2 states
    Widget destination;

    if (autoLoginSuccess && authProvider.status == AuthStatus.authenticated) {
      destination = const Homescreen();
    } else {
      // Any other status goes to login
      destination = const LoginScreen();
    }

    // IMPORTANT: Use Navigator.of(context, rootNavigator: true) to ensure
    // the new route is created within the Provider scope
    if (mounted) {
      Navigator.of(context, rootNavigator: false).pushReplacement(
        MaterialPageRoute(
          builder: (context) => destination,
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: Stack(
        children: [
          // Animated background pattern
          _buildBackgroundPattern(),

          // Main content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo with glow effect
                _buildAnimatedLogo(),

                const SizedBox(height: 40),

                // App name
                _buildAppName(),

                const SizedBox(height: 16),

                // Tagline
                _buildTagline(),

                const SizedBox(height: 60),

                // Loading indicator
                _buildLoadingIndicator(),
              ],
            ),
          ),

          // Bottom decoration
          _buildBottomDecoration(),
        ],
      ),
    );
  }

  Widget _buildBackgroundPattern() {
    return AnimatedBuilder(
      animation: _rotateController,
      builder: (context, child) {
        return CustomPaint(
          painter: _BackgroundPatternPainter(
            rotation: _rotateController.value * 2 * 3.14159,
            color: AppColors.primaryGold.withOpacity(0.03),
          ),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGold,
                AppColors.darkGold,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryGold.withOpacity(0.3 + _pulseController.value * 0.3),
                blurRadius: 30 + _pulseController.value * 20,
                spreadRadius: 5 + _pulseController.value * 10,
              ),
            ],
          ),
          child: Center(
            child: Icon(
              Icons.show_chart_rounded,
              size: 70,
              color: AppColors.primaryBlack,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
          duration: const Duration(seconds: 2),
          color: Colors.white.withOpacity(0.3),
        );
      },
    );
  }

  Widget _buildAppName() {
    return Text(
      'TRADE SIGNALS',
      style: GoogleFonts.orbitron(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryGold,
        letterSpacing: 6,
        shadows: [
          Shadow(
            color: AppColors.primaryGold.withOpacity(0.5),
            blurRadius: 20,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 800.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOutBack);
  }

  Widget _buildTagline() {
    return Text(
      'AI-POWERED TRADING INTELLIGENCE',
      style: GoogleFonts.rajdhani(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
        letterSpacing: 3,
      ),
    )
        .animate()
        .fadeIn(delay: 1000.ms, duration: 800.ms)
        .slideY(begin: 0.3, end: 0);
  }

  Widget _buildLoadingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 200,
          child: LinearProgressIndicator(
            backgroundColor: AppColors.surfaceBlack,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGold),
            minHeight: 3,
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .shimmer(
          duration: const Duration(seconds: 2),
          color: AppColors.lightGold,
        ),
        const SizedBox(height: 16),
        Text(
          _loadingText,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppColors.textMuted,
            letterSpacing: 2,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .fadeIn()
            .then()
            .fadeOut(delay: 1500.ms),
      ],
    ).animate().fadeIn(delay: 1500.ms, duration: 500.ms);
  }

  Widget _buildBottomDecoration() {
    return Positioned(
      bottom: 40,
      left: 0,
      right: 0,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFeatureChip('Real-time Data'),
              const SizedBox(width: 12),
              _buildFeatureChip('AI Analysis'),
              const SizedBox(width: 12),
              _buildFeatureChip('Pro Signals'),
            ],
          )
              .animate()
              .fadeIn(delay: 2000.ms, duration: 600.ms)
              .slideY(begin: 0.5, end: 0),
          const SizedBox(height: 20),
          Text(
            'v1.0.0',
            style: GoogleFonts.rajdhani(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ).animate().fadeIn(delay: 2500.ms),
        ],
      ),
    );
  }

  Widget _buildFeatureChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.rajdhani(
          fontSize: 11,
          color: AppColors.primaryGold,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BackgroundPatternPainter extends CustomPainter {
  final double rotation;
  final Color color;

  _BackgroundPatternPainter({
    required this.rotation,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = size.width > size.height ? size.width : size.height;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);

    // Draw concentric circles
    for (var i = 0; i < 10; i++) {
      final radius = (maxRadius / 10) * i;
      canvas.drawCircle(center, radius, paint);
    }

    // Draw radial lines
    for (var i = 0; i < 12; i++) {
      final angle = (3.14159 * 2 / 12) * i;
      final x = center.dx + maxRadius * _cos(angle);
      final y = center.dy + maxRadius * _sin(angle);
      canvas.drawLine(center, Offset(x, y), paint);
    }

    canvas.restore();
  }

  double _cos(double angle) => (angle - (angle * angle * angle / 6)).clamp(-1, 1);
  double _sin(double angle) => (angle - (angle * angle * angle / 6) + (angle * angle * angle * angle * angle / 120)).clamp(-1, 1);

  @override
  bool shouldRepaint(covariant _BackgroundPatternPainter oldDelegate) {
    return oldDelegate.rotation != rotation;
  }
}