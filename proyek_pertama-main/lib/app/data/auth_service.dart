import 'models.dart';
import 'hive_service.dart';
import 'supabase_service.dart';

/// AuthService: keeps the previous in-memory behaviour as fallback but will
/// attempt to use Supabase (and Hive for offline store) when configured.
class AuthService {
  static final List<User> _users = [
    User(username: 'Rofika', name: 'Rofika (Dosen)', age: 35, major: 'Psikologi', email: 'rofika@univ.edu', password: 'rofika12'),
    User(username: 'lira', name: 'Lira Aurora', age: 22, major: 'Teknik Informatika', email: 'lira@example.com', password: 'liralira'),
  ];

  static final Map<String, List<JournalEntry>> _userEntries = {};

  static Future<void> initServices() async {
    try {
      await HiveService.init();
      await SupabaseService.init();
    } catch (_) {}
  }

  /// Login by username + password. When Supabase is configured, attempt
  /// to resolve username -> email via `profiles` and sign in with email.
  static Future<User?> login(String username, String password) async {
    // try Supabase first (best-effort)
    try {
      if (SupabaseService.enabled) {
        final profile = await SupabaseService.getProfileByUsername(username);
        if (profile != null && profile.containsKey('email')) {
          final email = profile['email'] as String;
          final res = await SupabaseService.signIn(email, password);
          if (res.session != null || res.user != null) {
            // construct a local User object from profile
            final user = User(
              username: username,
              name: profile['name']?.toString() ?? '',
              age: int.tryParse(profile['age']?.toString() ?? '') ?? 0,
              major: profile['major']?.toString() ?? '',
              email: email,
              password: password,
            );
            // ensure local cache
            if (!_users.any((u) => u.username == username)) _users.add(user);
            return user;
          }
        }
      }
    } catch (_) {}

    // fallback to in-memory auth
    try {
      return _users.firstWhere((u) => u.username == username && u.password == password);
    } catch (_) {
      return null;
    }
  }

  /// Register a new user. If Supabase is available, perform signUp with
  /// email/password and insert profile into `profiles` table.
  static Future<bool> register(User user) async {
    final exists = _users.any((u) => u.username == user.username);
    if (exists) return false;
    _users.add(user);

    // If supabase enabled, attempt to sign up and insert profile (best-effort)
    try {
      if (SupabaseService.enabled) {
        await SupabaseService.signUp(user.email, user.password);
        // even if signUp returns error, attempt to insert profile; Supabase may allow inserting profiles independently
        await SupabaseService.insertProfile({
          'username': user.username,
          'name': user.name,
          'age': user.age,
          'major': user.major,
          'email': user.email,
        });
      }
    } catch (_) {}

    return true;
  }

  static Future<User?> getUserByUsername(String username) async {
    // try supabase profile
    try {
      if (SupabaseService.enabled) {
        final profile = await SupabaseService.getProfileByUsername(username);
        if (profile != null) {
          return User(
            username: username,
            name: profile['name']?.toString() ?? '',
            age: int.tryParse(profile['age']?.toString() ?? '') ?? 0,
            major: profile['major']?.toString() ?? '',
            email: profile['email']?.toString() ?? '',
            password: '',
          );
        }
      }
    } catch (_) {}

    try {
      return _users.firstWhere((u) => u.username == username);
    } catch (_) {
      return null;
    }
  }

  static List<User> getAllUsers() => List.unmodifiable(_users);

  /// Synchronous entriesFor used by UI. Prefers Hive offline store, then in-memory cache.
  static List<JournalEntry> entriesFor(String username) {
    try {
      final hiveEntries = HiveService.getEntriesFor(username);
      if (hiveEntries.isNotEmpty) {
        return hiveEntries.map((m) => JournalEntry(
              username: m['username'] as String,
              mood: m['mood'] as String,
              stressLevel: m['stressLevel'] as int,
              note: m['note'] as String,
              timestamp: DateTime.parse(m['timestamp'] as String),
            )).toList();
      }
    } catch (_) {}
    return List.unmodifiable(_userEntries[username] ?? []);
  }

  /// Async method to fetch entries from Supabase when available.
  static Future<List<JournalEntry>> entriesForRemote(String username) async {
    try {
      if (SupabaseService.enabled) {
        final rows = await SupabaseService.fetchEntries(username);
        final List<JournalEntry> entries = rows.map((m) {
          return JournalEntry(
            username: m['username']?.toString() ?? username,
            mood: m['mood']?.toString() ?? '',
            stressLevel: (m['stress_level'] is int) ? (m['stress_level'] as int) : int.tryParse(m['stress_level']?.toString() ?? '0') ?? 0,
            note: m['note']?.toString() ?? '',
            timestamp: DateTime.tryParse(m['timestamp']?.toString() ?? '') ?? DateTime.now(),
          );
        }).toList();
        // also persist fetched entries into Hive for offline availability
        try {
          for (var e in entries) {
            HiveService.saveEntry(username, {
              'username': e.username,
              'mood': e.mood,
              'stressLevel': e.stressLevel,
              'note': e.note,
              'timestamp': e.timestamp.toIso8601String(),
            });
          }
        } catch (_) {}
        return entries;
      }
    } catch (_) {}
    // fallback to synchronous implementation
    return entriesFor(username);
  }

  static Future<void> saveEntry(JournalEntry entry) async {
    final list = _userEntries.putIfAbsent(entry.username, () => []);
    list.add(entry);
    list.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    // persist to Hive offline store
    try {
      await HiveService.saveEntry(entry.username, {
        'username': entry.username,
        'mood': entry.mood,
        'stressLevel': entry.stressLevel,
        'note': entry.note,
        'timestamp': entry.timestamp.toIso8601String(),
      });
    } catch (_) {}

    // and also try to send to Supabase (best-effort)
    try {
      if (SupabaseService.enabled) {
        await SupabaseService.insertEntry({
          'username': entry.username,
          'mood': entry.mood,
          'stress_level': entry.stressLevel,
          'note': entry.note,
          'timestamp': entry.timestamp.toIso8601String(),
        });
      }
    } catch (_) {}
  }
}