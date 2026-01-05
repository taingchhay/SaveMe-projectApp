import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveme_project/utils/colors.dart';

class MarkAsSavedDialog extends StatefulWidget {
  final DateTime day;
  final double suggestedSaving;

  const MarkAsSavedDialog({
    super.key,
    required this.day,
    required this.suggestedSaving,
  });

  @override
  State<MarkAsSavedDialog> createState() => _MarkAsSavedDialogState();
}

class _MarkAsSavedDialogState extends State<MarkAsSavedDialog> {
  late final TextEditingController _spendingDescriptionController;
  late final TextEditingController _amountSpentController;
  late final TextEditingController _amountSavedController;

  @override
  void initState() {
    super.initState();
    _spendingDescriptionController = TextEditingController();
    _amountSpentController = TextEditingController(text: '0.00');
    _amountSavedController =
        TextEditingController(text: widget.suggestedSaving.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _spendingDescriptionController.dispose();
    _amountSpentController.dispose();
    _amountSavedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildTextField(
              label: 'What did you spend today?',
              hint: 'e.g., Groceries, Coffee, Lu...',
              controller: _spendingDescriptionController,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Amount Spent (\$)',
              controller: _amountSpentController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefix: '\$',
            ),
            const SizedBox(height: 24),
            _buildSuggestedSaving(),
            const SizedBox(height: 16),
            _buildTextField(
              label: 'Amount Saved (\$)',
              controller: _amountSavedController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              prefix: '\$',
            ),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM dd, yyyy').format(widget.day),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? prefix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedSaving() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.lightGreen.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lightbulb_outline, color: AppColors.primaryGreen),
              SizedBox(width: 8),
              Text('Suggested Saving',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${widget.suggestedSaving.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryGreen,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Based on your income and goal',
            style: TextStyle(color: AppColors.textGrey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Cancel'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final double? savedAmount =
                  double.tryParse(_amountSavedController.text);
              Navigator.pop(context, savedAmount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Mark as Saved'),
          ),
        ),
      ],
    );
  }
}
