import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../AppTheme/App_theme.dart';
import '../../Providers/Auth_provider.dart';
import '../../Providers/Trading_provider.dart';

import '../AuthScreens/Login_Screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            _buildAppBar(),

            // Profile Card
            SliverToBoxAdapter(
              child: _buildProfileCard()
                  .animate()
                  .fadeIn(delay: 100.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            // Settings Sections
            SliverToBoxAdapter(
              child: _buildSettingsSection(
                title: 'Trading Preferences',
                children: [
                  _buildTradingStyleSetting(),
                  _buildTimeframeSetting(),
                ],
              ).animate().fadeIn(delay: 200.ms),
            ),

            SliverToBoxAdapter(
              child: _buildSettingsSection(
                title: 'Notifications',
                children: [
                  _buildSwitchTile(
                    icon: Iconsax.notification,
                    title: 'Push Notifications',
                    subtitle: 'Get notified about new signals',
                    value: _notificationsEnabled,
                    onChanged: (v) => setState(() => _notificationsEnabled = v),
                  ),
                  _buildSwitchTile(
                    icon: Iconsax.volume_high,
                    title: 'Sound',
                    subtitle: 'Play sound for new signals',
                    value: _soundEnabled,
                    onChanged: (v) => setState(() => _soundEnabled = v),
                  ),
                  _buildSwitchTile(
                    icon: Iconsax.mobile,
                    title: 'Vibration',
                    subtitle: 'Vibrate for important alerts',
                    value: _vibrationEnabled,
                    onChanged: (v) => setState(() => _vibrationEnabled = v),
                  ),
                ],
              ).animate().fadeIn(delay: 300.ms),
            ),

            SliverToBoxAdapter(
              child: _buildSettingsSection(
                title: 'About',
                children: [
                  _buildActionTile(
                    icon: Iconsax.document_text,
                    title: 'Terms of Service',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Iconsax.shield_tick,
                    title: 'Privacy Policy',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Iconsax.message_question,
                    title: 'Help & Support',
                    onTap: () {},
                  ),
                  _buildActionTile(
                    icon: Iconsax.info_circle,
                    title: 'App Version',
                    trailing: Text(
                      'v1.0.0',
                      style: GoogleFonts.rajdhani(
                        color: AppColors.textMuted,
                      ),
                    ),
                    onTap: () {},
                  ),
                ],
              ).animate().fadeIn(delay: 400.ms),
            ),

            // Danger Zone
            SliverToBoxAdapter(
              child: _buildSettingsSection(
                title: 'Account',
                children: [
                  _buildActionTile(
                    icon: Iconsax.trash,
                    title: 'Clear Signal History',
                    titleColor: AppColors.waitOrange,
                    onTap: () => _showClearHistoryDialog(),
                  ),
                  _buildActionTile(
                    icon: Iconsax.profile_delete,
                    title: 'Delete Account',
                    titleColor: AppColors.sellRed,
                    onTap: () => _showDeleteAccountDialog(),
                  ),
                ],
              ).animate().fadeIn(delay: 450.ms),
            ),

            // Logout Button
            SliverToBoxAdapter(
              child: _buildLogoutButton()
                  .animate()
                  .fadeIn(delay: 500.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            // Bottom Padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.primaryBlack,
      automaticallyImplyLeading: false,
      title: Text(
        'SETTINGS',
        style: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGold,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGold.withOpacity(0.15),
                AppColors.cardBlack,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppGradients.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(0.3),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    (auth.user?.displayName ?? 'U')[0].toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryBlack,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      auth.user?.displayName ?? 'User',
                      style: GoogleFonts.orbitron(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.user?.email ?? '',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.buyGreen.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.buyGreen.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Iconsax.verify,
                            color: AppColors.buyGreen,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Verified',
                            style: GoogleFonts.rajdhani(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.buyGreen,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showEditProfileDialog(),
                icon: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBlack,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Iconsax.edit,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.orbitron(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlack,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
            ),
            child: Column(
              children: children,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradingStyleSetting() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.chart_2,
              color: AppColors.primaryGold,
              size: 22,
            ),
          ),
          title: Text(
            'Default Trading Style',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            trading.tradingStyle.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: AppColors.primaryGold,
            ),
          ),
          trailing: const Icon(
            Iconsax.arrow_right_3,
            color: AppColors.textMuted,
            size: 20,
          ),
          onTap: () => _showTradingStylePicker(trading),
        );
      },
    );
  }

  Widget _buildTimeframeSetting() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Iconsax.timer_1,
              color: AppColors.primaryGold,
              size: 22,
            ),
          ),
          title: Text(
            'Default Timeframe',
            style: GoogleFonts.rajdhani(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          subtitle: Text(
            trading.selectedTimeframe.toUpperCase(),
            style: GoogleFonts.rajdhani(
              fontSize: 13,
              color: AppColors.primaryGold,
            ),
          ),
          trailing: const Icon(
            Iconsax.arrow_right_3,
            color: AppColors.textMuted,
            size: 20,
          ),
          onTap: () => _showTimeframePicker(trading),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.primaryGold.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryGold,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.rajdhani(
          fontSize: 13,
          color: AppColors.textMuted,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryGold,
        activeTrackColor: AppColors.primaryGold.withOpacity(0.3),
        inactiveThumbColor: AppColors.textMuted,
        inactiveTrackColor: AppColors.surfaceBlack,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
    Color? titleColor,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: (titleColor ?? AppColors.primaryGold).withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: titleColor ?? AppColors.primaryGold,
          size: 22,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.rajdhani(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      trailing: trailing ??
          Icon(
            Iconsax.arrow_right_3,
            color: titleColor ?? AppColors.textMuted,
            size: 20,
          ),
      onTap: onTap,
    );
  }

  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.sellRed.withOpacity(0.5),
            width: 2,
          ),
        ),
        child: ElevatedButton(
          onPressed: () => _showLogoutDialog(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.logout,
                color: AppColors.sellRed,
              ),
              const SizedBox(width: 12),
              Text(
                'LOGOUT',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.sellRed,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTradingStylePicker(TradingProvider trading) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Trading Style',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 20),
            ...trading.tradingStyles.map((style) {
              final isSelected = trading.tradingStyle == style['key'];
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primaryGold.withOpacity(0.15)
                      : AppColors.surfaceBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primaryGold
                        : AppColors.primaryGold.withOpacity(0.2),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: ListTile(
                  onTap: () {
                    trading.setTradingStyle(style['key']!);
                    Navigator.pop(context);
                  },
                  title: Text(
                    style['label']!,
                    style: GoogleFonts.rajdhani(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryGold
                          : AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Text(
                    style['duration']!,
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(
                    Iconsax.tick_circle,
                    color: AppColors.primaryGold,
                  )
                      : null,
                ),
              );
            }).toList(),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  void _showTimeframePicker(TradingProvider trading) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBlack,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.textMuted,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Select Default Timeframe',
              style: GoogleFonts.orbitron(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: trading.availableTimeframes.map((tf) {
                final isSelected = trading.selectedTimeframe == tf;
                return GestureDetector(
                  onTap: () {
                    trading.setTimeframe(tf);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      gradient: isSelected
                          ? AppGradients.primaryGradient
                          : null,
                      color: isSelected ? null : AppColors.surfaceBlack,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.transparent
                            : AppColors.primaryGold.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      tf.toUpperCase(),
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primaryBlack
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController();
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    nameController.text = authProvider.user?.displayName ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.orbitron(
            color: AppColors.primaryGold,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: nameController,
          style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
          decoration: InputDecoration(
            labelText: 'Display Name',
            labelStyle: GoogleFonts.rajdhani(color: AppColors.textSecondary),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.primaryGold.withOpacity(0.3),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGold),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.rajdhani(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Update profile
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGold,
              foregroundColor: AppColors.primaryBlack,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.sellRed.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Iconsax.logout, color: AppColors.sellRed),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: GoogleFonts.orbitron(
                color: AppColors.sellRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.rajdhani(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.rajdhani(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await Provider.of<AuthProvider>(context, listen: false).logout();
              if (mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sellRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Logout',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.waitOrange.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Iconsax.trash, color: AppColors.waitOrange),
            const SizedBox(width: 12),
            Text(
              'Clear History',
              style: GoogleFonts.orbitron(
                color: AppColors.waitOrange,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete all your signal history. This action cannot be undone.',
          style: GoogleFonts.rajdhani(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.rajdhani(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Clear history
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Signal history cleared',
                    style: GoogleFonts.rajdhani(),
                  ),
                  backgroundColor: AppColors.cardBlack,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.waitOrange,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Clear',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.sellRed.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            Icon(Iconsax.profile_delete, color: AppColors.sellRed),
            const SizedBox(width: 12),
            Text(
              'Delete Account',
              style: GoogleFonts.orbitron(
                color: AppColors.sellRed,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          style: GoogleFonts.rajdhani(
            color: AppColors.textSecondary,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.rajdhani(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Delete account logic
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sellRed,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.rajdhani(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}