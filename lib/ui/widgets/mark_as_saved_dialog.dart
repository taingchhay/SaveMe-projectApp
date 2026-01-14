import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:saveme_project/domain/model/tracking_each_day.dart';
import 'package:saveme_project/domain/model/user_saving_plan.dart';
import 'package:saveme_project/utils/colors.dart';
import 'confirm_dialog.dart';

class MarkAsSavedDialog extends StatefulWidget {
  final UserSavingPlan plan;
  final DateTime day;
  final TrackingEachDay? existingTracking;

  const MarkAsSavedDialog({
    super.key,
    required this.plan,
    required this.day,
    this.existingTracking,
  });

  @override
  State<MarkAsSavedDialog> createState() => _MarkAsSavedDialogState();
}

class _MarkAsSavedDialogState extends State<MarkAsSavedDialog> {
  final List<TextEditingController> _expenseDescriptionControllers = [];
  final List<TextEditingController> _expenseAmountControllers = [];
  final List<Category> _selectedCategories = [];
  late final TextEditingController _savingAmountController;

  @override
  void initState() {
    super.initState();

    final initialAmount = widget.existingTracking?.newSavingAmount ??
        widget.plan.dynamicSuggestedSaving;

    _savingAmountController = TextEditingController(
      text: initialAmount > 0 ? initialAmount.toStringAsFixed(2) : '0.00',
    );

    _savingAmountController.addListener(() {
      setState(() {});
    });

    final existing = widget.existingTracking;
    if (existing != null && existing.dailyItems.isNotEmpty) {
      for (final e in existing.dailyItems) {
        _expenseDescriptionControllers.add(TextEditingController(text: e.name));
        _expenseAmountControllers.add(
          TextEditingController(
              text: e.amount == 0 ? '' : e.amount.toStringAsFixed(2)),
        );
        _selectedCategories.add(e.category);
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
    _savingAmountController.dispose();
    super.dispose();
  }

  void _addExpenseRow() {
    setState(() {
      _expenseDescriptionControllers.add(TextEditingController());
      _expenseAmountControllers.add(TextEditingController());
      _selectedCategories.add(Category.food);
    });
  }

  void _removeExpenseRow(int index) {
    if (_expenseDescriptionControllers.length <= 1) return;

    setState(() {
      _expenseDescriptionControllers[index].dispose();
      _expenseAmountControllers[index].dispose();
      _expenseDescriptionControllers.removeAt(index);
      _expenseAmountControllers.removeAt(index);
      _selectedCategories.removeAt(index);
    });
  }

  Future<void> _confirmRemoveExpense(int index) async {
    if (_expenseDescriptionControllers.length <= 1) return;

    final expenseName = _expenseDescriptionControllers[index].text.trim();
    final displayName = expenseName.isEmpty ? 'this expense' : expenseName;

    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Remove Expense',
      message: 'Are you sure you want to remove ""?',
      boldText: displayName,
      confirmText: 'Remove',
      confirmColor: Colors.red,
    );

    if (confirmed) {
      _removeExpenseRow(index);
    }
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
    final hasEstimatedSpending =
        widget.plan.spendingPerDay != null && widget.plan.spendingPerDay! > 0;
    final totalSpent = _calculateTotalSpent();
    final suggestedSaving = widget.plan.dynamicSuggestedSaving;

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
                if (hasEstimatedSpending) ...[
                  _buildEstimatedSpendingCard(),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Spending for the day',
                        style: TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 16),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Add expense',
                      onPressed: _addExpenseRow,
                      icon: const Icon(Icons.add_circle,
                          color: AppColors.primaryGreen),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ..._buildExpenseRows(),
                const SizedBox(height: 12),
                _buildTotalSpending(totalSpent),
                const SizedBox(height: 24),
                _buildSuggestedSaving(suggestedSaving),
                const SizedBox(height: 16),
                _buildCalculationInfo(totalSpent, hasEstimatedSpending),
                const SizedBox(height: 16),
                const SizedBox(height: 32),
                _buildActionButtons(suggestedSaving),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEstimatedSpendingCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF9E6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Row(
        children: [
          const Icon(Icons.shopping_cart_outlined, color: Color(0xFFFF9800)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your estimated daily spending',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFFFF9800)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'This is the amount you planned to spend per day',
                  style: TextStyle(fontSize: 12, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${widget.plan.spendingPerDay!.toStringAsFixed(2)}',
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFF9800)),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExpenseRows() {
    return List<Widget>.generate(_expenseDescriptionControllers.length, (i) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCategoryDropdown(i),
              const SizedBox(height: 12),
              TextField(
                controller: _expenseDescriptionControllers[i],
                decoration: InputDecoration(
                  hintText: 'What did you buy?',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primaryGreen),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expenseAmountControllers[i],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Amount',
                        prefixText: '\$ ',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide:
                              const BorderSide(color: AppColors.primaryGreen),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  if (_expenseDescriptionControllers.length > 1) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _confirmRemoveExpense(i),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Remove expense',
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCategoryDropdown(int index) {
    final categoryIcons = {
      Category.food: Icons.fastfood,
      Category.drink: Icons.local_drink,
      Category.entertainment: Icons.movie,
      Category.shopping: Icons.shopping_bag,
      Category.transport: Icons.directions_car,
    };

    final categoryLabels = {
      Category.food: 'Food',
      Category.drink: 'Drink',
      Category.entertainment: 'Entertainment',
      Category.shopping: 'Shopping',
      Category.transport: 'Transport',
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Category>(
          value: _selectedCategories[index],
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
          items: Category.values.map((cat) {
            return DropdownMenuItem(
              value: cat,
              child: Row(
                children: [
                  Icon(categoryIcons[cat],
                      size: 20, color: const Color(0xFFFF9800)),
                  const SizedBox(width: 12),
                  Text(categoryLabels[cat]!),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedCategories[index] = value;
              });
            }
          },
        ),
      ),
    );
  }

  Widget _buildSuggestedSaving(double suggestedAmount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.accentGreen,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.lightGreen.withAlpha(128)),
      ),
      child: Column(
        children: [
          const Text(
            'Suggested saving amount',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '\$',
                style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen),
              ),
              Flexible(
                child: IntrinsicWidth(
                  child: TextField(
                    controller: _savingAmountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryGreen,
                      height: 1.0,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: UnderlineInputBorder(
                        borderSide:
                            BorderSide(color: AppColors.primaryGreen, width: 2),
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                      isDense: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.edit, size: 14, color: AppColors.primaryGreen),
              SizedBox(width: 4),
              Text(
                'Tap to edit this amount',
                style: TextStyle(color: AppColors.primaryGreen, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationInfo(double totalSpent, bool hasEstimatedSpending) {
    final todaySavingAmount = double.tryParse(_savingAmountController.text) ??
        widget.plan.dynamicSuggestedSaving;

    final currentRemaining = widget.plan.remainingAmount;
    final futureRemaining = currentRemaining - todaySavingAmount;
    final futureRemainingClamped = futureRemaining < 0 ? 0.0 : futureRemaining;

    final totalDaysLeft =
        widget.plan.daysLeftToGoalDate ?? widget.plan.suggestedDaysToGoal ?? 1;
    final futureDaysLeft = totalDaysLeft - 1; // Subtract today
    final futureDaysLeftClamped = futureDaysLeft < 1 ? 1 : futureDaysLeft;

    final futureDynamicRate = futureRemainingClamped > 0
        ? futureRemainingClamped / futureDaysLeftClamped
        : 0.0;

    final daysNeededAtNewRate = futureDynamicRate > 0
        ? (futureRemainingClamped / futureDynamicRate).ceil()
        : (futureRemainingClamped > 0 ? futureDaysLeftClamped : 0);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'If you save \$${todaySavingAmount.toStringAsFixed(2)} today',
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4F46E5)),
          ),
          const SizedBox(height: 12),
          if (futureRemainingClamped > 0 &&
              futureDynamicRate != todaySavingAmount) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFDEF7EC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your new suggested daily saving:',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF047857),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${futureDynamicRate.toStringAsFixed(2)}/day',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF047857),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Remaining: \$${futureRemainingClamped.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today,
                  color: Color(0xFF4F46E5), size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '$daysNeededAtNewRate more ${daysNeededAtNewRate == 1 ? "day" : "days"} to reach your goal',
                  style:
                      const TextStyle(fontSize: 14, color: Color(0xFF4F46E5)),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          if (hasEstimatedSpending) ...[
            const SizedBox(height: 8),
            Builder(
              builder: (context) {
                final budgetRemaining =
                    (widget.plan.spendingPerDay ?? 0) - totalSpent;
                final remainingFromBudget =
                    budgetRemaining < 0 ? 0.0 : budgetRemaining;

                return Column(
                  children: [
                    Text(
                      'Remaining from budget: \$${remainingFromBudget.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: budgetRemaining < 0
                            ? Colors.red
                            : const Color(0xFF6B7280),
                        fontWeight: budgetRemaining < 0
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                    ),
                    if (budgetRemaining < 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Over budget by \$${(-budgetRemaining).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.red,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButtons(double suggestedAmount) {
    final isEditing = widget.existingTracking != null;

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
              final editedSavingAmount =
                  double.tryParse(_savingAmountController.text);
              if (editedSavingAmount == null || editedSavingAmount <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter a valid saving amount'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final expenses = <DailySpending>[];
              for (var i = 0; i < _expenseDescriptionControllers.length; i++) {
                final name = _expenseDescriptionControllers[i].text.trim();
                final amount =
                    double.tryParse(_expenseAmountControllers[i].text) ?? 0.0;
                if (name.isEmpty && amount == 0.0) continue;
                expenses.add(
                  DailySpending(
                    name: name,
                    amount: amount,
                    category: _selectedCategories[i],
                  ),
                );
              }

              Navigator.pop(
                context,
                TrackingEachDay(
                  date: widget.day,
                  dailyItem: expenses,
                  newSavingAmount: editedSavingAmount,
                  suggestedSavingAmount: widget.plan.suggestedSavingAmount,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isEditing ? 'Update' : 'Mark as Saved'),
          ),
        ),
      ],
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

  Widget _buildTotalSpending(double totalSpent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total Spending:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF111827),
            ),
          ),
          Text(
            '\$${totalSpent.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFFFF3D00),
            ),
          ),
        ],
      ),
    );
  }
}
