import 'package:flutter/material.dart';
import 'package:saveme_project/utils/colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? boldText;
  final String confirmText;
  final String cancelText;
  final Color? confirmColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    this.boldText,
    this.confirmText = 'Confirm',
    this.cancelText = 'Cancel',
    this.confirmColor,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.textBlack,
        ),
      ),
      content: boldText != null
          ? RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B7280),
                ),
                children: [
                  TextSpan(text: message.split('"')[0]),
                  TextSpan(
                    text: boldText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textBlack,
                    ),
                  ),
                  TextSpan(text: message.split('"').last),
                ],
              ),
            )
          : Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
            ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            cancelText,
            style: const TextStyle(
              color: Color(0xFF6B7280),
            ),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: confirmColor ?? Colors.red,
          ),
          child: Text(confirmText),
        ),
      ],
    );
  }

  static Future<bool> show({
    required BuildContext context,
    required String title,
    required String message,
    String? boldText,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    Color? confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => ConfirmDialog(
        title: title,
        message: message,
        boldText: boldText,
        confirmText: confirmText,
        cancelText: cancelText,
        confirmColor: confirmColor,
      ),
    );
    return result ?? false;
  }
}
