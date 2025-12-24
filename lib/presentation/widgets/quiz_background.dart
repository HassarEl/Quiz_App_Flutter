import 'package:flutter/material.dart';

class QuizBackground extends StatelessWidget {
  final Widget child;
  const QuizBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF5D5E8), // rose clair
            Color(0xFFF6D6A8), // beige/orange
            Color(0xFFE7F1FF), // bleu très clair
          ],
        ),
      ),
      child: child,
    );
  }
}
