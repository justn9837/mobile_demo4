import 'package:get/get.dart';
import '../../../data/models/journal_entry.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/auth_service.dart';
import '../../../services/supabase_service.dart';

class HomeController extends GetxController {
  final entries = <JournalEntry>[].obs;
  final users = <UserModel>[].obs;

  final _auth = AuthService();

  Future<void> loadEntries() async {
    // Fetch entries from Supabase for the current user (simplified)
    final client = Get.find<SupabaseService>().client;
    final res = await client.from('entries').select().order('timestamp');
    if (res != null) {
      entries.assignAll((res as List).map((e) => JournalEntry(
            id: e['id'] as String?,
            userId: e['user_id'] as String?,
            username: e['username'] as String?,
            mood: e['mood'] as String? ?? 'neutral',
            stressLevel: (e['stress_level'] ?? 0) as int,
            note: e['note'] as String?,
            timestamp: DateTime.tryParse(e['timestamp'] as String) ?? DateTime.now(),
            pending: false,
          )));
    }
  }
}
