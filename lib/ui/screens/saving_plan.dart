import 'package:saveme_project/ui/widgets/button.dart';
import 'package:saveme_project/ui/screens/saving_plan_list.dart';
import 'package:flutter/material.dart';
import 'package:saveme_project/data/daily_record_data.dart';
import 'package:saveme_project/domain/model/daily_record.dart';
import 'package:saveme_project/ui/widgets/saving_info_card.dart';
import 'package:saveme_project/ui/widgets/mark_as_saved_dialog.dart';
import 'package:saveme_project/ui/widgets/daily_entry_detail_dialog.dart';
import 'package:saveme_project/utils/colors.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:saveme_project/ui/widgets/custom_header.dart';

class SavingPlan extends StatefulWidget {
  final String goalName;
  final double goalPrice;
  final double monthlyIncome;
  final double totalFixedExpenses;
  final DateTime startDate;
  final DateTime targetDate;

  const SavingPlan({
    super.key,
    required this.goalName,
    required this.goalPrice,
    required this.monthlyIncome,
    required this.totalFixedExpenses,
    required this.startDate,
    required this.targetDate,
  });

  @override
  State<SavingPlan> createState() => _SavingPlanState();
}

class _SavingPlanState extends State<SavingPlan> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late int targetDays;

  final DailyRecordData _dailyRecordData = DailyRecordData();

  Map<DateTime, double> savedAmounts = {};
  Map<DateTime, bool> missedDays = {};
  late double suggestedDailySaving;
  double get totalSaved =>
      savedAmounts.values.fold(0.0, (sum, amount) => sum + amount);

  int get missedCount {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(
        widget.startDate.year, widget.startDate.month, widget.startDate.day);
    final end = DateTime(
        widget.targetDate.year, widget.targetDate.month, widget.targetDate.day);
    final endDate = today.isBefore(end) ? today : end;

    int count = 0;
    DateTime current = start;

    while (current.isBefore(endDate)) {
      if (!savedAmounts.containsKey(current)) {
        count++;
      }
      current = current.add(const Duration(days: 1));
    }

    return count;
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    targetDays = widget.targetDate.difference(widget.startDate).inDays + 1;
    if (targetDays <= 0) targetDays = 30;

    _calculateDailySaving();
    _loadExistingRecords();
  }

  Future<void> _loadExistingRecords() async {
    final records = await _dailyRecordData.loadAll();
    final map = <DateTime, double>{};
    final missed = <DateTime, bool>{};
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    for (final r in records) {
      final dateOnly = DateTime(r.date.year, r.date.month, r.date.day);
      if (r.isSaved) {
        map[dateOnly] = r.savedAmountThisDay;
      }
      if (r.isMissed) {
        missed[dateOnly] = true;
      }
    }

    final start = DateTime(
        widget.startDate.year, widget.startDate.month, widget.startDate.day);
    final end = DateTime(
        widget.targetDate.year, widget.targetDate.month, widget.targetDate.day);
    final endDate = todayOnly.isBefore(end) ? todayOnly : end;

    DateTime current = start;
    while (current.isBefore(endDate)) {
      if (!map.containsKey(current)) {
        missed[current] = true;
        await _dailyRecordData.upsertByDate(
          DailyRecord(
            date: current,
            spendingItems: [],
            totalSpending: 0.0,
            suggestedSaving: suggestedDailySaving,
            savedAmountThisDay: 0.0,
            isSaved: false,
            isMissed: true,
          ),
        );
      }
      current = current.add(const Duration(days: 1));
    }

    if (!mounted) return;
    setState(() {
      savedAmounts = map;
      missedDays = missed;
    });
  }

  void _calculateDailySaving() {
    double dailyAvailable =
        (widget.monthlyIncome - widget.totalFixedExpenses) / 30;
    double targetDailySaving = widget.goalPrice / targetDays;

    suggestedDailySaving = targetDailySaving < dailyAvailable
        ? targetDailySaving
        : dailyAvailable * 0.3;
  }

  void _showMarkAsSavedDialog(DateTime day) async {
    final dateOnly = DateTime(day.year, day.month, day.day);

    if (savedAmounts.containsKey(dateOnly)) {
      final existing = await _dailyRecordData.loadByDate(dateOnly);
      if (!mounted || existing == null) {
        return;
      }

      await showDialog<void>(
        context: context,
        builder: (context) => DailyEntryDetailDialog(
          record: existing,
          onEdit: () => _editExistingRecord(existing),
        ),
      );
      return;
    }

    final result = await showDialog<MarkAsSavedResult>(
      context: context,
      builder: (context) => MarkAsSavedDialog(
        day: dateOnly,
        suggestedSaving: suggestedDailySaving,
      ),
    );

    if (result != null) {
      final spendingItems = <SpendingItem>[];
      for (final e in result.expenses) {
        spendingItems.add(
          SpendingItem(
            spendingItemName:
                e.description.isEmpty ? 'Spending' : e.description,
            category: 'Other',
            spendingItemAmount: e.amount,
          ),
        );
      }

      await _dailyRecordData.upsertByDate(
        DailyRecord(
          date: dateOnly,
          spendingItems: spendingItems,
          totalSpending: result.totalSpent,
          suggestedSaving: suggestedDailySaving,
          savedAmountThisDay: result.amountSaved,
          isSaved: true,
          isMissed: false,
        ),
      );

      if (!mounted) return;
      setState(() {
        _selectedDay = day;
        savedAmounts[dateOnly] = result.amountSaved;
        missedDays.remove(dateOnly);
      });
    }
  }

  Future<void> _editExistingRecord(DailyRecord existing) async {
    final initialExpenses = existing.spendingItems
        .map(
          (s) => ExpenseEntry(
            description: s.spendingItemName,
            amount: s.spendingItemAmount,
          ),
        )
        .toList();

    final result = await showDialog<MarkAsSavedResult>(
      context: context,
      builder: (context) => MarkAsSavedDialog(
        day: DateTime(
            existing.date.year, existing.date.month, existing.date.day),
        suggestedSaving: existing.suggestedSaving,
        initialExpenses: initialExpenses,
        initialAmountSaved: existing.savedAmountThisDay,
      ),
    );

    if (result == null) return;

    final updatedSpendingItems = <SpendingItem>[];
    for (final e in result.expenses) {
      updatedSpendingItems.add(
        SpendingItem(
          spendingItemName: e.description.isEmpty ? 'Spending' : e.description,
          category: 'Other',
          spendingItemAmount: e.amount,
        ),
      );
    }

    final updated = existing.copyWith(
      spendingItems: updatedSpendingItems,
      totalSpending: result.totalSpent,
      savedAmountThisDay: result.amountSaved,
    );

    await _dailyRecordData.upsertByDate(updated);
    if (!mounted) return;
    setState(() {
      final dateOnly =
          DateTime(updated.date.year, updated.date.month, updated.date.day);
      savedAmounts[dateOnly] = updated.savedAmountThisDay;
      _selectedDay = updated.date;
    });
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
                            shadowColor: AppColors.primaryGreen.withAlpha(77),
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
                            shadowColor: AppColors.primaryBlue.withAlpha(77),
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
                      //AI Generated
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
                                left: 0,
                                right: 0,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Icon(
                                    Icons.check_circle,
                                    color: Colors.blue,
                                    size: 16,
                                  ),
                                ),
                              );
                            }

                            final now = DateTime.now();
                            final today =
                                DateTime(now.year, now.month, now.day);
                            final start = DateTime(widget.startDate.year,
                                widget.startDate.month, widget.startDate.day);
                            final end = DateTime(widget.targetDate.year,
                                widget.targetDate.month, widget.targetDate.day);
                            final effectiveEnd =
                                today.isBefore(end) ? today : end;

                            final isInRange = !dateOnly.isBefore(start) &&
                                dateOnly.isBefore(effectiveEnd);

                            if (isInRange &&
                                !savedAmounts.containsKey(dateOnly)) {
                              return Positioned(
                                bottom: 1,
                                child: Icon(
                                  Icons.cancel,
                                  color: Colors.red[600],
                                  size: 16,
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCalendarLegend(Colors.blue, 'Saved'),
                        const SizedBox(width: 20),
                        _buildCalendarLegend(Colors.red[600]!, 'Missed'),
                      ],
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Back to Plan List',
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SavingPlanList(
                              monthlyIncome: widget.monthlyIncome,
                              totalFixedExpenses: widget.totalFixedExpenses,
                            ),
                          ),
                          (route) => route.isFirst,
                        );
                      },
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
