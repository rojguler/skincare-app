import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Storage helper that works on both web and mobile
class StorageHelper {
  static SharedPreferences? _prefs;

  /// Initialize storage based on platform
  static Future<void> init() async {
    if (kIsWeb) {
      _prefs = await SharedPreferences.getInstance();
    }
    // Hive is already initialized in main.dart for mobile
  }

  /// Get value from storage
  static Future<dynamic> get(String key) async {
    if (kIsWeb && _prefs != null) {
      return _prefs!.get(key);
    } else {
      try {
        final box = Hive.box('settings');
        return box.get(key);
      } catch (e) {
        return null;
      }
    }
  }

  /// Set value in storage
  static Future<void> set(String key, dynamic value) async {
    if (kIsWeb && _prefs != null) {
      if (value is String) {
        await _prefs!.setString(key, value);
      } else if (value is int) {
        await _prefs!.setInt(key, value);
      } else if (value is bool) {
        await _prefs!.setBool(key, value);
      } else if (value is double) {
        await _prefs!.setDouble(key, value);
      } else if (value is List<String>) {
        await _prefs!.setStringList(key, value);
      }
    } else {
      try {
        final box = Hive.box('settings');
        await box.put(key, value);
      } catch (e) {
        print('Storage error: $e');
      }
    }
  }

  /// Remove value from storage
  static Future<void> remove(String key) async {
    if (kIsWeb && _prefs != null) {
      await _prefs!.remove(key);
    } else {
      try {
        final box = Hive.box('settings');
        await box.delete(key);
      } catch (e) {
        print('Storage error: $e');
      }
    }
  }

  /// Clear all storage
  static Future<void> clear() async {
    if (kIsWeb && _prefs != null) {
      await _prefs!.clear();
    } else {
      try {
        final box = Hive.box('settings');
        await box.clear();
      } catch (e) {
        print('Storage error: $e');
      }
    }
  }
}
