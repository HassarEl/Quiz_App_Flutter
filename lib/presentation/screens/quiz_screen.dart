import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/quiz_background.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  Future<bool> _confirmQuit(BuildContext context) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Quitter le quiz ?'),
            content: const Text('Ta progression sur cette question sera perdue.'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Quitter')),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    if (quiz.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (quiz.error != null) {
      return Scaffold(
        body: QuizBackground(
          child: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(quiz.error!, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(onPressed: quiz.startQuiz, child: const Text('Réessayer')),
                    TextButton(onPressed: () => context.go('/rounds'), child: const Text('Retour')),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final q = quiz.currentQuestion;
    if (q == null) {
      return const Scaffold(body: Center(child: Text('Aucune question')));
    }

    final progressText = '${quiz.index + 1}/${quiz.total}';

    return Scaffold(
      body: QuizBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                // top bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () async {
                        final ok = await _confirmQuit(context);
                        if (ok && context.mounted) context.go('/rounds');
                      },
                    ),
                    Expanded(
                      child: Center(
                        child: Text(quiz.roundTitle, style: const TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () async {
                        final ok = await _confirmQuit(context);
                        if (!ok) return;
                        final auth = context.read<AuthProvider>();
                        await auth.logout();
                        if (context.mounted) context.go('/login');
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // card main
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Text('No of Question', style: Theme.of(context).textTheme.bodyMedium),
                            const Spacer(),
                            // progress circle like screenshot
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black12),
                                color: Colors.white,
                              ),
                              child: Text(progressText, style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // question gradient card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            gradient: const LinearGradient(
                              colors: [Color(0xFFE7F1FF), Color(0xFFFFD1B8), Color(0xFFF5D5E8)],
                            ),
                          ),
                          child: Text(
                            q.question,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),

                        const SizedBox(height: 14),

                        // time row + progress bar
                        Row(
                          children: [
                            Text('Time', style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(width: 10),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: quiz.timeProgress,
                                  minHeight: 6,
                                  backgroundColor: Colors.black12,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text('00:${quiz.secondsLeft.toString().padLeft(2, '0')}',
                                style: Theme.of(context).textTheme.bodySmall),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // options A/B/C/D
                        Expanded(
                          child: ListView.separated(
                            itemCount: q.allAnswers.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final option = q.allAnswers[i];
                              final letter = String.fromCharCode(65 + i);

                              final isSelected = quiz.selectedAnswer == option;
                              final isCorrect = option == q.correctAnswer;
                              final revealed = quiz.answerState == AnswerState.revealed;

                              Color bg = Colors.white;
                              IconData? trailingIcon;

                              if (!revealed) {
                                if (isSelected) {
                                  bg = const Color(0xFFFFB5A3); // selected
                                }
                              } else {
                                if (isCorrect) {
                                  bg = const Color(0xFF3CD070);
                                  trailingIcon = Icons.check_circle;
                                } else if (isSelected && !isCorrect) {
                                  bg = const Color(0xFFFF4D4D);
                                  trailingIcon = Icons.cancel;
                                }
                              }

                              return InkWell(
                                borderRadius: BorderRadius.circular(12),
                                onTap: () => quiz.selectAnswer(option),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: bg,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 28,
                                        height: 28,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(8),
                                          color: Colors.black.withOpacity(0.06),
                                        ),
                                        child: Text(letter, style: const TextStyle(fontWeight: FontWeight.w700)),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          option,
                                          style: TextStyle(
                                            color: revealed ? Colors.white : Colors.black87,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (trailingIcon != null)
                                        Icon(trailingIcon, color: Colors.white)
                                      else
                                        Icon(
                                          isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                                          color: revealed ? Colors.white : Colors.black45,
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                GradientButton(
                  text: 'Submit Answer',
                  onPressed: (quiz.selectedAnswer == null || quiz.answerState == AnswerState.revealed)
                      ? null
                      : () async {
                          quiz.submit();

                          // if finished after submit delay: check later
                          Future.delayed(const Duration(milliseconds: 900), () async {
                            if (!context.mounted) return;
                            if (quiz.isFinished) {
                              final email = context.read<AuthProvider>().email!;
                              await quiz.saveResult(email: email);
                              if (context.mounted) context.go('/result');
                            }
                          });
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
