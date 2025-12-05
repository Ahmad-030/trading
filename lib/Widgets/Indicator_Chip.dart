import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../AppTheme/App_theme.dart';

class IndicatorChip extends StatelessWidget {
  final String label;
  final String value;
  final String status; // 'positive', 'negative', 'neutral'

  const IndicatorChip({
    super.key,
    required this.label,
    required this.value,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.rajdhani(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
              ),
              Text(
                value,
                style: GoogleFonts.orbitron(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case 'positive':
        return AppColors.buyGreen;
      case 'negative':
        return AppColors.sellRed;
      default:
        return AppColors.waitOrange;
    }
  }
}