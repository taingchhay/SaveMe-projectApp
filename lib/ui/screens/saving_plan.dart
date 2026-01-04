import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:saveme_project/ui/widgets/custom_header.dart';
import 'package:saveme_project/ui/widgets/info_card.dart';

class SavingPlan extends StatefulWidget {
  const SavingPlan({super.key});

  @override
  State<SavingPlan> createState() => _SavingPlanState();
}

class _SavingPlanState extends State<SavingPlan> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
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
                    const SizedBox(height: 24),
                    
                    InfoCard(
                      icon: Icons.auto_awesome,
                      title: 'How it works',
                      description: 'Track daily expenses...',
                      backgroundColor: Colors.green[50],
                      iconColor: Colors.green[500],
                    ),

                    const SizedBox(height: 20),

                    // CALENDAR HERE
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: TableCalendar(
                        firstDay: DateTime.utc(2020, 1, 1),
                        lastDay: DateTime.utc(2030, 12, 31),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay;
                          });
                        },
                        onPageChanged: (focusedDay) => _focusedDay = focusedDay,
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
                        _buildLegend(Colors.blue, 'Saved'),
                        const SizedBox(width: 20),
                        _buildLegend(Colors.pink[200]!, 'Missed'),
                        const SizedBox(width: 20),
                        _buildLegend(Colors.grey[300]!, 'Upcoming'),
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