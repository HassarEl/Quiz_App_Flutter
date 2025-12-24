import 'dart:convert';
import 'package:flutter/services.dart';
import '../../domain/entities/quiz_question.dart';

class QuizLocalDataSource {
  Future<List<QuizQuestion>> loadQuestions({
    required int amount,
    required int categoryId,
  }) async {
    final raw = await rootBundle.loadString('assets/questions_offline.json');
    final jsonMap = json.decode(raw) as Map<String, dynamic>;
    final list = (jsonMap['questions'] as List).cast<Map<String, dynamic>>();

    final filtered = list.where((q) => q['categoryId'] == categoryId).toList();
    final picked = (filtered.isNotEmpty ? filtered : list).take(amount).toList();

    return picked.map((q) {
      final answers = (q['answers'] as List).map((e) => e.toString()).toList();
      return QuizQuestion(
        question: q['question'].toString(),
        correctAnswer: q['correct'].toString(),
        allAnswers: answers,
      );
    }).toList();
  }
}
