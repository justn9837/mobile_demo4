/// Shared data models used across the app.
library;

class User {
  final String username;
  final String name;
  final int age;
  final String major;
  final String email;
  final String password;

  User({
    required this.username,
    required this.name,
    required this.age,
    required this.major,
    required this.email,
    required this.password,
  });
}

class JournalEntry {
  final String username;
  final String mood;
  final int stressLevel;
  final String note;
  final DateTime timestamp;

  JournalEntry({
    required this.username,
    required this.mood,
    required this.stressLevel,
    required this.note,
    required this.timestamp,
  });
}