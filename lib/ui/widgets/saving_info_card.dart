import 'package:flutter/material.dart';
import 'package:saveme_project/utils/colors.dart';

class SavingInfoCard extends StatelessWidget {
  final String title;
  final String amount;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  final Color shadowColor;

  const SavingInfoCard({
    super.key,
    required this.title,
    required this.amount,
    required this.description,
    required this.icon,
    required this.gradientColors,
    required this.shadowColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.textWhite, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style:
                      const TextStyle(color: AppColors.textWhite, fontSize: 14),
                  softWrap: true,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.textWhite,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(color: AppColors.textWhite70, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
