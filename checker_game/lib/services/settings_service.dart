class SettingsService {
  static final SettingsService _instance = SettingsService._internal();

  factory SettingsService() {
    return _instance;
  }

  SettingsService._internal();

  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _autoRotateDefault = true;

  // Getters
  bool get soundEnabled => _soundEnabled;
  bool get musicEnabled => _musicEnabled;
  bool get autoRotateDefault => _autoRotateDefault;

  // Setters
  void setSoundEnabled(bool value) {
    _soundEnabled = value;
  }

  void setMusicEnabled(bool value) {
    _musicEnabled = value;
  }

  void setAutoRotateDefault(bool value) {
    _autoRotateDefault = value;
  }
}
