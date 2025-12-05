import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import '../AppTheme/App_theme.dart';
import '../models/trading_models.dart';

class SignalCard extends StatelessWidget {
  final TradingSignal signal;

  const SignalCard({super.key, required this.signal});

  @override
  Widget build(BuildContext context) {
    final signalColor = _getSignalColor();
    final signalIcon = _getSignalIcon();

    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardBlack,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: signalColor.withOpacity(0.5),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: signalColor.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Signal Header
          _buildSignalHeader(signalColor, signalIcon),

          // Signal Details
          _buildSignalDetails(signalColor),

          // Analysis Section
          _buildAnalysisSection(),

          // Reasons Section
          _buildReasonsSection(),

          // Risk/Reward Info
          _buildRiskRewardSection(signalColor),
        ],
      ),
    );
  }

  Widget _buildSignalHeader(Color signalColor, IconData signalIcon) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            signalColor.withOpacity(0.2),
            signalColor.withOpacity(0.05),
          ],
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Row(
        children: [
          // Signal Icon
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: signalColor.withOpacity(0.2),
              border: Border.all(
                color: signalColor,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: signalColor.withOpacity(0.4),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              signalIcon,
              color: signalColor,
              size: 32,
            ),
          )
              .animate(onPlay: (c) => c.repeat(reverse: true))
              .scale(
            begin: const Offset(1, 1),
            end: const Offset(1.05, 1.05),
            duration: const Duration(seconds: 1),
          ),

          const SizedBox(width: 20),

          // Signal Type and Confidence
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  signal.signalType,
                  style: GoogleFonts.orbitron(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: signalColor,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Confidence: ',
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '${signal.confidence.toStringAsFixed(0)}%',
                      style: GoogleFonts.orbitron(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: signalColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Timeframe Badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryGold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.primaryGold.withOpacity(0.3),
              ),
            ),
            child: Text(
              signal.timeframe.toUpperCase(),
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignalDetails(Color signalColor) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: _buildPriceBox(
              label: 'Entry',
              value: _formatPrice(signal.entryPrice),
              color: AppColors.primaryGold,
              icon: Iconsax.login,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPriceBox(
              label: 'Stop Loss',
              value: _formatPrice(signal.stopLoss),
              color: AppColors.sellRed,
              icon: Iconsax.close_circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildPriceBox(
              label: 'Take Profit',
              value: _formatPrice(signal.takeProfit),
              color: AppColors.buyGreen,
              icon: Iconsax.tick_circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBox({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
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
            style: GoogleFonts.orbitron(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceBlack,
        borderRadius: BorderRadius.circular(14),
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
                Iconsax.cpu,
                color: AppColors.primaryGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'AI Analysis',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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
    );
  }

  Widget _buildReasonsSection() {
    if (signal.reasons.isEmpty) return const SizedBox();

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Iconsax.message_question,
                color: AppColors.primaryGold,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Key Reasons',
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...signal.reasons.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primaryGold.withOpacity(0.2),
                    ),
                    child: Center(
                      child: Text(
                        '${entry.key + 1}',
                        style: GoogleFonts.orbitron(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryGold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: GoogleFonts.rajdhani(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: Duration(milliseconds: 100 * entry.key))
                .slideX(begin: 0.1, end: 0);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildRiskRewardSection(Color signalColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.surfaceBlack,
            AppColors.cardBlack,
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.primaryGold.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // Trade Duration
          Expanded(
            child: _buildInfoItem(
              icon: Iconsax.timer_1,
              label: 'Duration',
              value: signal.tradeDuration,
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
          // Risk/Reward Ratio
          Expanded(
            child: _buildInfoItem(
              icon: Iconsax.chart,
              label: 'R:R Ratio',
              value: '1:${signal.riskRewardRatio.toStringAsFixed(1)}',
            ),
          ),
          Container(
            width: 1,
            height: 50,
            color: AppColors.primaryGold.withOpacity(0.2),
          ),
          // Potential Profit
          Expanded(
            child: _buildInfoItem(
              icon: Iconsax.money_recive,
              label: 'Potential',
              value: '+${signal.potentialProfit.toStringAsFixed(1)}%',
              valueColor: AppColors.buyGreen,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryGold,
          size: 20,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.rajdhani(
            fontSize: 11,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Color _getSignalColor() {
    switch (signal.signalType.toUpperCase()) {
      case 'BUY':
        return AppColors.buyGreen;
      case 'SELL':
        return AppColors.sellRed;
      default:
        return AppColors.waitOrange;
    }
  }

  IconData _getSignalIcon() {
    switch (signal.signalType.toUpperCase()) {
      case 'BUY':
        return Iconsax.arrow_up_3;
      case 'SELL':
        return Iconsax.arrow_down;
      default:
        return Iconsax.pause;
    }
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
}