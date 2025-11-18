import 'package:hive/hive.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
class UserModel extends HiveObject {
  @HiveField(0)
  String? id;

  @HiveField(1)
  String? username;

  @HiveField(2)
  String? name;

  @HiveField(3)
  int? age;

  @HiveField(4)
  String? major;

  @HiveField(5)
  String? email;

  @HiveField(6)
  String? avatar;

  @HiveField(7)
  String role;

  UserModel({
    this.id,
    this.username,
    this.name,
    this.age,
    this.major,
    this.email,
    this.avatar,
    this.role = 'user',
  });
}
