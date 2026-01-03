import 'package:flutter/material.dart';
import '../widgets/custom_header.dart';
import '../widgets/custom_header.dart';
import '../widgets/info_card.dart';
import '../widgets/input_label.dart';

class TrackingMode extends StatefulWidget {
  const TrackingMode({super.key});

  @override
  _TrackingModeState createState() => _TrackingModeState();
}

class _TrackingModeState extends State<TrackingMode> {
  final _goalNameController = TextEditingController();
  final _goalPriceController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _goalNameController.dispose();
    _goalPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomHeader(
                    title: 'Smart Tracking Mode',
                    subtitle: 'AI-powered saving recommendations',
                    onBackPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(height: 32),

                  InfoCard(
                    icon: Icons.auto_awesome,
                    title: 'How it works',
                    description: 'Track daily expenses...',
                    backgroundColor: Colors.green[50],
                    iconColor: Colors.green[500],
                  ),
                  const SizedBox(height: 32),

                  InputLabel(
                    icon: Icons.flag_circle_outlined,
                    text: 'Saving Goal Name',
                  ),
                  const SizedBox(height: 10),

                  TextFormField(
                    controller: _goalNameController,
                    decoration: InputDecoration(
                      hintText: 'e.g., New Laptop, Vacation',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  InputLabel(
                    icon: Icons.attach_money,
                    text: 'Goal Price',
                  ),
                  
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _goalPriceController,
                    decoration: InputDecoration(
                      hintText: 'e.g., New Laptop, Vacation',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                          color: Colors.green,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                    ),

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