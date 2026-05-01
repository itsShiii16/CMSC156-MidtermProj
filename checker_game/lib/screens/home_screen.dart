import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/checker_background.dart';
import '../widgets/action_button.dart';
import '../widgets/profile_chip.dart';
import '../widgets/profile_avatar.dart';
import '../services/settings_service.dart';
import 'game_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late SettingsService _settingsService;
  static const String _profileHeroTag = 'home-profile-avatar';

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
  }

  void _toggleSound() {
    setState(() {
      _settingsService.setSoundEnabled(!_settingsService.soundEnabled);
    });
  }

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
                  IconButton(
                    icon: const Icon(Icons.settings),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          _settingsService.soundEnabled ? Icons.volume_up : Icons.volume_off,
                        ),
                        onPressed: _toggleSound,
                      ),
                      const SizedBox(width: 4),
                      ProfileAvatar(
                        size: 44,
                        heroTag: _profileHeroTag,
                        onTap: () {
                          Navigator.push(
                            context,
                            ProfileScreen.route(heroTag: _profileHeroTag),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Text(
              'CHECKERS', 
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, letterSpacing: 2.0),
            ),
            const Text(
              'MASTER STRATEGY', 
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
              label: 'Start Game', 
              onPressed: () async {
                final names = await Navigator.push<List<String>>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const _PlayerNamesScreen(),
                  ),
                );
                if (names == null || names.length != 2) return;

                if (!context.mounted) return;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GameScreen(
                      player1Name: names[0],
                      player2Name: names[1],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 8),
            const Text(
              'Pass and Play', 
              style: TextStyle(fontSize: 14, color: AppColors.softGray),
            ),
            const SizedBox(height: 24), // Added a little padding at the bottom for breathing room
          ],
        ),
      ),
    );
  }
}

class _PlayerNamesScreen extends StatefulWidget {
  const _PlayerNamesScreen();

  @override
  State<_PlayerNamesScreen> createState() => _PlayerNamesScreenState();
}

class _PlayerNamesScreenState extends State<_PlayerNamesScreen> {
  final TextEditingController _player1Controller = TextEditingController();
  final TextEditingController _player2Controller = TextEditingController();

  @override
  void dispose() {
    _player1Controller.dispose();
    _player2Controller.dispose();
    super.dispose();
  }

  void _submitWithDefaults() {
    final player1 = _player1Controller.text.trim();
    final player2 = _player2Controller.text.trim();

    final finalPlayer1 = player1.isEmpty ? 'Player1' : player1;
    final finalPlayer2 = player2.isEmpty ? 'Player2' : player2;

    Navigator.pop(context, [finalPlayer1, finalPlayer2]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Player Names'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Enter player names (optional - defaults to Player1 and Player2)',
                style: TextStyle(fontSize: 16, color: AppColors.softGray),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _player1Controller,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'Player 1',
                  hintText: 'Enter Player 1 name',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _player2Controller,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                  labelText: 'Player 2',
                  hintText: 'Enter Player 2 name',
                ),
                onSubmitted: (_) => _submitWithDefaults(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitWithDefaults,
                child: const Text('Start Game'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}