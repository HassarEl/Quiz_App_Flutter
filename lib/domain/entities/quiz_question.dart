class QuizQuestion {
  final String question;
  final String correctAnswer;
  final List<String> allAnswers; // correct + incorrect shuffled

  QuizQuestion({
    required this.question,
    required this.correctAnswer,
    required this.allAnswers,
  });
}
