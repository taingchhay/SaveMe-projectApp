import 'package:flutter/material.dart';
import 'package:saveme_project/ui/screens/welcome_screen.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SaveMe',
      home: WelcomeScreen(),
    );
  }
}
