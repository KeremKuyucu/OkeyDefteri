import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _vibrationKey = 'vibration_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _telemetryKey = 'telemetry_enabled';
  static const String _languageKey = 'app_language';
  static const String _toxicNicknamesKey = 'toxic_nicknames_enabled';

  static late SharedPreferences _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  static String getLanguage() {
    return _prefs.getString(_languageKey) ?? 'eng';
  }

  static Future<void> setLanguage(String value) async {
    await _prefs.setString(_languageKey, value);
  }

  static bool getVibrationEnabled() {
    return _prefs.getBool(_vibrationKey) ?? true;
  }

  static Future<void> setVibrationEnabled(bool value) async {
    await _prefs.setBool(_vibrationKey, value);
  }

  static bool getSoundEnabled() {
    return _prefs.getBool(_soundKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    await _prefs.setBool(_soundKey, value);
  }

  static bool getTelemetryEnabled() {
    return _prefs.getBool(_telemetryKey) ?? true;
  }

  static Future<void> setTelemetryEnabled(bool value) async {
    await _prefs.setBool(_telemetryKey, value);
  }

  static bool getToxicNicknamesEnabled() {
    return _prefs.getBool(_toxicNicknamesKey) ?? false;
  }

  static Future<void> setToxicNicknamesEnabled(bool value) async {
    await _prefs.setBool(_toxicNicknamesKey, value);
  }
}

class AudioVibrationService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static Future<void> playClickSound() async {
    final isSoundEnabled = SettingsService.getSoundEnabled();
    if (isSoundEnabled) {
      // Play a click sound
      try {
        await _audioPlayer.play(AssetSource('sounds/click.mp3'));
      } catch (e) {
        // Ignore sound errors
      }
    }
  }

  static Future<void> vibrate() async {
    final isVibrationEnabled = SettingsService.getVibrationEnabled();
    if (isVibrationEnabled) {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          Vibration.vibrate(duration: 50); // Short light vibration
        }
      } catch (e) {
        // Ignore vibration errors
      }
    }
  }

  static Future<void> vibrateHeavy() async {
    final isVibrationEnabled = SettingsService.getVibrationEnabled();
    if (isVibrationEnabled) {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator) {
          Vibration.vibrate(duration: 150); // Heavy vibration
        }
      } catch (e) {
        // Ignore vibration errors
      }
    }
  }
}
