import 'package:flutter/material.dart';
import 'package:saveme_project/ui/screens/saving_plan.dart';
import 'package:saveme_project/ui/screens/tracking_mode.dart';
import 'package:saveme_project/ui/widgets/custom_header.dart';
import 'package:saveme_project/utils/colors.dart';

// Model class for a Saving Plan
class SavingPlanModel {
  final String id;
  final String goalName;
  final double goalPrice;
  final double monthlyIncome;
  final double totalFixedExpenses;
  final DateTime startDate;
  final DateTime targetDate;
  final int daysSaved;

  SavingPlanModel({
    required this.id,
    required this.goalName,
    required this.goalPrice,
    required this.monthlyIncome,
    required this.totalFixedExpenses,
    required this.startDate,
    required this.targetDate,
    this.daysSaved = 0,
  });

  int get totalDays => targetDate.difference(startDate).inDays;
  double get progressPercent =>
      totalDays > 0 ? (daysSaved / totalDays) * 100 : 0;
}

class SavingPlanList extends StatefulWidget {
  final double monthlyIncome;
  final double totalFixedExpenses;

  const SavingPlanList({
    super.key,
    required this.monthlyIncome,
    required this.totalFixedExpenses,
  });

  @override
  State<SavingPlanList> createState() => _SavingPlanListState();
}

class _SavingPlanListState extends State<SavingPlanList> {
  // Sample list of saving plans - In a real app, this would come from a database
  List<SavingPlanModel> savingPlans = [];

  @override
  void initState() {
    super.initState();
    // Sample data - Replace with actual data from your storage
    savingPlans = [
      SavingPlanModel(
        id: '1',
        goalName: 'Laptop',
        goalPrice: 200.00,
        monthlyIncome: 1000,
        totalFixedExpenses: 500,
        startDate: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 31)),
        daysSaved: 1,
      ),
      SavingPlanModel(
        id: '2',
        goalName: 'Laptop',
        goalPrice: 300.00,
        monthlyIncome: 1000,
        totalFixedExpenses: 500,
        startDate: DateTime.now(),
        targetDate: DateTime.now().add(const Duration(days: 31)),
        daysSaved: 1,
      ),
    ];
  }

  void _deletePlan(String id) {
    setState(() {
      savingPlans.removeWhere((plan) => plan.id == id);
    });
  }

  void _navigateToDetail(SavingPlanModel plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SavingPlan(
          goalName: plan.goalName,
          goalPrice: plan.goalPrice,
          monthlyIncome: plan.monthlyIncome,
          totalFixedExpenses: plan.totalFixedExpenses,
          startDate: plan.startDate,
          targetDate: plan.targetDate,
        ),
      ),
    );
  }

  void _addNewPlan() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TrackingMode(),
      ),
    );
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
            color: AppColors.textGrey.withOpacity(0.5),
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

  Widget _buildPlanCard(SavingPlanModel plan) {
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
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

            // Date Range
            Row(
              children: [
                const Icon(Icons.calendar_today,
                    size: 16, color: AppColors.textGrey),
                const SizedBox(width: 8),
                Text(
                  '${_formatDate(plan.startDate)} - ${_formatDate(plan.targetDate)}',
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Days Saved
            Row(
              children: [
                const Icon(Icons.check_circle,
                    size: 16, color: AppColors.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  '${plan.daysSaved} of ${plan.totalDays} days saved',
                  style:
                      const TextStyle(color: AppColors.textGrey, fontSize: 14),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: plan.progressPercent / 100,
                backgroundColor: AppColors.upcoming,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                minHeight: 8,
              ),
            ),

            const SizedBox(height: 8),

            // Progress Percentage
            Text(
              '${plan.progressPercent.toStringAsFixed(1)}% complete',
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

  void _showDeleteConfirmation(SavingPlanModel plan) {
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
