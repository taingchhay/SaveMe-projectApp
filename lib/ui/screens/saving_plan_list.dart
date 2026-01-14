import 'package:flutter/material.dart';
import 'package:saveme_project/ui/screens/saving_plan.dart';
import 'package:saveme_project/ui/screens/tracking_mode.dart';
import 'package:saveme_project/ui/widgets/custom_header.dart';
import 'package:saveme_project/ui/widgets/confirm_dialog.dart';
import 'package:saveme_project/utils/colors.dart';
import 'package:saveme_project/domain/model/user_saving_plan.dart';
import 'package:saveme_project/data/saving_plan_repository.dart';

class SavingPlanList extends StatefulWidget {
  const SavingPlanList({super.key});

  @override
  State<SavingPlanList> createState() => _SavingPlanListState();
}

class _SavingPlanListState extends State<SavingPlanList> {
  final List<UserSavingPlan> _plans = [];
  final SavingPlanRepository _repository = SavingPlanRepository();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPlans();
  }

  Future<void> _loadPlans() async {
    setState(() => _isLoading = true);

    try {
      final loadedPlans = await _repository.loadAll();
      setState(() {
        _plans.clear();
        _plans.addAll(loadedPlans);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading plans: $e')),
        );
      }
    }
  }

  Future<void> _savePlans() async {
    try {
      await _repository.saveAll(_plans);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving plans: $e')),
        );
      }
    }
  }

  void _deletePlan(int index) async {
    try {
      final planName = _plans[index].goalName;
      await _repository.delete(planName);

      setState(() {
        _plans.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deleted "$planName"')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting plan: $e')),
        );
      }
    }
  }

  void _navigateToDetail(UserSavingPlan plan) async {
    final fallbackTargetDate = plan.startDate.add(const Duration(days: 30));
    final targetDate = plan.suggestedGoalDate ?? fallbackTargetDate;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPlan(
          plan: plan,
          targetDate: targetDate,
          allPlans: _plans,
        ),
      ),
    );

    await _savePlans();
    setState(() {});
  }

  void _addNewPlan() async {
    final newPlan = await Navigator.push<UserSavingPlan>(
      context,
      MaterialPageRoute(
        builder: (context) => TrackingMode(plan: _plans),
      ),
    );

    if (newPlan != null) {
      setState(() {
        _plans.add(newPlan);
      });
      await _repository.save(newPlan);
    }
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
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _plans.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.all(20),
                        itemCount: _plans.length,
                        itemBuilder: (context, index) {
                          return _buildPlanCard(_plans[index], index);
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

  Widget _buildPlanCard(UserSavingPlan plan, int index) {
    final fallbackTargetDate = plan.startDate.add(const Duration(days: 30));
    final targetDate = plan.suggestedGoalDate ?? fallbackTargetDate;

    final progressPercent = plan.completionPercentage;

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
              color: Colors.black.withAlpha(128),
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
                  icon:
                      const Icon(Icons.delete_outline, color: AppColors.missed),
                  onPressed: () => _showDeleteConfirmation(plan, index),
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
                  '${_formatDate(plan.startDate)} - ${_formatDate(targetDate)}',
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14),
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
                  '\$${plan.savedSoFar.toStringAsFixed(2)} of \$${plan.goalPrice.toStringAsFixed(2)} saved',
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

  Future<void> _showDeleteConfirmation(UserSavingPlan plan, int index) async {
    final confirmed = await ConfirmDialog.show(
      context: context,
      title: 'Delete Plan',
      message: 'Are you sure you want to delete ""?',
      boldText: plan.goalName,
      confirmText: 'Delete',
      confirmColor: AppColors.missed,
    );

    if (confirmed) {
      _deletePlan(index);
    }
  }
}
