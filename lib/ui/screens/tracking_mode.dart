import 'package:flutter/material.dart';
import 'package:saveme_project/domain/model/fixed_expese.dart';
import 'package:saveme_project/domain/model/user_saving_plan.dart';
import '../widgets/button.dart';
import '../widgets/custom_header.dart';
import '../widgets/fixed_expenses_card.dart';
import '../widgets/form_input_card.dart';

class TrackingMode extends StatefulWidget {
  const TrackingMode({super.key, required this.plan});

  final List<UserSavingPlan> plan;

  @override
  State<TrackingMode> createState() => _TrackingModeState();
}

class _TrackingModeState extends State<TrackingMode> {
  final _goalNameController = TextEditingController();
  final _goalPriceController = TextEditingController();
  final _monthlyIncomeController = TextEditingController();
  final _estimateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<FixedExpense> _fixedExpenses = [];
  VoidCallback? _checkPendingExpenseCallback;

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

  String? _validateEstimatedDailySpending(String? v) {
    if (v != null && v.trim().isNotEmpty && double.tryParse(v.trim()) == null) {
      return 'Please enter a valid number';
    }
    return null;
  }

  @override
  void dispose() {
    _goalNameController.dispose();
    _goalPriceController.dispose();
    _monthlyIncomeController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  void _startPlan() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    _checkPendingExpenseCallback?.call();

    final goalName = _goalNameController.text.trim();
    final goalPrice = double.parse(_goalPriceController.text.trim());
    final monthlyIncome = double.parse(_monthlyIncomeController.text.trim());
    final estimateText = _estimateController.text.trim();
    final estimatedDailySpending =
        estimateText.isEmpty ? null : double.tryParse(estimateText);

    final now = DateTime.now();
    final plan = UserSavingPlan(
      goalName: goalName,
      goalPrice: goalPrice,
      inCome: monthlyIncome,
      fixExpeseItem: List<FixedExpense>.unmodifiable(_fixedExpenses),
      spendingPerDay: estimatedDailySpending,
      startDate: DateTime(now.year, now.month, now.day),
    );

    if (plan.suggestedSavingAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to create plan. Your income is insufficient to cover expenses and savings. Please adjust your income or reduce your spending per day.',
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    Navigator.pop(context, plan);
  }

  @override
  Widget build(BuildContext context) {
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
                      FormInputCard(
                        icon: Icons.flag_circle_outlined,
                        title: 'Saving Goal Name',
                        subtitle: 'What are you saving for?',
                        controller: _goalNameController,
                        hintText: 'e.g., New Laptop, Vacation',
                        textInputAction: TextInputAction.next,
                        validator: _validateGoalName,
                      ),
                      const SizedBox(height: 16),
                      FormInputCard(
                        icon: Icons.price_change,
                        title: 'Goal Price',
                        subtitle: 'Set your target amount',
                        controller: _goalPriceController,
                        hintText: 'Enter target amount',
                        prefixText: '\$',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: _validateGoalPrice,
                      ),
                      const SizedBox(height: 16),
                      FormInputCard(
                        icon: Icons.attach_money,
                        title: 'Monthly Income',
                        subtitle: 'How much do you earn per month?',
                        controller: _monthlyIncomeController,
                        hintText: 'Enter your monthly income',
                        prefixText: '\$',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        validator: _validateMonthlyIncome,
                      ),
                      const SizedBox(height: 16),
                      FixedExpensesCard(
                        expenses: _fixedExpenses,
                        onAdd: (expense) {
                          setState(() {
                            _fixedExpenses.add(expense);
                          });
                        },
                        onRemove: (expense) {
                          setState(() {
                            _fixedExpenses.remove(expense);
                          });
                        },
                        onInitCallback: (callback) {
                          _checkPendingExpenseCallback = callback;
                        },
                      ),
                      const SizedBox(height: 16),
                      FormInputCard(
                        icon: Icons.attach_money,
                        title: 'Spending Per Day',
                        subtitle: 'If you don\'t know, you can skip this.',
                        controller: _estimateController,
                        hintText: 'Average daily spending',
                        prefixText: '\$',
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.done,
                        validator: _validateEstimatedDailySpending,
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        text: 'Start Now',
                        onPressed: _startPlan,
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
