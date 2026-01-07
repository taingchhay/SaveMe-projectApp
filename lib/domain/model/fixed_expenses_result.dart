import 'user_finance.dart';

class FixedExpensesResult {
  final List<FixedExpenseItem> items;
  final double totalFixedMonthly;

  const FixedExpensesResult({
    required this.items,
    required this.totalFixedMonthly,
  });
}
