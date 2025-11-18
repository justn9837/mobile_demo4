import 'package:hive_flutter/hive_flutter.dart';

/// Simple Hive helper for offline journal entries. Uses a box named `entries`.
class HiveService {
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('entries');
    await Hive.openBox('profiles');
  }

  static Future<void> saveEntry(String username, Map<String, dynamic> entry) async {
    final box = Hive.box('entries');
    final list = List<Map<String, dynamic>>.from(box.get(username, defaultValue: []) as List);
    list.add(entry);
    await box.put(username, list);
  }

  static List<Map<String, dynamic>> getEntriesFor(String username) {
    final box = Hive.box('entries');
    final raw = box.get(username, defaultValue: []) as List;
    return raw.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }
}
