import 'package:flutter/material.dart';

class InfoBanner extends StatelessWidget {
  final String text;
  final String emoji;
  final Color? backgroundColor;

  const InfoBanner({
    Key? key,
    required this.text,
    this.emoji = '📊',
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.green[100]!,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[800],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}