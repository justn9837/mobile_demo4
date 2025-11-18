import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../../../data/models.dart';
import '../../../data/auth_service.dart';

/// Lightweight non-reactive helper used across views
class HomeController {
  /// Mengembalikan daftar entri untuk username (selalu non-null, paling tidak empty list)
  List<JournalEntry> entriesFor(String username) => AuthService.entriesFor(username);

  /// Simpan entri (delegasi ke AuthService in-memory)
  void saveEntry(JournalEntry entry) => AuthService.saveEntry(entry);

  /// Ambil semua user (untuk view dosen)
  List<User> getAllUsers() => AuthService.getAllUsers();
}

/// Controller for the regular user home that provides a reactive motivation string
class HomeUserHomeController extends GetxController {
  final motivation = ''.obs;

  /// Fetch a short motivational affirmation from the remote API
  Future<void> fetchMotivation() async {
    try {
      final r = await http.get(Uri.parse('https://www.affirmations.dev/'));
      if (r.statusCode == 200) {
        final json = jsonDecode(r.body) as Map<String, dynamic>;
        motivation.value = (json['affirmation'] as String?) ?? '';
      }
    } catch (_) {
      // ignore network errors silently for now
    }
  }
}

/// Controller for the dosen (teacher) home; same motivation API but kept separate
class HomeDosenHomeController extends GetxController {
  final motivation = ''.obs;

  Future<void> fetchMotivation() async {
    try {
      final r = await http.get(Uri.parse('https://www.affirmations.dev/'));
      if (r.statusCode == 200) {
        final json = jsonDecode(r.body) as Map<String, dynamic>;
        motivation.value = (json['affirmation'] as String?) ?? '';
      }
    } catch (_) {}
  }
}