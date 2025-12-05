import 'package:hive_flutter/hive_flutter.dart';

class HiveHelper {
  static Box? getBox(String boxName) {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      } else {
        // Return null if box is not open - caller should handle this
        print('Box $boxName is not open');
        return null;
      }
    } catch (e) {
      print('Error accessing Hive box $boxName: $e');
      return null;
    }
  }

  static Future<Box?> getBoxAsync(String boxName) async {
    try {
      if (Hive.isBoxOpen(boxName)) {
        return Hive.box(boxName);
      } else {
        // Try to open the box if it's not open
        return await Hive.openBox(boxName);
      }
    } catch (e) {
      print('Error accessing Hive box $boxName: $e');
      return null;
    }
  }

  static Future<void> clearAllBoxes() async {
    try {
      final boxNames = [
        'entries',
        'stats',
        'profile',
        'habits',
        'goals',
        'settings',
        'routines',
        'statsBox',
      ];
      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).clear();
        }
      }
    } catch (e) {
      print('Error clearing Hive boxes: $e');
    }
  }
}
