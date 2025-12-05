import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:trading_signals_app/Screens/HomeScreens/Trading_Screen.dart' show TradingScreen;
import '../../AppTheme/App_theme.dart';
import '../../Widgets/MarketStats_Card.dart';
import '../../Widgets/trading_pair_card.dart'; // FIXED: Changed from lowercase 'widgets' to uppercase 'Widgets'

import '../../providers/auth_provider.dart';
import '../../providers/trading_provider.dart';
import '../../models/trading_models.dart';

import '../AuthScreens/Login_Screen.dart';
import '../History&SettingScreens/History_Screen.dart';
import '../History&SettingScreens/Setting_screens.dart';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  String _selectedCategory = 'all';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            _buildHomeContent(),
            const HistoryScreen(),
            const SettingsScreen(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(),
    );
  }

  Widget _buildHomeContent() {
    return RefreshIndicator(
      onRefresh: () async {
        final trading = Provider.of<TradingProvider>(context, listen: false);
        await trading.refreshData();
      },
      color: AppColors.primaryGold,
      backgroundColor: AppColors.cardBlack,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(child: _buildSearchBar()),
          SliverToBoxAdapter(child: _buildMarketOverview()),
          SliverToBoxAdapter(child: _buildCategoryTabs()),
          SliverToBoxAdapter(child: _buildSectionHeader()),
          _buildTradingPairsGrid(),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 80,
      floating: true,
      pinned: true,
      backgroundColor: AppColors.primaryBlack,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primaryGold.withOpacity(0.1),
                AppColors.primaryBlack,
              ],
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: AppGradients.primaryGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGold.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.show_chart_rounded,
              color: AppColors.primaryBlack,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TRADE SIGNALS',
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                  letterSpacing: 2,
                ),
              ),
              Text(
                'AI-Powered Analysis',
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.cardBlack,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primaryGold.withOpacity(0.2),
                  ),
                ),
                child: const Icon(
                  Iconsax.notification,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.sellRed,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ),
        Consumer<AuthProvider>(
          builder: (context, auth, _) {
            return PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'logout') {
                  _showLogoutDialog();
                } else if (value == 'settings') {
                  setState(() => _currentIndex = 2);
                }
              },
              offset: const Offset(0, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: AppColors.cardBlack,
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'profile',
                  child: Row(
                    children: [
                      const Icon(Iconsax.user, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        auth.user?.displayName ?? 'User',
                        style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Row(
                    children: [
                      const Icon(Iconsax.setting_2, color: AppColors.textSecondary, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        'Settings',
                        style: GoogleFonts.rajdhani(color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Iconsax.logout, color: AppColors.sellRed, size: 18),
                      const SizedBox(width: 12),
                      Text(
                        'Logout',
                        style: GoogleFonts.rajdhani(color: AppColors.sellRed),
                      ),
                    ],
                  ),
                ),
              ],
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppGradients.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Iconsax.user,
                  color: AppColors.primaryBlack,
                  size: 20,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.primaryGold.withOpacity(0.3)),
        ),
        title: Row(
          children: [
            const Icon(Iconsax.logout, color: AppColors.sellRed),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: GoogleFonts.orbitron(
                color: AppColors.textPrimary,
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
              if (context.mounted) {
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

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() => _searchQuery = value);
        },
        style: GoogleFonts.rajdhani(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
        decoration: InputDecoration(
          hintText: 'Search trading pairs...',
          hintStyle: GoogleFonts.rajdhani(
            color: AppColors.textMuted,
            fontSize: 15,
          ),
          prefixIcon: const Icon(
            Iconsax.search_normal,
            color: AppColors.primaryGold,
            size: 20,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            onPressed: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
            icon: const Icon(
              Icons.close,
              color: AppColors.textMuted,
              size: 18,
            ),
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildMarketOverview() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.chart_2,
                  color: AppColors.primaryGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Market Overview',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: MarketStatsCard(
                  title: 'BTC/USDT',
                  value: '\$97,234.56',
                  change: '+2.45%',
                  isPositive: true,
                  icon: Iconsax.bitcoin_card,
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.2, end: 0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MarketStatsCard(
                  title: 'ETH/USDT',
                  value: '\$3,456.78',
                  change: '+1.23%',
                  isPositive: true,
                  icon: Iconsax.coin_1,
                ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.2, end: 0),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = [
      {'id': 'all', 'name': 'All', 'icon': Iconsax.category},
      {'id': 'crypto', 'name': 'Crypto', 'icon': Iconsax.bitcoin_card},
      {'id': 'forex', 'name': 'Forex', 'icon': Iconsax.dollar_circle},
      {'id': 'commodities', 'name': 'Gold', 'icon': Iconsax.chart_1},
    ];

    return Container(
      height: 50,
      margin: const EdgeInsets.only(top: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category['id'];

          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = category['id'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                gradient: isSelected ? AppGradients.primaryGradient : null,
                color: isSelected ? null : AppColors.cardBlack,
                borderRadius: BorderRadius.circular(12),
                border: isSelected
                    ? null
                    : Border.all(
                  color: AppColors.primaryGold.withOpacity(0.2),
                ),
                boxShadow: isSelected
                    ? [
                  BoxShadow(
                    color: AppColors.primaryGold.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 18,
                    color: isSelected
                        ? AppColors.primaryBlack
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    category['name'] as String,
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? AppColors.primaryBlack
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildSectionHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryGold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Iconsax.flash_1,
                  color: AppColors.primaryGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Trading Pairs',
                style: GoogleFonts.orbitron(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: AppColors.cardBlack,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
            ),
            child: Consumer<TradingProvider>(
              builder: (context, trading, _) {
                final filteredPairs = _getFilteredPairs(trading);
                return Text(
                  '${filteredPairs.length} pairs',
                  style: GoogleFonts.rajdhani(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TradingPair> _getFilteredPairs(TradingProvider trading) {
    List<TradingPair> pairs = trading.popularPairs;

    // Filter by category
    if (_selectedCategory != 'all') {
      pairs = pairs.where((p) => p.category == _selectedCategory).toList();
    }

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      pairs = pairs.where((p) {
        return p.symbol.toLowerCase().contains(query) ||
            p.name.toLowerCase().contains(query) ||
            p.baseAsset.toLowerCase().contains(query);
      }).toList();
    }

    return pairs;
  }

  Widget _buildTradingPairsGrid() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        final filteredPairs = _getFilteredPairs(trading);

        if (filteredPairs.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final pair = filteredPairs[index];
                return TradingPairCard(
                  pair: pair,
                  onTap: () => _navigateToTradingScreen(pair, trading),
                )
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 50 * index))
                    .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1, 1),
                  duration: 300.ms,
                );
              },
              childCount: filteredPairs.length,
            ),
          ),
        );
      },
    );
  }

  void _navigateToTradingScreen(TradingPair pair, TradingProvider trading) {
    trading.selectPair(pair);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TradingScreen(pair: pair), // FIXED: Pass the pair parameter
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBlack,
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
            ),
            child: Icon(
              Iconsax.search_normal,
              size: 36,
              color: AppColors.primaryGold.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'No Pairs Found',
            style: GoogleFonts.orbitron(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or category filter',
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        border: Border(
          top: BorderSide(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Iconsax.home_2,
              activeIcon: Iconsax.home_15,
              label: 'Home',
            ),
            _buildNavItem(
              index: 1,
              icon: Iconsax.clock,
              activeIcon: Iconsax.clock5,
              label: 'History',
            ),
            _buildNavItem(
              index: 2,
              icon: Iconsax.setting_2,
              activeIcon: Iconsax.setting,
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = _currentIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 20 : 16,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryGold.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.primaryGold : AppColors.textMuted,
              size: 22,
            ),
            if (isActive) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}