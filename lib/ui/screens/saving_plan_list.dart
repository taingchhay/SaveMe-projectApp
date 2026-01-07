import 'package:flutter/material.dart';
import 'package:saveme_project/data/daily_record_data.dart';
import 'package:saveme_project/data/plan_history_data.dart';
import 'package:saveme_project/data/saving_goal_data.dart';
import 'package:saveme_project/domain/logic/date_generator.dart';
import 'package:saveme_project/domain/logic/saving_calculator.dart';
import 'package:saveme_project/domain/model/saving_goal.dart';
import 'package:saveme_project/domain/model/user_finance.dart';
import 'package:saveme_project/ui/screens/saving_plan.dart';
import 'package:saveme_project/ui/screens/tracking_mode.dart';
import 'package:saveme_project/ui/widgets/custom_header.dart';
import 'package:saveme_project/utils/colors.dart';

typedef SavingPlanCard = ({
  String id,
  String goalName,
  double goalPrice,
  double monthlyIncome,
  double totalFixedExpenses,
  DateTime startDate,
  DateTime targetDate,
  int totalPlannedDays,
  double totalSaved,
  double targetDailySaving,
  int daysSaved,
});

class SavingPlanList extends StatefulWidget {
  const SavingPlanList({
    super.key,
  });

  @override
  State<SavingPlanList> createState() => _SavingPlanListState();
}

class _SavingPlanListState extends State<SavingPlanList> {
  List<SavingPlanCard> savingPlans = [];
  String? _currentPlanId;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    final currentGoal = await SavingGoalData().loadGoal();
    final currentFinance = await SavingGoalData().loadFinance();
    final totalDays = await SavingGoalData().loadTotalPlannedDays();
    final records = await DailyRecordData().loadAll();
    final currentSavedDays = records.where((r) => r.isSaved).length;
    final currentTotalSaved = records
        .where((r) => r.isSaved)
        .fold<double>(0.0, (s, r) => s + r.savedAmountThisDay);

    final history = await PlanHistoryData().loadAll();

    final items = <SavingPlanCard>[];
    if (currentGoal != null && currentFinance != null && totalDays != null) {
      final start = DateGenerator.dateOnly(currentGoal.startDate);
      final end = start.add(Duration(days: totalDays - 1));
      items.add(
        _fromDomain(
          goal: currentGoal,
          finance: currentFinance,
          startDate: start,
          targetDate: end,
          totalPlannedDays: totalDays,
          totalSaved: currentTotalSaved,
          targetDailySaving: currentGoal.targetDailySaving ?? 0.0,
          daysSaved: currentSavedDays,
        ),
      );
      _currentPlanId = currentGoal.id;
    } else {
      _currentPlanId = null;
    }

    for (final h in history) {
      items.add(
        _fromDomain(
          goal: h.goal,
          finance: h.finance,
          startDate: h.goal.startDate,
          targetDate: h.endDate,
          totalPlannedDays: h.totalPlannedDays,
          totalSaved: h.totalSaved,
          targetDailySaving: h.goal.targetDailySaving ?? 0.0,
          daysSaved: h.savedDays,
        ),
      );
    }

