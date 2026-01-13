import 'package:flutter/material.dart';
import 'package:saveme_project/data/daily_record_data.dart';
import 'package:saveme_project/data/plan_history_data.dart';
import 'package:saveme_project/data/saving_goal_data.dart';
import 'package:saveme_project/domain/logic/date_generator.dart';
import 'package:saveme_project/domain/logic/saving_calculator.dart';
import 'package:saveme_project/domain/model/fixed_expenses_result.dart';
import 'package:saveme_project/domain/model/plan_calculation_result.dart';
import 'package:saveme_project/domain/model/saving_goal.dart';
import 'package:saveme_project/domain/model/user_finance.dart';
import 'package:saveme_project/ui/screens/saving_plan.dart';
import '../widgets/button.dart';
import '../widgets/custom_header.dart';
import '../widgets/input_label.dart';

class TrackingMode extends StatefulWidget {
  const TrackingMode({super.key});

  @override
  State<TrackingMode> createState() => _TrackingModeState();
}

class _TrackingModeState extends State<TrackingMode> {
  final _goalNameController = TextEditingController();
  final _goalPriceController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _estimateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<_ExpenseRowControllers> _expenseRows = [];

  @override
  void initState() {
    super.initState();
    _addExpenseRow();
  }

  void _addExpenseRow() =>
      setState(() => _expenseRows.add(_ExpenseRowControllers()));

  void _removeExpenseRow(int index) {
    if (_expenseRows.length <= 1) return;
    final row = _expenseRows.removeAt(index);
    row.dispose();
    setState(() {});
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _goalPriceController.dispose();
    _monthlyIncomeController.dispose();
    _estimateController.dispose();
    for (final r in _expenseRows) {
      r.dispose();
    }
    super.dispose();
  }

  String? _validateGoalName(String? v) => (v == null || v.trim().isEmpty)
      ? 'Please enter your saving goal name'
      : null;

