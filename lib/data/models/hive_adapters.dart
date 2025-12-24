import 'package:hive/hive.dart';
import 'user_model.dart';
import 'quiz_result_model.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < fieldsCount; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return UserModel(
      email: fields[0] as String,
      passwordHash: fields[1] as String,
      fullName: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.passwordHash)
      ..writeByte(2)
      ..write(obj.fullName);
  }
}

class QuizResultModelAdapter extends TypeAdapter<QuizResultModel> {
  @override
  final int typeId = 2;

  @override
  QuizResultModel read(BinaryReader reader) {
    final fieldsCount = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < fieldsCount; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return QuizResultModel(
      email: fields[0] as String,
      categoryName: fields[1] as String,
      score: fields[2] as int,
      total: fields[3] as int,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, QuizResultModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.categoryName)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.total)
      ..writeByte(4)
      ..write(obj.createdAt);
  }
}
