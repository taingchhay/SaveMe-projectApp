import 'fixed_expese.dart';
import 'tracking_each_day.dart';

class UserSavingPlan {
  final String goalName;
  final double goalPrice;
  final double inCome;
  final List<FixedExpense> fixExpeseItem;
  final List<TrackingEachDay> trackingEachDay;
  final double? spendingPerDay;
  DateTime startDate;

  UserSavingPlan({
    required this.goalName,
    required this.goalPrice,
    required this.inCome,
    required this.fixExpeseItem,
    this.spendingPerDay,
    required this.startDate,
    List<TrackingEachDay>? trackingEachDay,
  }) : trackingEachDay = trackingEachDay ?? <TrackingEachDay>[];

  double get totalFixedExpenseAmount =>
      fixExpeseItem.fold<double>(0, (sum, item) => sum + item.amount);

  double get monthlySpending => (spendingPerDay ?? 0) * 30;

  double get availableMoney {
    final available = inCome - totalFixedExpenseAmount - monthlySpending;
    return available < 0 ? 0 : available;
  }

  double get suggestedSavingAmount {
    if (availableMoney <= 0) return 0;
    return availableMoney / 30;
  }

  int? get suggestedDaysToGoal {
    if (suggestedSavingAmount <= 0) return null;
    final days = (goalPrice / suggestedSavingAmount).ceil();
    return days.clamp(1, 3650);
  }

  DateTime? get suggestedGoalDate {
    final days = suggestedDaysToGoal;
    if (days == null) return null;
    return startDate.add(Duration(days: days));
  }

  double get savedSoFar =>
      trackingEachDay.fold<double>(0, (sum, day) => sum + day.newSavingAmount);

  bool get isGoalCompleted => savedSoFar >= goalPrice;

  double get remainingAmount {
    if (isGoalCompleted) return 0;
    final remaining = goalPrice - savedSoFar;
    return remaining < 0 ? 0 : remaining;
  }

  int get daysPassed {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return today.difference(start).inDays;
  }

  int? get remainingDaysFromPlan {
    if (isGoalCompleted) return 0;

    final plannedDays = suggestedDaysToGoal;
    if (plannedDays == null) return null;
    final remaining = plannedDays - daysPassed;
    return remaining < 0 ? 0 : remaining;
  }

  int? get daysLeftToGoalDate {
    if (isGoalCompleted) return 0;

    final goalDate = suggestedGoalDate;
    if (goalDate == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final endDate = DateTime(goalDate.year, goalDate.month, goalDate.day);

    final daysLeft = endDate.difference(today).inDays;
    return daysLeft < 0 ? 0 : daysLeft;
  }

  double get dynamicSuggestedSaving {
    if (isGoalCompleted) return 0;

    final daysLeft = daysLeftToGoalDate;
    if (daysLeft == null || daysLeft <= 0) return 0;

    final remaining = remainingAmount;
    if (remaining <= 0) return 0;

    return remaining / daysLeft;
  }

  double get currentDailySavingRate {
    if (isGoalCompleted) return 0;

    final dynamic = dynamicSuggestedSaving;

    if (dynamic > 0 && dynamic != suggestedSavingAmount) {
      return dynamic;
    }

    return suggestedSavingAmount;
  }

  double get averageDailySavingRate {
    if (trackingEachDay.isEmpty) return 0;
    return savedSoFar / trackingEachDay.length;
  }

  double get latestDailySavingRate =>
      trackingEachDay.isNotEmpty ? trackingEachDay.last.newSavingAmount : 0;

  double get completionPercentage {
    if (goalPrice <= 0) return 0;
    final percentage =
        (savedSoFar / goalPrice * 100).clamp(0.0, 100.0).toDouble();
    return percentage;
  }

  int get daysAheadOrBehind {
    if (isGoalCompleted) {
      final plannedDays = suggestedDaysToGoal ?? 0;
      return plannedDays - daysPassed;
    }

    final expectedSaved = suggestedSavingAmount * daysPassed;
    final difference = savedSoFar - expectedSaved;

    if (suggestedSavingAmount <= 0) return 0;

    return (difference / suggestedSavingAmount).round();
  }

  Map<String, dynamic> toJson() {
    return {
      'goalName': goalName,
      'goalPrice': goalPrice,
      'inCome': inCome,
      'spendingPerDay': spendingPerDay,
      'startDate': startDate.toIso8601String(),
      'fixExpeseItem': fixExpeseItem.map((e) => e.toJson()).toList(),
      'trackingEachDay': trackingEachDay.map((t) => t.toJson()).toList(),
    };
  }

  factory UserSavingPlan.fromJson(Map<String, dynamic> json) {
    return UserSavingPlan(
      goalName: json['goalName'] as String,
      goalPrice: (json['goalPrice'] as num).toDouble(),
      inCome: (json['inCome'] as num).toDouble(),
      spendingPerDay: json['spendingPerDay'] as double?,
      startDate: DateTime.parse(json['startDate'] as String),
      fixExpeseItem: (json['fixExpeseItem'] as List)
          .map((item) => FixedExpense.fromJson(item))
          .toList(),
      trackingEachDay: (json['trackingEachDay'] as List)
          .map((item) => TrackingEachDay.fromJson(item))
          .toList(),
    );
  }
}
