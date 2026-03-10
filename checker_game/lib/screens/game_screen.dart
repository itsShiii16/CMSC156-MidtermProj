import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/checker_board.dart';
import '../widgets/profile_chip.dart';
import '../widgets/auto_rotate_toggle.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _isAutoRotateOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.screenFrame),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Play in Person',
          style: TextStyle(color: AppColors.screenFrame, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ProfileChip(name: 'Opponent'),
          ),
          
          Expanded(
            child: Container(
              color: AppColors.beige,
              child: const Center(
                child: AspectRatio(
                  aspectRatio: 1, 
                  child: CheckerBoard(interactive: true)
                ),
              ),
            ),
          ),
          
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: ProfileChip(name: 'G4bbiru'),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                // Group 1: The two arrow icon AND the toggle switch
                Row(
                  children: [
                    const Icon(Icons.swap_vert, size: 32),
                    const SizedBox(width: 16), // Adds spacing between the icon and toggle
                    AutoRotateToggle(
                      value: _isAutoRotateOn,
                      onChanged: (newValue) {
                        setState(() {
                          _isAutoRotateOn = newValue;
                        });
                      },
                    ),
                  ],
                ),
                
                // Group 2: The Back and Forward history controls
                Row(
                  children: [
                    Column(
                      children: const [
                        Icon(Icons.chevron_left, size: 32),
                        Text('Back', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      children: const [
                        Icon(Icons.chevron_right, size: 32),
                        Text('Forward', style: TextStyle(fontSize: 12)),
                      ],
                    ),
                  ],
                )
              ],
            ),
          )
        ],  
      ),
    );
  }
}