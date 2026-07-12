import 'package:shared_preferences/shared_preferences.dart';

class AppPrefs {
  static const String _keyPin = "user_pin";
  static const String _keyBiometricEnabled = "biometric_enabled";
  static const String _keyHasPromptedPin = "has_prompted_pin";

  static Future<void> setPin(String pin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPin, pin);
  }

  static Future<String?> getPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPin);
  }

  static Future<void> setHasPromptedPin(bool prompted) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasPromptedPin, prompted);
  }

  static Future<bool> hasPromptedPin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasPromptedPin) ?? false;
  }

  static Future<void> setBiometricEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  static Future<bool> isBiometricEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyBiometricEnabled) ?? false;
  }
}
