class SavingCalculator {
  static const double daysInMonth = 30.0;

  static double suggestedSavingPerDayFixed({
    required double monthlyIncome,
    required double totalFixedExpenses,
    required double estimatedDailySpending,
  }) {
    final monthlySpending = estimatedDailySpending * daysInMonth;
    final availableMoney = monthlyIncome - totalFixedExpenses - monthlySpending;
    if (availableMoney <= 0) return 0.0;
    return availableMoney / daysInMonth;
  }

  static int daysToReachGoal({
    required double goalPrice,
    required double suggestedSavingPerDay,
  }) {
    if (suggestedSavingPerDay <= 0) return 0;
    final raw = (goalPrice / suggestedSavingPerDay).ceil();

    const maxDays = 3650;
    return raw.clamp(1, maxDays);
  }

  static double suggestedSavingDynamicToday({
    required double goalPrice,
    required double totalSaved,
    required int totalPlannedDays,
    required int dayIndexFromStart,
  }) {
    final remainingGoal = (goalPrice - totalSaved).clamp(0.0, goalPrice);
    final remainingDays = totalPlannedDays - dayIndexFromStart;
    if (remainingDays <= 0) return remainingGoal;
    return remainingGoal / remainingDays;
  }
}
