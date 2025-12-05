import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import '../../AppTheme/App_theme.dart';
import '../../Providers/Trading_provider.dart';

import '../../models/trading_models.dart';
import 'package:intl/intl.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _filterType = 'all'; // all, buy, sell, wait

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBlack,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // App Bar
            _buildAppBar(),

            // Filter Chips
            SliverToBoxAdapter(
              child: _buildFilterChips()
                  .animate()
                  .fadeIn(delay: 100.ms),
            ),

            // Statistics Card
            SliverToBoxAdapter(
              child: _buildStatisticsCard()
                  .animate()
                  .fadeIn(delay: 200.ms)
                  .slideY(begin: 0.1, end: 0),
            ),

            // History List
            _buildHistoryList(),
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
        'SIGNAL HISTORY',
        style: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.primaryGold,
          letterSpacing: 2,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () {
            // Export or share history
          },
          icon: const Icon(
            Iconsax.export_1,
            color: AppColors.primaryGold,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {'key': 'all', 'label': 'All', 'icon': Iconsax.category},
      {'key': 'BUY', 'label': 'Buy', 'icon': Iconsax.arrow_up_3},
      {'key': 'SELL', 'label': 'Sell', 'icon': Iconsax.arrow_down},
      {'key': 'WAIT', 'label': 'Wait', 'icon': Iconsax.pause},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((filter) {
            final isSelected = _filterType == filter['key'];
            Color filterColor = AppColors.primaryGold;
            if (filter['key'] == 'BUY') filterColor = AppColors.buyGreen;
            if (filter['key'] == 'SELL') filterColor = AppColors.sellRed;
            if (filter['key'] == 'WAIT') filterColor = AppColors.waitOrange;

            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: GestureDetector(
                onTap: () => setState(() => _filterType = filter['key'] as String),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? filterColor.withOpacity(0.2)
                        : AppColors.cardBlack,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? filterColor
                          : AppColors.primaryGold.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        filter['icon'] as IconData,
                        size: 18,
                        color: isSelected ? filterColor : AppColors.textMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        filter['label'] as String,
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? filterColor
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildStatisticsCard() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        int total = trading.signalHistory.length;
        int buyCount = trading.signalHistory
            .where((s) => s.signalType == 'BUY')
            .length;
        int sellCount = trading.signalHistory
            .where((s) => s.signalType == 'SELL')
            .length;
        int waitCount = trading.signalHistory
            .where((s) => s.signalType == 'WAIT')
            .length;

        double avgConfidence = total > 0
            ? trading.signalHistory
            .map((s) => s.confidence)
            .reduce((a, b) => a + b) /
            total
            : 0;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardBlack,
                AppColors.surfaceBlack,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Iconsax.chart_1,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Statistics',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      label: 'Total',
                      value: total.toString(),
                      color: AppColors.primaryGold,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Buy',
                      value: buyCount.toString(),
                      color: AppColors.buyGreen,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Sell',
                      value: sellCount.toString(),
                      color: AppColors.sellRed,
                    ),
                  ),
                  Expanded(
                    child: _buildStatItem(
                      label: 'Wait',
                      value: waitCount.toString(),
                      color: AppColors.waitOrange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceBlack,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Average Confidence',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${avgConfidence.toStringAsFixed(1)}%',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryList() {
    return Consumer<TradingProvider>(
      builder: (context, trading, _) {
        List<TradingSignal> signals = trading.signalHistory;

        // Apply filter
        if (_filterType != 'all') {
          signals = signals
              .where((s) => s.signalType == _filterType)
              .toList();
        }

        if (signals.isEmpty) {
          return SliverToBoxAdapter(
            child: _buildEmptyState(),
          );
        }

        return SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
                  (context, index) {
                final signal = signals[index];
                return _buildHistoryItem(signal, index)
                    .animate()
                    .fadeIn(delay: Duration(milliseconds: 50 * index))
                    .slideX(begin: 0.1, end: 0);
              },
              childCount: signals.length,
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.cardBlack,
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
            ),
            child: Icon(
              Iconsax.document,
              size: 48,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Signals Yet',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start analyzing trading pairs to see your signal history here',
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

  Widget _buildHistoryItem(TradingSignal signal, int index) {
    final signalColor = _getSignalColor(signal.signalType);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: signalColor.withOpacity(0.3),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSignalDetails(signal),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Signal Type Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: signalColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: signalColor.withOpacity(0.3),
                    ),
                  ),
                  child: Icon(
                    _getSignalIcon(signal.signalType),
                    color: signalColor,
                    size: 24,
                  ),
                ),

                const SizedBox(width: 14),

                // Signal Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            signal.symbol,
                            style: GoogleFonts.orbitron(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: signalColor.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              signal.signalType,
                              style: GoogleFonts.rajdhani(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: signalColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Entry: \$${signal.entryPrice.toStringAsFixed(4)}',
                        style: GoogleFonts.rajdhani(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Confidence and Time
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${signal.confidence.toStringAsFixed(0)}%',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _formatDate(signal.createdAt),
                      style: GoogleFonts.rajdhani(
                        fontSize: 11,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),

                const SizedBox(width: 8),

                Icon(
                  Iconsax.arrow_right_3,
                  color: AppColors.textMuted,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSignalDetails(TradingSignal signal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          final signalColor = _getSignalColor(signal.signalType);

          return Container(
            decoration: BoxDecoration(
              color: AppColors.cardBlack,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              border: Border.all(
                color: signalColor.withOpacity(0.3),
              ),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                // Handle
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

                // Header
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: signalColor.withOpacity(0.2),
                        border: Border.all(
                          color: signalColor,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        _getSignalIcon(signal.signalType),
                        color: signalColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            signal.symbol,
                            style: GoogleFonts.orbitron(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            signal.signalType,
                            style: GoogleFonts.orbitron(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: signalColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${signal.confidence.toStringAsFixed(0)}%',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Price Details
                _buildDetailRow('Entry Price', '\$${signal.entryPrice.toStringAsFixed(6)}'),
                _buildDetailRow('Stop Loss', '\$${signal.stopLoss.toStringAsFixed(6)}', color: AppColors.sellRed),
                _buildDetailRow('Take Profit', '\$${signal.takeProfit.toStringAsFixed(6)}', color: AppColors.buyGreen),
                _buildDetailRow('Timeframe', signal.timeframe.toUpperCase()),
                _buildDetailRow('Duration', signal.tradeDuration),
                _buildDetailRow('R:R Ratio', '1:${signal.riskRewardRatio.toStringAsFixed(2)}'),

                const SizedBox(height: 20),

                // Analysis
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceBlack,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analysis',
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        signal.analysis,
                        style: GoogleFonts.rajdhani(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Created At
                Center(
                  child: Text(
                    'Created: ${DateFormat('MMM dd, yyyy HH:mm').format(signal.createdAt)}',
                    style: GoogleFonts.rajdhani(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.rajdhani(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Color _getSignalColor(String signalType) {
    switch (signalType.toUpperCase()) {
      case 'BUY':
        return AppColors.buyGreen;
      case 'SELL':
        return AppColors.sellRed;
      default:
        return AppColors.waitOrange;
    }
  }

  IconData _getSignalIcon(String signalType) {
    switch (signalType.toUpperCase()) {
      case 'BUY':
        return Iconsax.arrow_up_3;
      case 'SELL':
        return Iconsax.arrow_down;
      default:
        return Iconsax.pause;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM dd').format(date);
    }
  }
}