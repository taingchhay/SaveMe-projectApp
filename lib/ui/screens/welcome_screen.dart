import 'package:flutter/material.dart';
import '../widgets/mode_card.dart';
import 'tracking_mode.dart';

class WelcomeScreen extends StatelessWidget {
  final Function(String) onModeSelect;
  const WelcomeScreen({super.key, required this.onModeSelect});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ Colors.green, Colors.lightGreen],
          ),
        ),

        child: Center(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.savings, size: 80, color: Colors.green[600]),
                SizedBox(height: 16),
                const Text(
                  'Welcome to SaveMe',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 16),
                ModeCard(
                  title: 'Smart Tracking',
                  icon: Icons.bar_chart,
                  description: 'Quick expense tracking',
                  gradient: [Colors.teal[500]!, Colors.green[600]!],
                  onTap: () => onModeSelect('smart_tracking'),
                ),
                
                const SizedBox(height: 10),
                
                ModeCard(
                  title: 'Quick Planning',
                  icon: Icons.calendar_today,
                  description: 'Plan your budget easily',
                  gradient: [Colors.blue[500]!, Colors.indigo[600]!],
                  onTap: () => onModeSelect('quick_planning'),
                ),
              ],
            ),
          ),
        ),
    );
  }
}