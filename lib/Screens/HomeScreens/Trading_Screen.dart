import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:iconsax/iconsax.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../AppTheme/App_theme.dart';
import '../../Providers/Trading_provider.dart';
import '../../Widgets/Indicator_Chip.dart';
import '../../Widgets/Signal_Card.dart';

import '../../models/trading_models.dart';


class TradingScreen extends StatefulWidget {
  final TradingPair pair;

  const TradingScreen({super.key, required this.pair});

  @override
  State<TradingScreen> createState() => _TradingScreenState();
}

class _TradingScreenState extends State<TradingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
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
        child: Consumer<TradingProvider>(
          builder: (context, trading, _) {
            return CustomScrollView(
              slivers: [
                // App Bar
                _buildAppBar(trading),

                // Price Header
                SliverToBoxAdapter(
                  child: _buildPriceHeader(trading)
                      .animate()
                      .fadeIn(duration: 400.ms),
                ),

                // Timeframe Selector
                SliverToBoxAdapter(
                  child: _buildTimeframeSelector(trading)
                      .animate()
                      .fadeIn(delay: 100.ms),
                ),

                // Chart
                SliverToBoxAdapter(
                  child: _buildChart(trading)
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),
                ),

                // Technical Indicators
                SliverToBoxAdapter(
                  child: _buildIndicatorsSection(trading)
                      .animate()
                      .fadeIn(delay: 300.ms),
                ),

                // Trading Style Selector
                SliverToBoxAdapter(
                  child: _buildTradingStyleSelector(trading)
                      .animate()
                      .fadeIn(delay: 400.ms),
                ),

                // AI Analysis Button
                SliverToBoxAdapter(
                  child: _buildAnalyzeButton(trading)
                      .animate()
                      .fadeIn(delay: 500.ms)
                      .slideY(begin: 0.2, end: 0),
                ),

                // Signal Result
                if (trading.currentSignal != null)
                  SliverToBoxAdapter(
                    child: SignalCard(signal: trading.currentSignal!)
                        .animate()
                        .fadeIn()
                        .scale(begin: const Offset(0.95, 0.95)),
                  ),

                // Bottom spacing
                const SliverToBoxAdapter(
                  child: SizedBox(height: 30),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(TradingProvider trading) {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppColors.primaryBlack,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.cardBlack,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryGold.withOpacity(0.3),
            ),
          ),
          child: const Icon(
            Iconsax.arrow_left,
            color: AppColors.primaryGold,
            size: 20,
          ),
        ),
      ),
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              widget.pair.category == 'crypto'
                  ? Iconsax.bitcoin_card
                  : Iconsax.dollar_circle,
              color: AppColors.primaryGold,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.pair.symbol,
                style: GoogleFonts.orbitron(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
              Text(
                widget.pair.name,
                style: GoogleFonts.rajdhani(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () => trading.refreshData(),
          icon: Icon(
            Iconsax.refresh,
            color: trading.status == TradingStatus.loading
                ? AppColors.textMuted
                : AppColors.primaryGold,
          ),
        ),
        IconButton(
          onPressed: () {
            // Add to favorites
          },
          icon: const Icon(
            Iconsax.star,
            color: AppColors.primaryGold,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceHeader(TradingProvider trading) {
    final isPositive = trading.priceChange24h >= 0;

    return Container(
      margin: const EdgeInsets.all(20),
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
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGold.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Price',
                    style: GoogleFonts.rajdhani(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trading.currentPrice > 0
                        ? _formatPrice(trading.currentPrice)
                        : 'Loading...',
                    style: GoogleFonts.orbitron(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isPositive
                      ? AppColors.buyGreen.withOpacity(0.15)
                      : AppColors.sellRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isPositive
                        ? AppColors.buyGreen.withOpacity(0.3)
                        : AppColors.sellRed.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive
                          ? Iconsax.arrow_up_3
                          : Iconsax.arrow_down,
                      color: isPositive
                          ? AppColors.buyGreen
                          : AppColors.sellRed,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isPositive ? '+' : ''}${trading.priceChange24h.toStringAsFixed(2)}%',
                      style: GoogleFonts.orbitron(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isPositive
                            ? AppColors.buyGreen
                            : AppColors.sellRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                label: '24h High',
                value: _formatPrice(trading.high24h),
                color: AppColors.buyGreen,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
              _buildStatItem(
                label: '24h Low',
                value: _formatPrice(trading.low24h),
                color: AppColors.sellRed,
              ),
              Container(
                width: 1,
                height: 40,
                color: AppColors.primaryGold.withOpacity(0.2),
              ),
              _buildStatItem(
                label: 'Volume',
                value: _formatVolume(trading.volume24h),
                color: AppColors.info,
              ),
            ],
          ),
        ],
      ),
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
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.rajdhani(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildTimeframeSelector(TradingProvider trading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeframe',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: trading.availableTimeframes.map((tf) {
                final isSelected = trading.selectedTimeframe == tf;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => trading.setTimeframe(tf),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppGradients.primaryGradient
                            : null,
                        color: isSelected ? null : AppColors.cardBlack,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.primaryGold.withOpacity(0.2),
                        ),
                      ),
                      child: Text(
                        tf.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? AppColors.primaryBlack
                              : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(TradingProvider trading) {
    if (trading.status == TradingStatus.loading) {
      return Container(
        height: 300,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primaryGold,
                strokeWidth: 2,
              ),
              const SizedBox(height: 16),
              Text(
                'Loading chart data...',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (trading.candles.isEmpty) {
      return Container(
        height: 300,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBlack,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Iconsax.chart_fail,
                size: 48,
                color: AppColors.textMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'No chart data available',
                style: GoogleFonts.rajdhani(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 320,
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(20),
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
      child: Column(
        children: [
          // Chart header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Price Chart',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
              Row(
                children: [
                  _buildChartLegend('Bullish', AppColors.buyGreen),
                  const SizedBox(width: 16),
                  _buildChartLegend('Bearish', AppColors.sellRed),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Chart
          Expanded(
            child: _buildCandlestickChart(trading.candles),
          ),
        ],
      ),
    );
  }

  Widget _buildChartLegend(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildCandlestickChart(List<CandleData> candles) {
    // Take last 50 candles for display
    final displayCandles = candles.take(50).toList().reversed.toList();

    if (displayCandles.isEmpty) return const SizedBox();

    // Calculate min and max for Y axis
    double minY = displayCandles.map((c) => c.low).reduce((a, b) => a < b ? a : b);
    double maxY = displayCandles.map((c) => c.high).reduce((a, b) => a > b ? a : b);
    double padding = (maxY - minY) * 0.1;
    minY -= padding;
    maxY += padding;

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: (maxY - minY) / 5,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.primaryGold.withOpacity(0.1),
              strokeWidth: 1,
            );
          },
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatPrice(value),
                  style: GoogleFonts.rajdhani(
                    fontSize: 10,
                    color: AppColors.textMuted,
                  ),
                );
              },
            ),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: displayCandles.length.toDouble() - 1,
        minY: minY,
        maxY: maxY,
        lineBarsData: [
          // Close price line
          LineChartBarData(
            spots: displayCandles.asMap().entries.map((e) {
              return FlSpot(e.key.toDouble(), e.value.close);
            }).toList(),
            isCurved: true,
            curveSmoothness: 0.2,
            gradient: LinearGradient(
              colors: [
                AppColors.primaryGold,
                AppColors.primaryGold.withOpacity(0.5),
              ],
            ),
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.primaryGold.withOpacity(0.2),
                  AppColors.primaryGold.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBorder: BorderSide(
              color: AppColors.primaryGold.withOpacity(0.3),
            ),
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                return LineTooltipItem(
                  _formatPrice(spot.y),
                  GoogleFonts.orbitron(
                    color: AppColors.primaryGold,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIndicatorsSection(TradingProvider trading) {
    final indicators = trading.indicators;
    if (indicators == null) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Technical Indicators',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              IndicatorChip(
                label: 'RSI',
                value: indicators.rsi?.toStringAsFixed(1) ?? 'N/A',
                status: _getRSIStatus(indicators.rsi),
              ),
              IndicatorChip(
                label: 'Trend',
                value: indicators.trend?.toUpperCase() ?? 'N/A',
                status: indicators.trend == 'bullish'
                    ? 'positive'
                    : indicators.trend == 'bearish'
                    ? 'negative'
                    : 'neutral',
              ),
              IndicatorChip(
                label: 'MACD',
                value: indicators.macdHistogram != null
                    ? (indicators.macdHistogram! > 0 ? 'Bullish' : 'Bearish')
                    : 'N/A',
                status: indicators.macdHistogram != null
                    ? (indicators.macdHistogram! > 0 ? 'positive' : 'negative')
                    : 'neutral',
              ),
              IndicatorChip(
                label: 'Momentum',
                value: indicators.momentum?.toUpperCase() ?? 'N/A',
                status: indicators.momentum == 'bullish' ||
                    indicators.momentum == 'oversold'
                    ? 'positive'
                    : indicators.momentum == 'bearish' ||
                    indicators.momentum == 'overbought'
                    ? 'negative'
                    : 'neutral',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getRSIStatus(double? rsi) {
    if (rsi == null) return 'neutral';
    if (rsi < 30) return 'positive'; // Oversold - buy signal
    if (rsi > 70) return 'negative'; // Overbought - sell signal
    return 'neutral';
  }

  Widget _buildTradingStyleSelector(TradingProvider trading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Trading Style',
            style: GoogleFonts.orbitron(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: trading.tradingStyles.map((style) {
                final isSelected = trading.tradingStyle == style['key'];
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => trading.setTradingStyle(style['key']!),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? AppGradients.primaryGradient
                            : null,
                        color: isSelected ? null : AppColors.cardBlack,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : AppColors.primaryGold.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            style['label']!,
                            style: GoogleFonts.rajdhani(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? AppColors.primaryBlack
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            style['duration']!,
                            style: GoogleFonts.rajdhani(
                              fontSize: 11,
                              color: isSelected
                                  ? AppColors.primaryBlack.withOpacity(0.7)
                                  : AppColors.textMuted,
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
        ],
      ),
    );
  }

  Widget _buildAnalyzeButton(TradingProvider trading) {
    final isLoading = trading.status == TradingStatus.analyzing;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Full AI Analysis Button
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: AppGradients.primaryGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGold.withOpacity(
                        0.3 + _pulseController.value * 0.2,
                      ),
                      blurRadius: 20 + _pulseController.value * 10,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () => trading.generateSignal(useFullAI: true),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(
                            AppColors.primaryBlack,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'ANALYZING...',
                        style: GoogleFonts.orbitron(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  )
                      : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Iconsax.cpu,
                        color: AppColors.primaryBlack,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'AI ANALYSIS',
                        style: GoogleFonts.orbitron(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlack,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 12),

          // Quick Analysis Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () => trading.generateSignal(useFullAI: false),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: AppColors.primaryGold.withOpacity(0.5),
                  width: 2,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Iconsax.flash_1,
                    color: AppColors.primaryGold,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'QUICK SIGNAL',
                    style: GoogleFonts.orbitron(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGold,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    if (price == 0) return '-';
    if (price >= 1000) {
      return '\$${price.toStringAsFixed(2)}';
    } else if (price >= 1) {
      return '\$${price.toStringAsFixed(4)}';
    } else {
      return '\$${price.toStringAsFixed(6)}';
    }
  }

  String _formatVolume(double volume) {
    if (volume >= 1000000000) {
      return '${(volume / 1000000000).toStringAsFixed(2)}B';
    } else if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(2)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(2)}K';
    }
    return volume.toStringAsFixed(2);
  }
}