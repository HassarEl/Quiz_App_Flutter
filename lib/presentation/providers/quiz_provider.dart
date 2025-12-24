import 'dart:async';
import 'package:flutter/material.dart';

import '../../core/services/local_storage_service.dart';
import '../../data/datasources/quiz_local_datasource.dart';
import '../../data/datasources/quiz_remote_datasource.dart';
import '../../data/models/quiz_result_model.dart';
import '../../domain/entities/quiz_question.dart';

enum AnswerState { idle, selected, revealed }

class QuizProvider extends ChangeNotifier {
  final QuizRemoteDataSource _remote = QuizRemoteDataSource();
  final QuizLocalDataSource _local = QuizLocalDataSource();

  bool isLoading = false;
  String? error;

  List<QuizQuestion> questions = [];
  int index = 0;
  int score = 0;

  // round/category
  String roundTitle = 'Round-1';
  String categoryName = 'Général';
  int categoryId = 9;
  int secondsPerQuestion = 40;
  int amount = 10;

  // timer
  Timer? _timer;
  int secondsLeft = 40;

  // answers ui
  String? selectedAnswer;
  AnswerState answerState = AnswerState.idle;

  void setRound({
    required String round,
    required int seconds,
    required int questionCount,
    required String catName,
    required int catId,
  }) {
    roundTitle = round;
    secondsPerQuestion = seconds;
    amount = questionCount;
    categoryName = catName;
    categoryId = catId;
    notifyListeners();
  }

  double get timeProgress => secondsPerQuestion == 0 ? 0 : (secondsLeft / secondsPerQuestion).clamp(0, 1);
  bool get isFinished => questions.isNotEmpty && index >= questions.length;
  int get total => questions.length;

  QuizQuestion? get currentQuestion {
    if (questions.isEmpty || isFinished) return null;
    return questions[index];
  }

  Future<void> startQuiz() async {
    isLoading = true;
    error = null;
    questions = [];
    index = 0;
    score = 0;
    _stopTimer();
    secondsLeft = secondsPerQuestion;
    selectedAnswer = null;
    answerState = AnswerState.idle;
    notifyListeners();

    try {
      // try online first
      questions = await _remote.fetchQuestions(amount: amount, categoryId: categoryId);
    } catch (_) {
      // fallback offline
      try {
        questions = await _local.loadQuestions(amount: amount, categoryId: categoryId);
      } catch (e) {
        error = 'Impossible de charger les questions (online/offline).';
      }
    }

    isLoading = false;
    notifyListeners();

    if (error == null && questions.isNotEmpty) {
      _startTimer();
    }
  }

  void selectAnswer(String value) {
    if (answerState == AnswerState.revealed) return;
    selectedAnswer = value;
    answerState = AnswerState.selected;
    notifyListeners();
  }

  void submit() {
    final q = currentQuestion;
    if (q == null) return;
    if (selectedAnswer == null) return;

    answerState = AnswerState.revealed;

    if (selectedAnswer == q.correctAnswer) score++;

    _stopTimer();

    // wait 700ms then next
    Future.delayed(const Duration(milliseconds: 700), () {
      index++;
      if (!isFinished) {
        selectedAnswer = null;
        answerState = AnswerState.idle;
        secondsLeft = secondsPerQuestion;
        _startTimer();
      }
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> saveResult({required String email}) async {
    final result = QuizResultModel(
      email: email,
      categoryName: categoryName,
      score: score,
      total: questions.length,
      createdAt: DateTime.now(),
    );
    await LocalStorageService.resultsBox.add(result);
  }

  List<QuizResultModel> getResultsFor(String email) {
    return LocalStorageService.resultsBox.values
        .where((r) => r.email == email)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  // ✅ Stats
  double averageScore(String email) {
    final res = getResultsFor(email);
    if (res.isEmpty) return 0;
    final avg = res.map((e) => e.score / (e.total == 0 ? 1 : e.total)).reduce((a, b) => a + b) / res.length;
    return avg;
  }

  Map<String, QuizResultModel> bestByCategory(String email) {
    final res = getResultsFor(email);
    final map = <String, QuizResultModel>{};
    for (final r in res) {
      final prev = map[r.categoryName];
      if (prev == null || r.score > prev.score) map[r.categoryName] = r;
    }
    return map;
  }

  // timer
  void _startTimer() {
    _stopTimer();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      secondsLeft--;
      if (secondsLeft <= 0) {
        secondsLeft = 0;
        _stopTimer();
        // auto submit (si rien choisi -> passe)
        if (selectedAnswer == null) {
          index++;
          if (!isFinished) {
            secondsLeft = secondsPerQuestion;
            _startTimer();
          }
          notifyListeners();
          return;
        }
        submit();
      }
      notifyListeners();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
