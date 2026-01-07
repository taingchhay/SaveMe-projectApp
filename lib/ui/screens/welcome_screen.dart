import 'package:flutter/material.dart';
import 'package:saveme_project/ui/widgets/button.dart';
import 'package:saveme_project/ui/screens/saving_plan_list.dart';
import 'tracking_mode.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Widget _featureItem({
    required IconData icon,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 86,
          height: 86,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(50),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Icon(
            icon,
            size: 34,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings,
                  size: 80, color: const Color.fromARGB(255, 255, 255, 255)),
                  SizedBox(height: 20),
                  const Text(
                    'SaveMe',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Save smarter, one day at a time',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _featureItem(
                        icon: Icons.gps_fixed,
                        label: 'Set Goals',
                      ),
                      _featureItem(
                        icon: Icons.trending_up,
                        label: 'Track Daily',
                      ),
                      _featureItem(
                        icon: Icons.account_balance_wallet_outlined,
                        label: 'Save More',
                      ),
                    ],
                  ),
                  const SizedBox(height: 50),
                  CustomButton(
                    text: 'Smart Tracking',
                    backgroundColor: Colors.teal,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TrackingMode(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  CustomButton(
                    text: 'My Plans',
                    backgroundColor:Colors.teal,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SavingPlanList(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
