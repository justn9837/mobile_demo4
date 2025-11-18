import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../data/models/journal_entry.dart';
import 'package:hive/hive.dart';
import '../../services/supabase_service.dart';

class DailyJournalController extends GetxController {
  final entries = <JournalEntry>[].obs;
  final noteController = TextEditingController();

  late Box<JournalEntry> _box;

  @override
  void onInit() {
    super.onInit();
    _openBox();
  }

  Future<void> _openBox() async {
    _box = await Hive.openBox<JournalEntry>('entries');
    entries.assignAll(_box.values.toList());
  }

  Future<void> addEntry(String mood, int stress) async {
    final e = JournalEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      mood: mood,
      stressLevel: stress,
      note: noteController.text,
      pending: true,
    );
    await _box.add(e);
    entries.insert(0, e);
    noteController.clear();
    // Try to sync immediately (best-effort)
    syncPending();
  }

  Future<void> syncPending() async {
    final client = Get.find<SupabaseService>().client;
    for (final e in _box.values.where((x) => x.pending)) {
      try {
        await client.from('entries').insert({
          'user_id': e.userId,
          'username': e.username,
          'mood': e.mood,
          'stress_level': e.stressLevel,
          'note': e.note,
        });
        e.pending = false;
        await e.save();
      } catch (err) {
        // ignore and keep pending
        print('sync error: $err');
      }
    }
    entries.assignAll(_box.values.toList().reversed.toList());
  }
}
