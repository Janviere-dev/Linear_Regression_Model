import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ResultCard extends StatelessWidget {
  final double minutes;

  const ResultCard({super.key, required this.minutes});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Estimated Delivery Time',
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            '${minutes.toStringAsFixed(1)} minutes',
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.accentEnd),
          ),
        ],
      ),
    );
  }
}
