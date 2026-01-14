import 'package:flutter/material.dart';
import 'package:saveme_project/ui/widgets/mark_as_saved_dialog.dart';
import 'package:saveme_project/utils/colors.dart';
import 'package:saveme_project/domain/model/user_saving_plan.dart';
import 'package:saveme_project/domain/model/tracking_each_day.dart';
import 'package:saveme_project/ui/widgets/saving_calendar.dart';
import 'package:table_calendar/table_calendar.dart';

class SavingPlan extends StatefulWidget {
  final UserSavingPlan plan;
  final DateTime? targetDate;
  final List<UserSavingPlan>? allPlans;

  const SavingPlan({
    super.key,
    required this.plan,
    this.targetDate,
    this.allPlans,
  });

  @override
  State<SavingPlan> createState() => _SavingPlanState();
}

class _SavingPlanState extends State<SavingPlan> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  late DateTime _startDate;
  late DateTime _targetDate;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    _startDate = DateTime(
      widget.plan.startDate.year,
      widget.plan.startDate.month,
      widget.plan.startDate.day,
    );
    _targetDate = widget.targetDate ??
        widget.plan.suggestedGoalDate ??
        _startDate.add(const Duration(days: 30));
  }

  void _showMarkAsSavedDialog(DateTime day) async {
    // Check if goal is already completed
    if (widget.plan.isGoalCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Goal already completed! No more savings needed.'),
          backgroundColor: AppColors.primaryGreen,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final dateOnly = DateTime(day.year, day.month, day.day);

    // Check if the date is within the plan range
    final start = _startDate;
    final end = DateTime(_targetDate.year, _targetDate.month, _targetDate.day);

    if (dateOnly.isBefore(start) || dateOnly.isAfter(end)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This date is outside your saving plan range'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Find existing tracking for this date
    TrackingEachDay? existing;
    try {
      existing = widget.plan.trackingEachDay.firstWhere(
        (t) => isSameDay(t.date, dateOnly),
      );
    } catch (e) {
      existing = null;
    }

    // Show dialog with existing data (if any)
    final result = await showDialog<TrackingEachDay>(
      context: context,
      builder: (context) => MarkAsSavedDialog(
        plan: widget.plan,
        day: dateOnly,
        existingTracking: existing, // Pass existing data for editing
      ),
    );

    if (result != null) {
      if (!mounted) return;

      setState(() {
        // Remove old entry if exists
        widget.plan.trackingEachDay
            .removeWhere((t) => isSameDay(t.date, dateOnly));

        // Add new/updated entry
        widget.plan.trackingEachDay.add(result);

        _selectedDay = day;
      });

      // Check if goal is now completed
      if (widget.plan.isGoalCompleted) {
        _showGoalCompletedDialog();
      }
    }
  }

  void _showGoalCompletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.celebration, color: AppColors.primaryGreen, size: 32),
            SizedBox(width: 12),
            Flexible(
              child: Text(
                'Goal Completed!',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Congratulations! You\'ve reached your goal of \$${widget.plan.goalPrice.toStringAsFixed(2)}!',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.accentGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Saved: \$${widget.plan.savedSoFar.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Days taken: ${widget.plan.trackingEachDay.length}',
                      style: const TextStyle(color: AppColors.primaryGreen),
                    ),
                    if (widget.plan.daysAheadOrBehind > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.rocket_launch,
                              color: AppColors.primaryGreen, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${widget.plan.daysAheadOrBehind} days ahead of schedule!',
                              style: const TextStyle(
                                color: AppColors.primaryGreen,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Recalculate progress every time build is called
    final progressPercent = widget.plan.completionPercentage;
    final isCompleted = widget.plan.isGoalCompleted;

    // Show text for progress based on completion status
    final progressText = isCompleted
        ? '100%'
        : (progressPercent < 1
            ? '${progressPercent.toStringAsFixed(2)}%'
            : '${progressPercent.toStringAsFixed(0)}%');

    return Scaffold(
      backgroundColor:
          isCompleted ? const Color(0xFFE8F5E9) : AppColors.primaryGreen,
      body: SafeArea(
        child: Column(
          children: [
            // Header with goal name and back button
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Back button
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Goal name and subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.plan.goalName,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Track your daily savings',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Calendar icon
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon:
                          const Icon(Icons.calendar_today, color: Colors.white),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            // Progress to Goal Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isCompleted
                    ? AppColors.primaryGreen
                    : Colors.white.withAlpha(38),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color:
                      isCompleted ? Colors.white : Colors.white.withAlpha(77),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCompleted ? 'Goal Completed!' : 'Progress to Goal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        progressText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: isCompleted ? 1.0 : (progressPercent / 100),
                      minHeight: 8,
                      backgroundColor: Colors.white.withAlpha(77),
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                  if (isCompleted) ...[
                    const SizedBox(height: 8),
                    const Text(
                      '✨ No more savings needed!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Info Cards Section
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Row 1: Total Saved & Remaining Amount
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.attach_money,
                              iconColor: AppColors.primaryGreen,
                              iconBgColor:
                                  const Color.fromARGB(114, 102, 187, 106),
                              title: 'Total Saved',
                              value:
                                  '\$${widget.plan.savedSoFar.toStringAsFixed(2)}',
                              valueColor: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.track_changes,
                              iconColor: const Color(0xFF6B7280),
                              iconBgColor: const Color(0xFFF3F4F6),
                              title: 'Remaining Amount',
                              value:
                                  '\$${widget.plan.remainingAmount.toStringAsFixed(2)}',
                              valueColor: const Color(0xFF111827),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Row 2: Suggested Daily Saving & Days Remaining
                      Row(
                        children: [
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.trending_up,
                              iconColor: AppColors.primaryGreen,
                              iconBgColor:
                                  const Color.fromARGB(114, 102, 187, 106),
                              title: 'Suggested Daily Saving',
                              value:
                                  '\$${widget.plan.currentDailySavingRate.toStringAsFixed(2)}',
                              valueColor: AppColors.primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildInfoCard(
                              icon: Icons.access_time,
                              iconColor: AppColors.primaryBlue,
                              iconBgColor:
                                  const Color.fromARGB(119, 66, 164, 245),
                              title: 'Days Remaining',
                              value: '${widget.plan.dynamicRemainingDays ?? 0}',
                              valueColor: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      SavingCalendar(
                        plan: widget.plan,
                        focusedDay: _focusedDay,
                        selectedDay: _selectedDay,
                        startDate: _startDate,
                        targetDate: _targetDate,
                        onDaySelected: (selectedDay, focusedDay) {
                          final dateOnly = DateTime(selectedDay.year,
                              selectedDay.month, selectedDay.day);
                          final start = _startDate;
                          final end = DateTime(_targetDate.year,
                              _targetDate.month, _targetDate.day);

                          if (!dateOnly.isBefore(start) &&
                              !dateOnly.isAfter(end)) {
                            _showMarkAsSavedDialog(selectedDay);
                            setState(() {
                              _focusedDay = focusedDay;
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'You can only track dates within your saving plan range'),
                                duration: Duration(seconds: 2),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        onPageChanged: (focusedDay) {
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      // Legend
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildCalendarLegend(AppColors.primaryGreen, 'Saved'),
                          const SizedBox(width: 20),
                          _buildCalendarLegend(Colors.amber, 'Missed'),
                          const SizedBox(width: 20),
                          _buildCalendarLegend(
                              Colors.grey.shade300, 'Upcoming'),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: iconColor.withAlpha(102),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: iconColor, size: 32),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF6B7280),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: valueColor,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarLegend(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }
}
