import 'package:flutter/material.dart';
import 'package:saveme_project/domain/model/fixed_expese.dart';
import 'package:saveme_project/utils/colors.dart';
import 'confirm_dialog.dart';

class FixedExpensesCard extends StatefulWidget {
  final List<FixedExpense> expenses;
  final ValueChanged<FixedExpense> onAdd;
  final ValueChanged<FixedExpense> onRemove;
  final ValueChanged<VoidCallback>? onInitCallback;

  const FixedExpensesCard({
    super.key,
    required this.expenses,
    required this.onAdd,
    required this.onRemove,
    this.onInitCallback,
  });

  @override
  State<FixedExpensesCard> createState() => _FixedExpensesCardState();
}

class _FixedExpensesCardState extends State<FixedExpensesCard> {
  final _nameController = TextEditingController();
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _amountController.addListener(() {
      setState(() {});
    });

    widget.onInitCallback?.call(checkAndAddPendingExpense);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _total =>
      widget.expenses.fold<double>(0, (sum, e) => sum + e.amount);

  double get _currentAmount {
    final amount = double.tryParse(_amountController.text.trim());
    return amount ?? 0;
  }

  bool get _showTotal => widget.expenses.isNotEmpty || _currentAmount > 0;

  // Public method to check and add pending expense
  void checkAndAddPendingExpense() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isNotEmpty && amount != null && amount > 0) {
      widget.onAdd(FixedExpense(name: name, amount: amount));
      _nameController.clear();
      _amountController.clear();
    }
  }

  void _addExpense() {
    final name = _nameController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (name.isEmpty || amount == null || amount <= 0) return;

    setState(() {
      widget.onAdd(FixedExpense(name: name, amount: amount));
    });

    _nameController.clear();
    _amountController.clear();
    FocusScope.of(context).unfocus();
  }

  Future<void> _confirmRemove(FixedExpense expense) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Remove Expense',
      message: 'Are you sure you want to remove ""?',
      boldText: expense.name,
      confirmText: 'Remove',
      confirmColor: Colors.red,
    );

    if (confirmed) {
      widget.onRemove(expense);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Monthly Expenses',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textBlack,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Rent, bills, gasoline, etc.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Material(
                color: AppColors.primaryGreen,
                shape: const CircleBorder(),
                elevation: 2,
                child: IconButton(
                  tooltip: 'Add expense',
                  onPressed: _addExpense,
                  icon: const Icon(Icons.add, color: AppColors.textWhite),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextField(
                  controller: _nameController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration('Name'),
                  onSubmitted: (_) {
                    FocusScope.of(context).nextFocus();
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  onSubmitted: (_) => _addExpense(),
                  decoration: _inputDecoration('Amount', prefixText: '\$'),
                ),
              ),
            ],
          ),
          if (widget.expenses.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...widget.expenses.map(
              (e) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        e.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textBlack,
                        ),
                      ),
                    ),
                    Text(
                      '\$${e.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Remove',
                      onPressed: () => _confirmRemove(e),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
              ),
            ),
          ],
          if (_showTotal) ...[
            const SizedBox(height: 14),
            Divider(color: Colors.black.withAlpha(20), height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Total Fixed Expenses:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                    ),
                  ),
                ),
                Text(
                  '\$${(_total + _currentAmount).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF3D00),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hintText, {String? prefixText}) {
    return InputDecoration(
      hintText: hintText,
      prefixText: prefixText,
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black.withAlpha(20)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black.withAlpha(20)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: AppColors.primaryGreen, width: 1.5),
      ),
    );
  }
}
