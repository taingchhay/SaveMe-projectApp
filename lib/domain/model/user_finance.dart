class FixedExpenseItem {
  final String fixedExpenseItemName;
  final double fixedExpenseItemAmount;

  FixedExpenseItem({required this.fixedExpenseItemName, required this.fixedExpenseItemAmount});

  Map<String, dynamic> toJson() => {'fixedExpenseItemName': fixedExpenseItemName, 'fixedExpenseItemAmount': fixedExpenseItemAmount};

  static FixedExpenseItem fromJson(Map<String, dynamic> json) =>
      FixedExpenseItem(
        fixedExpenseItemName: (json['fixedExpenseItemName'] as String?) ?? '',
        fixedExpenseItemAmount: (json['fixedExpenseItemAmount'] as num?)?.toDouble() ?? 0.0,
      );
}

class UserFinance {
  final double monthlyIncome;
  final List<FixedExpenseItem> fixedMonthlyExpenses;

  final double? estimatedDailySpending;

  UserFinance({
    required this.monthlyIncome,
    required this.fixedMonthlyExpenses,
    required this.estimatedDailySpending,
  });

  double get totalFixedExpenses => fixedMonthlyExpenses.fold<double>(0.0, (sum, item) => sum + item.fixedExpenseItemAmount);

  Map<String, dynamic> toJson() => {
    'monthlyIncome': monthlyIncome,
    'fixedMonthlyExpenses': fixedMonthlyExpenses
        .map((e) => e.toJson())
        .toList(),
    'estimatedDailySpending': estimatedDailySpending,
  };

  //AI Generated
  static UserFinance fromJson(Map<String, dynamic> json) => UserFinance(
    monthlyIncome: (json['monthlyIncome'] as num?)?.toDouble() ?? 0.0,
    fixedMonthlyExpenses: ((json['fixedMonthlyExpenses'] as List?) ?? const [])
        .map(
          (e) => FixedExpenseItem.fromJson((e as Map).cast<String, dynamic>()),
        )
        .toList(),
    estimatedDailySpending: (json['estimatedDailySpending'] as num?)
        ?.toDouble(),
  );
}
