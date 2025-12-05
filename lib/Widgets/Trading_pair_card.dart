import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iconsax/iconsax.dart';
import '../AppTheme/App_theme.dart';
import '../models/trading_models.dart';

class TradingPairCard extends StatelessWidget {
  final TradingPair pair;
  final VoidCallback onTap;

  const TradingPairCard({
    super.key,
    required this.pair,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
              color: AppColors.primaryGold.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            splashColor: AppColors.primaryGold.withOpacity(0.1),
            highlightColor: AppColors.primaryGold.withOpacity(0.05),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and category
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: AppGradients.primaryGradient,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGold.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(
                          _getCategoryIcon(),
                          color: AppColors.primaryBlack,
                          size: 24,
                        ),
                      ),

                      // Category badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getCategoryColor().withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _getCategoryColor().withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          pair.category.toUpperCase(),
                          style: GoogleFonts.rajdhani(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Symbol
                  Text(
                    pair.symbol,
                    style: GoogleFonts.orbitron(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      letterSpacing: 1,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Name
                  Text(
                    pair.name,
                    style: GoogleFonts.rajdhani(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const Spacer(),

                  // Action hint
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tap to analyze',
                        style: GoogleFonts.rajdhani(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.primaryGold.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Iconsax.arrow_right_3,
                          color: AppColors.primaryGold,
                          size: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (pair.category) {
      case 'crypto':
        return Iconsax.bitcoin_card;
      case 'forex':
        return Iconsax.dollar_circle;
      case 'commodities':
        return Iconsax.chart_2;
      default:
        return Iconsax.chart_1;
    }
  }

  Color _getCategoryColor() {
    switch (pair.category) {
      case 'crypto':
        return AppColors.primaryGold;
      case 'forex':
        return AppColors.info;
      case 'commodities':
        return AppColors.warning;
      default:
        return AppColors.textSecondary;
    }
  }
}