  String? _validateGoalPrice(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Please enter goal price';
    }
    final n = double.tryParse(v.trim());
    if (n == null) {
      return 'Please enter a valid number';
    }
    if (n <= 0) {
      return 'Price must be greater than 0';
    }
    return null;
  }

  String? _validateMonthlyIncome(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Please enter your monthly income';
    }
    final n = double.tryParse(v.trim());
    if (n == null) {
      return 'Please enter a valid number';
    }
    if (n <= 0) {
      return 'Income must be greater than 0';
    }
    return null;
  }

  String? _validateExpenseName(String? value, int index) {
    final amountText = _expenseRows[index].amount.text.trim();
    final nameText = (value ?? '').trim();
    final eitherFilled = nameText.isNotEmpty || amountText.isNotEmpty;
    if (eitherFilled && nameText.isEmpty) {
      return 'Enter expense name';
    }
    return null;
  }

  String? _validateExpenseAmount(String? value, int index) {
    final nameText = _expenseRows[index].name.text.trim();
    final amountText = (value ?? '').trim();
    final eitherFilled = nameText.isNotEmpty || amountText.isNotEmpty;

    if (eitherFilled && amountText.isEmpty) {
      return 'Enter amount';
    }
    if (amountText.isNotEmpty && double.tryParse(amountText) == null) {
      return 'Invalid number';
    }
    return null;
  }

  String? _validateEstimatedDailySpending(String? v) {
    if (v != null && v.trim().isNotEmpty && double.tryParse(v.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  double _calculateTotalFixedExpenses() {
    double total = 0;
    for (final row in _expenseRows) {
      final amtText = row.amount.text.trim();
      if (amtText.isEmpty) {
        continue;
      }
      total += double.tryParse(amtText) ?? 0;
    }
    return total;
  }

  FixedExpensesResult _buildFixedExpenses() {
    final items = <FixedExpenseItem>[];
    double totalFixedMonthly = 0;

    for (final row in _expenseRows) {
      final name = row.name.text.trim();
      final amtText = row.amount.text.trim();
      if (name.isEmpty && amtText.isEmpty) {
        continue;
      }

      final amt = double.tryParse(amtText) ?? 0;
      totalFixedMonthly += amt;

      items.add(
        FixedExpenseItem(
          fixedExpenseItemName: name.isEmpty ? 'Fixed Expense' : name,
          fixedExpenseItemAmount: amt,
        ),
      );
    }

    if (items.isEmpty) {
      items.add(
        FixedExpenseItem(
          fixedExpenseItemName: 'Fixed Expenses',
          fixedExpenseItemAmount: 0,
        ),
      );
    }

    return FixedExpensesResult(
        items: items, totalFixedMonthly: totalFixedMonthly);
  }

  PlanCalculationResult _calculatePlan({
    required double goalPrice,
    required double monthlyIncome,
    required double totalFixedMonthly,
    required double estimatedDailySpending,
    required DateTime startDate,
  }) {
    final start = DateGenerator.dateOnly(startDate);

    final dailySaving = SavingCalculator.suggestedSavingPerDayFixed(
      monthlyIncome: monthlyIncome,
      totalFixedExpenses: totalFixedMonthly,
      estimatedDailySpending: estimatedDailySpending,
    );
    if (dailySaving <= 0) {
      return PlanCalculationResult.failure(
        message: 'Your expenses are too high to save with the current inputs.',
      );
    }

    final totalPlannedDays = SavingCalculator.daysToReachGoal(
      goalPrice: goalPrice,
      suggestedSavingPerDay: dailySaving,
    );
    if (totalPlannedDays <= 0) {
      return PlanCalculationResult.failure(
          message: 'Cannot calculate plan duration.');
    }

    final endDate = start.add(Duration(days: totalPlannedDays - 1));
    return PlanCalculationResult.success(
      dailySaving: dailySaving,
      totalPlannedDays: totalPlannedDays,
      endDate: endDate,
    );
  }

  Future<void> _handleStartPlan() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields correctly'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final fixed = _buildFixedExpenses();

      final monthlyIncome = double.parse(_monthlyIncomeController.text.trim());
      final goalPrice = double.parse(_goalPriceController.text.trim());
      final estimatedDaily = _estimateController.text.trim().isEmpty
          ? 0.0
          : (double.tryParse(_estimateController.text.trim()) ?? 0.0);

      final startDate = DateGenerator.dateOnly(DateTime.now());

      final plan = _calculatePlan(
        goalPrice: goalPrice,
        monthlyIncome: monthlyIncome,
        totalFixedMonthly: fixed.totalFixedMonthly,
        estimatedDailySpending: estimatedDaily,
        startDate: startDate,
      );

      if (!plan.canSave) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(plan.message ?? 'Cannot start plan.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final goal = SavingGoal(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        goalName: _goalNameController.text.trim(),
        goalPrice: goalPrice,
        startDate: startDate,
        targetDailySaving: plan.dailySaving!,
      );

      final finance = UserFinance(
        monthlyIncome: monthlyIncome,
        fixedMonthlyExpenses: fixed.items,
        estimatedDailySpending: _estimateController.text.trim().isEmpty
            ? null
            : double.tryParse(_estimateController.text.trim()),
      );

      await PlanHistoryData().saveCurrentPlanToHistory();
      await SavingGoalData().savePlan(
        goal: goal,
        finance: finance,
        totalPlannedDays: plan.totalPlannedDays!,
      );
      await DailyRecordData().clear();

      if (!context.mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SavingPlan(
            goalName: goal.goalName,
            goalPrice: goal.goalPrice,
            monthlyIncome: finance.monthlyIncome,
            totalFixedExpenses: fixed.totalFixedMonthly,
            startDate: goal.startDate,
            targetDate: plan.endDate!,
          ),
        ),
      );
    } catch (e, st) {
      debugPrint('Start plan failed: $e');
      debugPrint('$st');
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not start plan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalFixedPreview = _calculateTotalFixedExpenses();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: Column(
        children: [
          CustomHeader(
            title: 'Smart Tracking Mode',
            subtitle: 'Let\'s set up your saving plan',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 32),
                      InputLabel(
                          icon: Icons.flag_circle_outlined,
                          text: 'Saving Goal Name'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _goalNameController,
                        validator: _validateGoalName,
                        decoration: InputDecoration(
                          hintText: 'e.g., New Laptop, Vacation',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 24),
                      InputLabel(icon: Icons.price_change, text: 'Goal Price'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _goalPriceController,
                        keyboardType: TextInputType.number,
                        validator: _validateGoalPrice,
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: 'Enter target amount',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 20),
                      InputLabel(
                          icon: Icons.attach_money, text: 'Monthly Income'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _monthlyIncomeController,
                        keyboardType: TextInputType.number,
                        validator: _validateMonthlyIncome,
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: 'Enter your monthly income',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: InputLabel(
                                icon: Icons.expand,
                                text: 'Fixed Monthly Expenses'),
                          ),
                          IconButton(
                            tooltip: 'Add expense',
                            onPressed: _addExpenseRow,
                            icon: const Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Column(
                        children: [
                          for (int i = 0; i < _expenseRows.length; i++) ...[
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: TextFormField(
                                    controller: _expenseRows[i].name,
                                    validator: (v) =>
                                        _validateExpenseName(v, i),
                                    decoration: InputDecoration(
                                      hintText: 'e.g., Rent',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _expenseRows[i].amount,
                                    keyboardType: TextInputType.number,
                                    validator: (v) =>
                                        _validateExpenseAmount(v, i),
                                    onChanged: (_) => setState(() {}),
                                    decoration: InputDecoration(
                                      prefixText: '\$',
                                      hintText: '0.00',
                                      hintStyle:
                                          const TextStyle(color: Colors.grey),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  tooltip: 'Remove',
                                  onPressed: _expenseRows.length > 1
                                      ? () => _removeExpenseRow(i)
                                      : null,
                                  icon: const Icon(Icons.remove_circle_outline),
                                ),
                              ],
                            ),
                            if (i != _expenseRows.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Total Fixed Expenses: \$${totalFixedPreview.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 16),
                      InputLabel(
                          icon: Icons.attach_money,
                          text: 'Estimated Daily Spending (optional)'),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _estimateController,
                        keyboardType: TextInputType.number,
                        validator: _validateEstimatedDailySpending,
                        decoration: InputDecoration(
                          prefixText: '\$',
                          hintText: 'Average daily spending',
                          hintStyle: const TextStyle(color: Colors.grey),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        text: 'Start Now',
                        onPressed: _handleStartPlan,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class _ExpenseRowControllers {
  final TextEditingController name = TextEditingController();
  final TextEditingController amount = TextEditingController();

  void dispose() {
    name.dispose();
    amount.dispose();
  }
}
