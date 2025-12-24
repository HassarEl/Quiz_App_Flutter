import 'package:hive/hive.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String passwordHash;

  @HiveField(2)
  final String fullName;

  UserModel({
    required this.email,
    required this.passwordHash,
    required this.fullName,
  });
}
