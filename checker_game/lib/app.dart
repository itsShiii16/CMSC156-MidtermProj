import 'package:flutter/material.dart';
import 'screens/home_screen.dart';
import 'theme/app_colors.dart';

class CheckersApp extends StatelessWidget {
  const CheckersApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Checkers',
      theme: ThemeData(
        scaffoldBackgroundColor: AppColors.cream,
        fontFamily: 'Serif',
      ),
      home: const HomeScreen(),
    );
  }
}