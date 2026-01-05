import 'package:flutter/material.dart';
import 'package:saveme_project/ui/widgets/saving_info_card.dart';
import 'package:saveme_project/ui/widgets/mark_as_saved_dialog.dart';
import 'package:saveme_project/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:saveme_project/ui/widgets/custom_header.dart';

class SavingPlan extends StatefulWidget {
  final String goalName;
  final double goalPrice;
  final double monthlyIncome;
  final double totalFixedExpenses;
  final DateTime targetDate;

  const SavingPlan({
    super.key,
    required this.goalName,
    required this.goalPrice,
    required this.monthlyIncome,
    required this.totalFixedExpenses,
    required this.targetDate,
  });

  @override
  State<SavingPlan> createState() => _SavingPlanState();
}

class _SavingPlanState extends State<SavingPlan> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late int targetDays;

  Map<DateTime, double> savedAmounts = {}; // Track saved amounts for each day
  late double suggestedDailySaving; // Daily saving amount
  double get totalSaved => savedAmounts.values
      .fold(0.0, (sum, amount) => sum + amount); // Calculate total

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Calculate target days from target date
    targetDays = widget.targetDate.difference(DateTime.now()).inDays;
    if (targetDays <= 0) targetDays = 30; // Minimum 30 days

    _calculateDailySaving();
  }

  void _calculateDailySaving() {
    // Use data from widget (from previous screen)
    double dailyAvailable =
        (widget.monthlyIncome - widget.totalFixedExpenses) / 30;
    double targetDailySaving = widget.goalPrice / targetDays;

    // assign to class variable instead
    suggestedDailySaving = targetDailySaving < dailyAvailable
        ? targetDailySaving
        : dailyAvailable * 0.3;
  }

  void _showMarkAsSavedDialog(DateTime day) async {
    final dateOnly = DateTime(day.year, day.month, day.day);

    // If the day is already saved, remove it on tap.
    // A better UX might be to show an edit/delete dialog.
    if (savedAmounts.containsKey(dateOnly)) {
      setState(() {
        savedAmounts.remove(dateOnly);
        _selectedDay = null; // Deselect the day
      });
      return;
    }

    // Show the dialog to get the saved amount
    final savedAmount = await showDialog<double>(
      context: context,
      builder: (context) => MarkAsSavedDialog(
        day: dateOnly,
        suggestedSaving: suggestedDailySaving,
      ),
    );

    // If the user confirmed, update the state with the new amount
    if (savedAmount != null) {
      setState(() {
        _selectedDay = day;
        savedAmounts[dateOnly] = savedAmount;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          CustomHeader(
            title: 'Your Saving Plan',
            subtitle: 'Mark each day you save',
            onBackPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: SavingInfoCard(
                            title: 'Total Saved',
                            amount: '\$${totalSaved.toStringAsFixed(2)}',
                            description: 'Keep it up! You\'re doing great',
                            icon: Icons.savings,
                            gradientColors: const [
                              AppColors.lightGreen,
                              AppColors.darkGreen
                            ],
                            shadowColor:
                                AppColors.primaryGreen.withOpacity(0.3),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: SavingInfoCard(
                            title: 'Suggested Daily',
                            amount:
                                '\$${suggestedDailySaving.toStringAsFixed(2)}',
                            description: 'Spend less than this amount daily',
                            icon: Icons.trending_down,
                            gradientColors: const [
                              AppColors.lightBlue,
                              AppColors.darkBlue
                            ],
                            shadowColor: AppColors.primaryBlue.withOpacity(0.3),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) =>
                            isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          _showMarkAsSavedDialog(selectedDay);
                          setState(() {
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            final dateOnly =
                                DateTime(date.year, date.month, date.day);
                            if (savedAmounts.containsKey(dateOnly)) {
                              return Positioned(
                                bottom: 1,
                                child: Container(
                                  decoration: const BoxDecoration(
                                    color: AppColors.primaryGreen,
                                    shape: BoxShape.circle,
                                  ),
                                  width: 7,
                                  height: 7,
                                ),
                              );
                            }
                            return null;
                          },
                        ),
                        calendarStyle: CalendarStyle(
                          todayDecoration: BoxDecoration(
                            color: Colors.green[300],
                            shape: BoxShape.circle,
                          ),
                          selectedDecoration: BoxDecoration(
                            color: Colors.green[600],
                            shape: BoxShape.circle,
                          ),
                        ),
                        headerStyle: const HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Legend
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegend(Color(0xFF4CAF50), 'Saved'),
                        const SizedBox(width: 20),
                        _buildLegend(const Color.fromARGB(255, 255, 0, 0)!, 'Missed'),
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
    );
  }

  Widget _buildLegend(Color color, String label) {
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
