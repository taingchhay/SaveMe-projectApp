import 'package:flutter/material.dart';
import 'package:saveme_project/ui/widgets/button.dart';
import 'package:saveme_project/ui/widgets/info_card.dart';
import 'tracking_mode.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.savings, size: 80, color: const Color.fromARGB(255, 255, 255, 255)),
              SizedBox(height: 20),
              const Text(
                'Welcome to SaveMe',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: InfoCard(
                  icon: Icons.auto_awesome,
                  title: 'Save smarter, on day at a time',
                  description: 'Create a daily saving plan instantly using your income, fixed Expenses, and estimated spending.',
                  backgroundColor: Colors.green[50],
                  iconColor: Colors.blueAccent,
                  ),
              ),

              SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: CustomButton(
                  text: 'Smart Tracking',
                  backgroundColor: Colors.blue,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TrackingMode()),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