    if (!mounted) return;
    setState(() {
      savingPlans = items;
    });
  }

  SavingPlanCard _fromDomain({
    required SavingGoal goal,
    required UserFinance finance,
    required DateTime startDate,
    required DateTime targetDate,
    required int totalPlannedDays,
    required double totalSaved,
    required double targetDailySaving,
    required int daysSaved,
  }) {
    return (
      id: goal.id,
      goalName: goal.goalName,
      goalPrice: goal.goalPrice,
      monthlyIncome: finance.monthlyIncome,
      totalFixedExpenses: finance.totalFixedExpenses,
      startDate: startDate,
      targetDate: targetDate,
      totalPlannedDays: totalPlannedDays,
      totalSaved: totalSaved,
      targetDailySaving: targetDailySaving,
      daysSaved: daysSaved,
    );
  }

  Future<void> _deletePlan(String id) async {
    if (_currentPlanId != null && id == _currentPlanId) {
      await SavingGoalData().clear();
      await DailyRecordData().clear();
      _currentPlanId = null;
    } else {
      await PlanHistoryData().deleteById(id);
    }
    await _loadPlans();
  }

  DateTime _getEndDate(SavingPlanCard plan) {
    final totalDays = _totalDays(plan);
    return DateGenerator.dateOnly(plan.startDate)
        .add(Duration(days: totalDays - 1));
  }

  Future<void> _navigateToDetail(SavingPlanCard plan) async {
    final effectiveTarget = _getEndDate(plan);
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPlan(
          goalName: plan.goalName,
          goalPrice: plan.goalPrice,
          monthlyIncome: plan.monthlyIncome,
          totalFixedExpenses: plan.totalFixedExpenses,
          startDate: plan.startDate,
          targetDate: effectiveTarget,
        ),
      ),
    );

    await _loadPlans();
  }

  Future<void> _addNewPlan() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrackingMode()),
    );
    await _loadPlans();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[date.month - 1]} ${date.day.toString().padLeft(2, '0')}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            title: 'My Saving Plans',
            subtitle: 'Tap a plan to track your progress',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: savingPlans.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: savingPlans.length,
                    itemBuilder: (context, index) {
                      return _buildPlanCard(savingPlans[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewPlan,
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add, color: AppColors.textWhite),
        label: const Text(
          'New Plan',
          style: TextStyle(color: AppColors.textWhite),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.savings_outlined,
            size: 80,
            color: AppColors.textGrey.withAlpha(128),
          ),
          const SizedBox(height: 16),
          const Text(
            'No saving plans yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to create your first plan',
            style: TextStyle(color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  int _totalDays(SavingPlanCard plan) {
    final plannedDays = plan.totalPlannedDays < 1 ? 1 : plan.totalPlannedDays;
    if (plan.targetDailySaving <= 0) {
      return plannedDays;
    }

    final remainingGoal =
        (plan.goalPrice - plan.totalSaved).clamp(0.0, plan.goalPrice);
    final remainingDays = SavingCalculator.daysToReachGoal(
      goalPrice: remainingGoal,
      suggestedSavingPerDay: plan.targetDailySaving,
    );

    final recomputedTotalDays = (plan.daysSaved + remainingDays).clamp(1, 3650);
    final effectiveDays =
        recomputedTotalDays < plannedDays ? recomputedTotalDays : plannedDays;
    return effectiveDays < plan.daysSaved ? plan.daysSaved : effectiveDays;
  }

  double _progressPercent(SavingPlanCard plan) {
    if (plan.goalPrice <= 0) {
      return 0.0;
    }
    return ((plan.totalSaved / plan.goalPrice) * 100).clamp(0.0, 100.0);
  }

  int? _calculateRemainingDays(SavingPlanCard plan) {
    if (plan.totalSaved >= plan.goalPrice) {
      return 0;
    }

    final remainingAmount = plan.goalPrice - plan.totalSaved;

    if (plan.daysSaved <= 0 || plan.totalSaved <= 0) {
      if (plan.targetDailySaving > 0) {
        return (remainingAmount / plan.targetDailySaving).ceil();
      }
      return null;
    }

    final actualDailySaving = plan.totalSaved / plan.daysSaved;

    return (remainingAmount / actualDailySaving).ceil();
  }

  String _getRemainingDaysText(SavingPlanCard plan) {
    final remainingDays = _calculateRemainingDays(plan);

    if (remainingDays == null) {
      return 'Start saving to see remaining days';
    } else if (remainingDays == 0) {
      return 'Goal achieved!';
    } else if (remainingDays == 1) {
      return '1 day remaining at current rate';
    } else {
      return '$remainingDays days remaining at current rate';
    }
  }

  Widget _buildPlanCard(SavingPlanCard plan) {
    final progressPercent = _progressPercent(plan);
    final effectiveTarget = _getEndDate(plan);
    return GestureDetector(
      onTap: () => _navigateToDetail(plan),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        plan.goalName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${plan.goalPrice.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(plan),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppColors.textGrey),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(plan.startDate)} - ${_formatDate(effectiveTarget)}',
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.timelapse,
                    size: 16, color: AppColors.primaryBlue),
                const SizedBox(width: 8),
                Text(
                  _getRemainingDaysText(plan),
                  style: TextStyle(
                    color: AppColors.textGrey,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.savings,
                    size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  '\$${plan.totalSaved.toStringAsFixed(2)} of \$${plan.goalPrice.toStringAsFixed(2)} saved',
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progressPercent / 100,
                backgroundColor: AppColors.upcoming,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progressPercent.toStringAsFixed(1)}% complete',
              style: const TextStyle(
                color: AppColors.textGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(SavingPlanCard plan) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Plan'),
        content: Text('Are you sure you want to delete "${plan.goalName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePlan(plan.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: AppColors.textWhite,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
