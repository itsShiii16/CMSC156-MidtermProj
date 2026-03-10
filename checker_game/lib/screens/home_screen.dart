import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/checker_background.dart';
import '../widgets/action_button.dart';
import '../widgets/profile_chip.dart';
import 'game_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
                  IconButton(icon: const Icon(Icons.volume_up), onPressed: () {}),
                ],
              ),
            ),
            const Text(
              'CHECKERS', // [cite: 2]
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
            const Text(
              'MASTER STRATEGY', // [cite: 3]
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.5),
            ),
            const SizedBox(height: 24),
            
            // The Beige middle band
            Expanded(
              child: Container(
                width: double.infinity,
                color: AppColors.beige,
                child: const Center(
                  child: CheckerBackground(),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            ActionButton(
              label: 'Start Game', // [cite: 4]
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const GameScreen()));
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Pass and Play', // [cite: 5]
              style: TextStyle(fontSize: 14, color: AppColors.softGray),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const ProfileChip(name: 'G4biru', isSmall: true), // 
                  
                  // Trophy with Notification Badge
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(8)),
                        child: const Icon(Icons.emoji_events, color: AppColors.screenFrame),
                      ),
                      Positioned(
                        right: -4,
                        top: -4,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: AppColors.redNotif,
                            shape: BoxShape.circle,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}