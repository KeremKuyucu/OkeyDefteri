import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _vibrationKey = 'vibration_enabled';
  static const String _soundKey = 'sound_enabled';
  static const String _telemetryKey = 'telemetry_enabled';

  static Future<bool> getVibrationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_vibrationKey) ?? true;
  }

  static Future<void> setVibrationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrationKey, value);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundKey) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundKey, value);
  }

  static Future<bool> getTelemetryEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_telemetryKey) ?? true;
  }

  static Future<void> setTelemetryEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_telemetryKey, value);
  }
}

class AudioVibrationService {
  static final AudioPlayer _audioPlayer = AudioPlayer();
  
  static Future<void> playClickSound() async {
    final isSoundEnabled = await SettingsService.getSoundEnabled();
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
    final isVibrationEnabled = await SettingsService.getVibrationEnabled();
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
    final isVibrationEnabled = await SettingsService.getVibrationEnabled();
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
