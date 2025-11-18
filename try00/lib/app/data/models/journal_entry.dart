import 'package:hive/hive.dart';

part 'journal_entry.g.dart';

@HiveType(typeId: 1)
class JournalEntry extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? userId;

  @HiveField(2)
  String? username;

  @HiveField(3)
  String mood;

  @HiveField(4)
  int stressLevel;

  @HiveField(5)
  String? note;

  @HiveField(6)
  DateTime timestamp;

  @HiveField(7)
  bool pending;

  JournalEntry({
    this.id,
    this.userId,
    this.username,
    this.mood = 'neutral',
    this.stressLevel = 0,
    this.note,
    DateTime? timestamp,
    this.pending = true,
  }) : timestamp = timestamp ?? DateTime.now();
}
