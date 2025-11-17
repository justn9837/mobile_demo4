import 'models.dart';

/// Lightweight in-memory auth + entry storage service.
/// Keeps default users Rofika (dosen) and lira (mahasiswa).
class AuthService {
  static final List<User> _users = [
    User(username: 'Rofika', name: 'Rofika (Dosen)', age: 35, major: 'Psikologi', email: 'rofika@univ.edu', password: 'rofika12'),
    User(username: 'lira', name: 'Lira Aurora', age: 22, major: 'Teknik Informatika', email: 'lira@example.com', password: 'liralira'),
  ];

  static final Map<String, List<JournalEntry>> _userEntries = {};

  static User? login(String username, String password) {
    try {
      return _users.firstWhere((u) => u.username == username && u.password == password);
    } catch (_) {
      return null;
    }
  }

  static bool register(User user) {
    final exists = _users.any((u) => u.username == user.username);
    if (exists) return false;
    _users.add(user);
    return true;
  }

  static User? getUserByUsername(String username) {
    try {
      return _users.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  static List<User> getAllUsers() => List.unmodifiable(_users);

  static List<JournalEntry> entriesFor(String username) => List.unmodifiable(_userEntries[username] ?? []);

  static void saveEntry(JournalEntry entry) {
    final list = _userEntries.putIfAbsent(entry.username, () => []);
    list.add(entry);
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }
}