import 'dart:math';
import 'package:dio/dio.dart';
import 'package:html_unescape/html_unescape.dart';

import '../../domain/entities/quiz_question.dart';

class QuizRemoteDataSource {
  final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  final _unescape = HtmlUnescape();

  Future<List<QuizQuestion>> fetchQuestions({
    required int amount,
    required int categoryId,
  }) async {
    final url = 'https://opentdb.com/api.php?amount=$amount&category=$categoryId&type=multiple';

    final res = await _dio.get(url);
    final data = res.data;

    if (data == null || data['response_code'] != 0) {
      throw Exception('API error: response_code=${data?['response_code']}');
    }

    final results = (data['results'] as List).cast<Map<String, dynamic>>();
    final rng = Random();

    return results.map((q) {
      final question = _unescape.convert(q['question'] as String);
      final correct = _unescape.convert(q['correct_answer'] as String);
      final incorrect = (q['incorrect_answers'] as List)
          .map((e) => _unescape.convert(e as String))
          .toList();

      final all = [...incorrect, correct]..shuffle(rng);

      return QuizQuestion(
        question: question,
        correctAnswer: correct,
        allAnswers: all,
      );
    }).toList();
  }
}
