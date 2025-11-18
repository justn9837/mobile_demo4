import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models.dart';
import '../../../data/auth_service.dart';

/// HomeController now provides a reactive `motivation` string and a method
/// `fetchMotivation()` that loads a motivational affirmation from
/// https://www.affirmations.dev/ and stores it into `motivation`.
class HomeController extends GetxController {
  final RxString motivation = ''.obs;

  /// Mengembalikan daftar entri untuk username (selalu non-null, paling tidak empty list)
  List<JournalEntry> entriesFor(String username) => AuthService.entriesFor(username);

  /// Simpan entri (delegasi ke AuthService)
  void saveEntry(JournalEntry entry) => AuthService.saveEntry(entry);

  /// Ambil semua user (untuk view dosen)
  List<User> getAllUsers() => AuthService.getAllUsers();

  /// Fetch a motivation/affirmation from the public API and store it
  /// into the reactive `motivation` variable.
  Future<void> fetchMotivation() async {
    try {
      final res = await http.get(Uri.parse('https://www.affirmations.dev/'));
      if (res.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(res.body) as Map<String, dynamic>;
        final aff = data['affirmation'] as String? ?? '';
        motivation.value = aff;
      } else {
        motivation.value = '';
      }
    } catch (e) {
      motivation.value = '';
    }
  }
}