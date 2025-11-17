import '../../../data/models.dart';
import '../../../data/auth_service.dart';

class HomeController {
  /// Mengembalikan daftar entri untuk username (selalu non-null, paling tidak empty list)
  List<JournalEntry> entriesFor(String username) => AuthService.entriesFor(username);

  /// Simpan entri (delegasi ke AuthService in-memory)
  void saveEntry(JournalEntry entry) => AuthService.saveEntry(entry);

  /// Ambil semua user (untuk view dosen)
  List<User> getAllUsers() => AuthService.getAllUsers();
}