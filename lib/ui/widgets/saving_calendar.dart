import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:saveme_project/domain/model/user_saving_plan.dart';
import 'package:saveme_project/domain/model/tracking_each_day.dart';
import 'package:saveme_project/utils/colors.dart';

class SavingCalendar extends StatelessWidget {
  final UserSavingPlan plan;
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final DateTime startDate;
  final DateTime targetDate;
  final Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final Function(DateTime focusedDay) onPageChanged;

  const SavingCalendar({
    super.key,
    required this.plan,
    required this.focusedDay,
    required this.selectedDay,
    required this.startDate,
    required this.targetDate,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TableCalendar(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: focusedDay,
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: onDaySelected,
        onPageChanged: onPageChanged,
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day, isToday: false, isSelected: false);
          },
          todayBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day, isToday: true, isSelected: false);
          },
          selectedBuilder: (context, day, focusedDay) {
            return _buildCalendarCell(day, isToday: false, isSelected: true);
          },
        ),
        calendarStyle: const CalendarStyle(
          cellMargin: EdgeInsets.all(4),
          markersMaxCount: 0,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCalendarCell(DateTime day,
      {required bool isToday, required bool isSelected}) {
    final dateOnly = DateTime(day.year, day.month, day.day);
    final tracking = plan.trackingEachDay.cast<TrackingEachDay?>().firstWhere(
          (t) => t != null && isSameDay(t.date, dateOnly),
          orElse: () => null,
        );

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = startDate;
    final end = DateTime(targetDate.year, targetDate.month, targetDate.day);

    final isInRange = !dateOnly.isBefore(start) && !dateOnly.isAfter(end);
    final isPast = dateOnly.isBefore(today);
    final hasSaved = tracking != null;
    final isCompleted = plan.isGoalCompleted;

    Color? bgColor;
    if (isSelected) {
      bgColor = AppColors.primaryGreen.withAlpha(51);
    } else if (hasSaved) {
      bgColor = AppColors.primaryGreen.withAlpha(38);
    } else if (isCompleted) {
      // Show neutral color for future dates after completion
      bgColor = Colors.grey.withAlpha(13);
    } else if (isInRange && isPast) {
      bgColor = Colors.amber.withAlpha(38);
    } else if (isInRange) {
      bgColor = Colors.grey.withAlpha(25);
    }

    Color textColor;
    if (isToday || isSelected) {
      textColor = AppColors.primaryGreen;
    } else if (isInRange && !isCompleted) {
      textColor = Colors.black87;
    } else {
      textColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        border: (isToday || isSelected)
            ? Border.all(color: AppColors.primaryGreen, width: 2)
            : null,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight:
                hasSaved || isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
