import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late SettingsService _settingsService;

  @override
  void initState() {
    super.initState();
    _settingsService = SettingsService();
  }

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
          'Settings',
          style: TextStyle(
            color: AppColors.screenFrame,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          const Divider(height: 1, thickness: 1, color: Colors.black12),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              children: [
                // Sound Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    'SOUND',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.screenFrame.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.volume_up,
                  title: 'Sound Effects',
                  value: _settingsService.soundEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settingsService.setSoundEnabled(value);
                    });
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.music_note,
                  title: 'Background Music',
                  value: _settingsService.musicEnabled,
                  onChanged: (value) {
                    setState(() {
                      _settingsService.setMusicEnabled(value);
                    });
                  },
                ),
                const Divider(height: 24, indent: 16, endIndent: 16),
                
                // Gameplay Settings Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    'GAMEPLAY',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.screenFrame.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildSettingsTile(
                  icon: Icons.rotate_right,
                  title: 'Auto-Rotate Board',
                  subtitle: 'Rotate board on opponent\'s turn',
                  value: _settingsService.autoRotateDefault,
                  onChanged: (value) {
                    setState(() {
                      _settingsService.setAutoRotateDefault(value);
                    });
                  },
                ),
                const Divider(height: 24, indent: 16, endIndent: 16),
                
                // About Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Text(
                    'ABOUT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppColors.screenFrame.withOpacity(0.6),
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Checkers Master Strategy',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppColors.screenFrame,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Version 1.0.0',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.screenFrame.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: Icon(icon, color: AppColors.screenFrame),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.screenFrame,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.screenFrame.withOpacity(0.6),
                ),
              )
            : null,
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.gold,
        ),
        onTap: () => onChanged(!value),
      ),
    );
  }
}
