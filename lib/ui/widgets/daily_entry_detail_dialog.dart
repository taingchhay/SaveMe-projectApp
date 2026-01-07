import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveme_project/domain/model/daily_record.dart';
import 'package:saveme_project/utils/colors.dart';

class DailyEntryDetailDialog extends StatelessWidget {
  final DailyRecord record;
  final VoidCallback onEdit;

  const DailyEntryDetailDialog({
    super.key,
    required this.record,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 600),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(context),
                const SizedBox(height: 16),
                _buildSectionTitle('Spending items'),
                const SizedBox(height: 10),
                if (record.spendingItems.isEmpty)
                  const Text(
                    'No spending items recorded.',
                    style: TextStyle(color: AppColors.textGrey),
                  )
                else
                  ...record.spendingItems.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _buildSpendingRow(
                        name: e.spendingItemName,
                        amount: e.spendingItemAmount,
                      ),
                    ),
                  ),
                const SizedBox(height: 10),
                _buildKeyValue('Total spending', record.totalSpending),
                const SizedBox(height: 8),
                _buildKeyValue('Suggested saving', record.suggestedSaving),
                const SizedBox(height: 8),
                _buildKeyValue('Actual saved', record.savedAmountThisDay),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Close'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onEdit();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Edit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(Icons.calendar_today, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Text(
              DateFormat('MMM dd, yyyy').format(record.date),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildSpendingRow({required String name, required double amount}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name.isEmpty ? 'Spending' : name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyValue(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGrey)),
        Text(
          '\$${value.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}
