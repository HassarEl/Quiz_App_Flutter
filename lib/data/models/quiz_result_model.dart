import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class QuizResultModel extends HiveObject {
  @HiveField(0)
  final String email;

  @HiveField(1)
  final String categoryName;

  @HiveField(2)
  final int score;

  @HiveField(3)
  final int total;

  @HiveField(4)
  final DateTime createdAt;

  QuizResultModel({
    required this.email,
    required this.categoryName,
    required this.score,
    required this.total,
    required this.createdAt,
  });
}
