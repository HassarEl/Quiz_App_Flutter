import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/gradient_button.dart';
import '../widgets/quiz_background.dart';

class RoundsScreen extends StatefulWidget {
  const RoundsScreen({super.key});

  @override
  State<RoundsScreen> createState() => _RoundsScreenState();
}

class _RoundsScreenState extends State<RoundsScreen> {
  int selected = 0;

  final rounds = const [
    {'title': 'Round-1', 'label': 'Easy', 'seconds': 40, 'count': 10, 'catName': 'Général', 'catId': 9},
    {'title': 'Round-2', 'label': 'Medium', 'seconds': 30, 'count': 10, 'catName': 'Informatique', 'catId': 18},
    {'title': 'Round-3', 'label': 'Semi-Medium', 'seconds': 25, 'count': 10, 'catName': 'Math', 'catId': 19},
    {'title': 'Round-4', 'label': 'Hard', 'seconds': 20, 'count': 10, 'catName': 'Histoire', 'catId': 23},
    {'title': 'Round-5', 'label': 'Most-hard', 'seconds': 15, 'count': 10, 'catName': 'Sport', 'catId': 21},
  ];

  String _initials(String fullNameOrEmail) {
    final s = fullNameOrEmail.trim();
    if (s.isEmpty) return 'U';
    if (s.contains('@')) return s.split('@').first[0].toUpperCase();
    final parts = s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  Widget _anim({required Widget child, int delayMs = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, t, _) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, (1 - t) * 14), child: child),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final ok = (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Déconnexion'),
            content: const Text('Tu veux te déconnecter ?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Annuler')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
            ],
          ),
        )) ??
        false;

    if (!ok) return;
    await context.read<AuthProvider>().logout();
    if (context.mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final auth = context.watch<AuthProvider>();

    final email = auth.email ?? '';
    final fullName = auth.getFullName() ?? 'Utilisateur';
    final initials = _initials(fullName != 'Utilisateur' ? fullName : email);

    final results = email.isEmpty ? [] : quiz.getResultsFor(email);
    final avg = email.isEmpty ? 0.0 : quiz.averageScore(email);
    final last = results.isEmpty ? null : results.first;

    final rSel = rounds[selected];

    return Scaffold(
      body: QuizBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
               
                _anim(
                  delayMs: 0,
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Quizo.',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Profil',
                        onPressed: () => context.go('/profile'),
                        icon: const Icon(Icons.person),
                      ),
                      IconButton(
                        tooltip: 'Thème',
                        onPressed: () => context.read<ThemeProvider>().toggle(),
                        icon: const Icon(Icons.brightness_6),
                      ),
                      IconButton(
                        tooltip: 'Logout',
                        onPressed: () => _logout(context),
                        icon: const Icon(Icons.logout),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                
                _anim(
                  delayMs: 60,
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.78),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(colors: [Color(0xFF7C8DFF), Color(0xFFFFB5A3)]),
                          ),
                          child: Text(
                            initials,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(fullName,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                              const SizedBox(height: 2),
                              Text(
                                email,
                                style: Theme.of(context).textTheme.bodySmall,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  _pill('Quizzes', results.length.toString(), Icons.quiz),
                                  const SizedBox(width: 8),
                                  _pill('Avg', '${(avg * 100).toStringAsFixed(1)}%', Icons.bar_chart),
                                  const SizedBox(width: 8),
                                  _pill('Last', last == null ? '—' : '${last.score}/${last.total}', Icons.history),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                
                _anim(
                  delayMs: 120,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Each Round will get harder.',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                _anim(
                  delayMs: 140,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Choisis un round puis démarre le quiz.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

               
                Expanded(
                  child: _anim(
                    delayMs: 180,
                    child: GridView.builder(
                      itemCount: rounds.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 1.30,
                      ),
                      itemBuilder: (_, i) {
                        final r = rounds[i];
                        final isSel = i == selected;

                        return InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => setState(() => selected = i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(color: Colors.white54),
                              color: Colors.white.withOpacity(0.78),
                              gradient: isSel
                                  ? const LinearGradient(colors: [Color(0xFF7C8DFF), Color(0xFFFFB5A3)])
                                  : null,
                              boxShadow: [
                                if (isSel)
                                  BoxShadow(
                                    blurRadius: 18,
                                    offset: const Offset(0, 8),
                                    color: Colors.black.withOpacity(0.10),
                                  )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(999),
                                        color: isSel ? Colors.white.withOpacity(0.18) : Colors.black.withOpacity(0.06),
                                      ),
                                      child: Text(
                                        r['label'] as String,
                                        style: TextStyle(
                                          color: isSel ? Colors.white : Colors.black54,
                                          fontWeight: FontWeight.w800,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Icon(Icons.timer,
                                        size: 18, color: isSel ? Colors.white : Colors.black54),
                                    const SizedBox(width: 4),
                                    Text('${r['seconds']}s',
                                        style: TextStyle(color: isSel ? Colors.white : Colors.black54)),
                                  ],
                                ),
                                const Spacer(),
                                Text(
                                  r['title'] as String,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: isSel ? Colors.white : Colors.black87,
                                      ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  r['catName'] as String,
                                  style: TextStyle(color: isSel ? Colors.white70 : Colors.black54),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Icon(Icons.help_outline,
                                        size: 18, color: isSel ? Colors.white70 : Colors.black54),
                                    const SizedBox(width: 6),
                                    Text(
                                      '${r['count']} questions',
                                      style: TextStyle(color: isSel ? Colors.white70 : Colors.black54),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

               
                _anim(
                  delayMs: 260,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.70),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white54),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${rSel['title']} • ${rSel['catName']} • ${rSel['count']}Q • ${rSel['seconds']}s/Q',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(width: 10),
                        SizedBox(
                          width: 140,
                          child: GradientButton(
                            text: 'Start',
                            onPressed: () async {
                              final r = rounds[selected];
                              quiz.setRound(
                                round: r['title'] as String,
                                seconds: r['seconds'] as int,
                                questionCount: r['count'] as int,
                                catName: r['catName'] as String,
                                catId: r['catId'] as int,
                              );
                              await quiz.startQuiz();
                              if (context.mounted) context.go('/quiz');
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _pill(String title, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: Colors.black.withOpacity(0.06),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black87),
          const SizedBox(width: 6),
          Text('$title: ',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.black54)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}
