import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveme_project/utils/colors.dart';

class ExpenseEntry {
  final String description;
  final double amount;

  const ExpenseEntry({
    required this.description,
    required this.amount,
  });
}

class MarkAsSavedResult {
  final List<ExpenseEntry> expenses;
  final double totalSpent;
  final double amountSaved;

  const MarkAsSavedResult({
    required this.expenses,
    required this.totalSpent,
    required this.amountSaved,
  });
}

class MarkAsSavedDialog extends StatefulWidget {
  final DateTime day;
  final double suggestedSaving;
  final List<ExpenseEntry>? initialExpenses;
  final double? initialAmountSaved;

  const MarkAsSavedDialog({
    super.key,
    required this.day,
    required this.suggestedSaving,
    this.initialExpenses,
    this.initialAmountSaved,
  });

  @override
  State<MarkAsSavedDialog> createState() => _MarkAsSavedDialogState();
}

class _MarkAsSavedDialogState extends State<MarkAsSavedDialog> {
  final List<TextEditingController> _expenseDescriptionControllers = [];
  final List<TextEditingController> _expenseAmountControllers = [];
  late final TextEditingController _amountSavedController;

  @override
  void initState() {
    super.initState();
    final initialSaved = widget.initialAmountSaved;
    _amountSavedController = TextEditingController(
      text: initialSaved == null
          ? widget.suggestedSaving.toStringAsFixed(2)
          : (initialSaved == 0 ? '' : initialSaved.toStringAsFixed(2)),
    );

    final initialExpenses = widget.initialExpenses;
    if (initialExpenses != null && initialExpenses.isNotEmpty) {
      for (final e in initialExpenses) {
        _expenseDescriptionControllers.add(
          TextEditingController(text: e.description),
        );
        _expenseAmountControllers.add(
          TextEditingController(
            text: e.amount == 0 ? '' : e.amount.toStringAsFixed(2),
          ),
        );
      }
    } else {
      _addExpenseRow();
    }
  }

  @override
  void dispose() {
    for (final c in _expenseDescriptionControllers) {
      c.dispose();
    }
    for (final c in _expenseAmountControllers) {
      c.dispose();
    }
    _amountSavedController.dispose();
    super.dispose();
  }

  void _addExpenseRow() {
    setState(() {
      _expenseDescriptionControllers.add(TextEditingController());
      _expenseAmountControllers.add(TextEditingController());
    });
  }

  void _removeExpenseRow(int index) {
    if (_expenseDescriptionControllers.length <= 1) return;

    setState(() {
      _expenseDescriptionControllers[index].dispose();
      _expenseAmountControllers[index].dispose();
      _expenseDescriptionControllers.removeAt(index);
      _expenseAmountControllers.removeAt(index);
    });
  }

  double _calculateTotalSpent() {
    double total = 0.0;
    for (final c in _expenseAmountControllers) {
      total += double.tryParse(c.text) ?? 0.0;
    }
    return total;
  }

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
                _buildHeader(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'What did you spend today?',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add expense',
                      onPressed: _addExpenseRow,
                      icon: const Icon(Icons.add_circle_outline),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._buildExpenseRows(),
                const SizedBox(height: 10),
                _buildTotalSpent(),
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
        ),
      ),
    );
  }

  List<Widget> _buildExpenseRows() {
    return List<Widget>.generate(_expenseDescriptionControllers.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: _buildTextField(
                label: null,
                hint: i == 0 ? 'e.g., Groceries, Coffee, Lunch' : 'Description',
                controller: _expenseDescriptionControllers[i],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: _buildTextField(
                label: null,
                controller: _expenseAmountControllers[i],
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefix: '\$',
                hintText: '0.00',
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(width: 4),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: IconButton(
                tooltip: 'Remove expense',
                onPressed: _expenseDescriptionControllers.length > 1
                    ? () => _removeExpenseRow(i)
                    : null,
                icon: const Icon(Icons.remove_circle_outline),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTotalSpent() {
    final total = _calculateTotalSpent();
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        'Total Spent: \$${total.toStringAsFixed(2)}',
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.black87,
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
    required String? label,
    required TextEditingController controller,
    String? hint,
    TextInputType? keyboardType,
    String? prefix,
    ValueChanged<String>? onChanged,
    String? hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hintText ?? hint,
            hintStyle: const TextStyle(color: Colors.grey),
            prefixText: prefix,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.primaryGreen),
            ),
            filled: true,
            fillColor: Colors.white,
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
        border: Border.all(color: AppColors.lightGreen.withAlpha(128)),
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
              final savedAmount = double.tryParse(_amountSavedController.text);
              if (savedAmount == null) {
                Navigator.pop(context);
                return;
              }

              final expenses = <ExpenseEntry>[];
              for (var i = 0; i < _expenseDescriptionControllers.length; i++) {
                final description =
                    _expenseDescriptionControllers[i].text.trim();
                final amount =
                    double.tryParse(_expenseAmountControllers[i].text) ?? 0.0;
                if (description.isEmpty && amount == 0.0) continue;
                expenses.add(
                    ExpenseEntry(description: description, amount: amount));
              }
              final totalSpent = expenses.fold(0.0, (sum, e) => sum + e.amount);

              Navigator.pop(
                context,
                MarkAsSavedResult(
                  expenses: expenses,
                  totalSpent: totalSpent,
                  amountSaved: savedAmount,
                ),
              );
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
