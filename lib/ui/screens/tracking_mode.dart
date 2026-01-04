import 'package:flutter/material.dart';
import 'package:saveme_project/ui/screens/saving_plan.dart';
import 'package:saveme_project/ui/widgets/button.dart';
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
  final _monthlyIncomeController = TextEditingController();
  final _fixedMonthlyController = TextEditingController();
  final _amountController = TextEditingController();
  final _estimateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _goalNameController.dispose();
    _goalPriceController.dispose();
    _monthlyIncomeController.dispose();
    _fixedMonthlyController.dispose();
    _amountController.dispose();
    _estimateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 250, 250),
      body: Column(
        children: [
          CustomHeader(
            title: 'Smart Tracking Mode',
            subtitle: 'AI-powered saving recommendations',
            onBackPressed: () {
              Navigator.pop(context);
            },
            
          ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
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
                        const SizedBox(height: 32),
                        InputLabel(
                          icon: Icons.flag_circle_outlined,
                          text: 'Saving Goal Name',
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _goalNameController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your saving goal name';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'e.g., New Laptop, Vacation',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        InputLabel(
                          icon: Icons.price_change,
                          text: 'Goal Price',
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _goalPriceController,
                          keyboardType: TextInputType.number, // ADD THIS
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter goal price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Price must be greater than 0';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixText: '\$',
                            hintText: 'Enter target amount',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        InputLabel(
                          icon: Icons.attach_money,
                          text: 'Monthly Income',
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _monthlyIncomeController,
                          keyboardType: TextInputType.number, // ADD THIS
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your monthly income';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Income must be greater than 0';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            prefixText: '\$',
                            hintText: 'Enter your monthly income',
                            hintStyle: const TextStyle(color: Colors.grey),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        InputLabel(
                          icon: Icons.expand,
                          text: 'Fixed Monthly Expense',
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: TextFormField(
                                controller: _fixedMonthlyController,
                                validator: (value) {
                                  // Only validate if amount is filled
                                  if (_amountController.text.isNotEmpty && (value == null || value.isEmpty)) {
                                    return 'Enter expense name';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  hintText: 'e.g., Rent',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _amountController,
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  // Only validate if name is filled
                                  if (_fixedMonthlyController.text.isNotEmpty && (value == null || value.isEmpty)) {
                                    return 'Enter amount';
                                  }
                                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  prefixText: '\$',
                                  hintText: 'Amount',
                                  hintStyle: const TextStyle(color: Colors.grey),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                              ),
                            ),
                            // const SizedBox(width: 8),
                            // IconButton(
                            //   icon: const Icon(Icons.close, color: Colors.red),
                            //   onPressed: () => _removeFixedExpense(index),
                            // ),
                          ],
                        ),
                        const SizedBox(height: 16),
                          InputLabel(
                            icon: Icons.attach_money,
                            text: 'Estimated Daily Spending (optional)',
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: _estimateController,
                            keyboardType: TextInputType.number, // ADD THIS
                            validator: (value) {
                              // This field is optional, so only validate if user entered something
                              if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                                return 'Please enter a valid number';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              prefixText: '\$',
                              hintText: 'Average daily spending',
                              hintStyle: const TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.white,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          CustomButton(
                            text: 'Start Now',
                            onPressed: () {
                              // Validate all fields
                              if (_formKey.currentState!.validate()) {
                                // All fields are valid, navigate to next screen
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SavingPlan(),
                                  ),
                                );
                              } else {
                                // Show error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Please fill all required fields correctly'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                          ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
