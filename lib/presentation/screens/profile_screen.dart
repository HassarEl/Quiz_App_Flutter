import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/quiz_provider.dart';
import '../widgets/quiz_background.dart';
import '../../data/models/quiz_result_model.dart';


class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  String _initials(String fullNameOrEmail) {
    final s = fullNameOrEmail.trim();
    if (s.isEmpty) return 'U';
    // si c'est un email
    if (s.contains('@')) {
      final before = s.split('@').first;
      return (before.isNotEmpty ? before[0] : 'U').toUpperCase();
    }
    final parts = s.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  String _fmtDate(DateTime dt) {
    // ex: 12 Dec 2025, 14:30
    return DateFormat('dd MMM yyyy, HH:mm').format(dt);
  }

  int _streakDays(List<dynamic> results) {
    // Streak = nombre de jours consécutifs où l'utilisateur a joué au moins 1 quiz
    // On prend les dates des résultats et on calcule suite "aujourd'hui / hier / avant-hier ..."
    if (results.isEmpty) return 0;

    final days = results
        .map<DateTime>((r) => (r.createdAt as DateTime))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a)); // desc

    final today = DateTime.now();
    final t = DateTime(today.year, today.month, today.day);

    // si dernier jour != aujourd'hui et != hier => streak 0 (ou 1 si tu veux)
    int diff0 = t.difference(days.first).inDays;
    if (diff0 > 1) return 0;

    int streak = 1;
    for (int i = 0; i < days.length - 1; i++) {
      final diff = days[i].difference(days[i + 1]).inDays;
      if (diff == 1) {
        streak++;
      } else if (diff == 0) {
        continue;
      } else {
        break;
      }
    }
    return streak;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final quiz = context.watch<QuizProvider>();

    final email = auth.email ?? '';
    final fullName = auth.getFullName() ?? 'Utilisateur';
    final initials = _initials(fullName != 'Utilisateur' ? fullName : email);

    final results = quiz.getResultsFor(email); // trié desc (dernier en premier)
    final avg = quiz.averageScore(email);
    final Map<String, QuizResultModel> bestByCat = quiz.bestByCategory(email);

    // Last score
    final last = results.isEmpty ? null : results.first;

    // Best category (par %)
    String bestCategoryName = '—';
    String bestCategoryScore = '—';
    double bestPct = -1;
    
    bestByCat.forEach((String cat, QuizResultModel r) {
      final double pct = r.total == 0 ? 0.0 : (r.score / r.total);
    
      if (pct > bestPct) {
        bestPct = pct;
        bestCategoryName = cat;
        bestCategoryScore = '${r.score}/${r.total}';
      }
    });

    // Best score overall (tous quiz confondus)
    String bestScoreText = '—';
    if (results.isNotEmpty) {
      final best = results.reduce((a, b) => (a.score / (a.total == 0 ? 1 : a.total)) >= (b.score / (b.total == 0 ? 1 : b.total)) ? a : b);
      bestScoreText = '${best.score}/${best.total}';
    }

    final streak = _streakDays(results);

    Widget animatedSection({required Widget child, int delayMs = 0}) {
      // animation légère: slide + fade via TweenAnimationBuilder
      return TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 450 + delayMs),
        curve: Curves.easeOutCubic,
        builder: (context, t, _) {
          return Opacity(
            opacity: t,
            child: Transform.translate(
              offset: Offset(0, (1 - t) * 14),
              child: child,
            ),
          );
        },
      );
    }

    return Scaffold(
      body: QuizBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => context.go('/rounds'),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text('Profil', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Profile Card (Avatar initials + name/email)
                      animatedSection(
                        delayMs: 0,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.78),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: Row(
                            children: [
                              // Avatar initials
                              Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [Color(0xFF7C8DFF), Color(0xFFFFB5A3)],
                                  ),
                                ),
                                child: Text(
                                  initials,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w900,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      fullName,
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(email, style: Theme.of(context).textTheme.bodySmall),
                                  ],
                                ),
                              ),
                              // Badges (Best Score + Streak)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  _badge(
                                    icon: Icons.emoji_events,
                                    text: 'Best $bestScoreText',
                                  ),
                                  const SizedBox(height: 8),
                                  _badge(
                                    icon: Icons.local_fire_department,
                                    text: 'Streak $streak',
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Top: Best category + Last score
                      animatedSection(
                        delayMs: 60,
                        child: Row(
                          children: [
                            Expanded(
                              child: _infoCard(
                                context,
                                title: 'Best category',
                                value: bestCategoryName,
                                subtitle: bestCategoryScore,
                                icon: Icons.star,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _infoCard(
                                context,
                                title: 'Last score',
                                value: last == null ? '—' : '${last.score}/${last.total}',
                                subtitle: last == null ? '' : _fmtDate(last.createdAt),
                                icon: Icons.history,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Stats cards: quizzes + average
                      animatedSection(
                        delayMs: 120,
                        child: Row(
                          children: [
                            Expanded(
                              child: _statCard(
                                context,
                                title: 'Quizzes',
                                value: results.length.toString(),
                                icon: Icons.quiz,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _statCard(
                                context,
                                title: 'Average',
                                value: '${(avg * 100).toStringAsFixed(1)}%',
                                icon: Icons.bar_chart,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Best by category + progress
                      animatedSection(
                        delayMs: 180,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.78),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Meilleur score par catégorie',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 10),
                              if (bestByCat.isEmpty)
                                const Text('Aucun score enregistré.')
                              else
                                ...bestByCat.entries.map((e) {
                                  final r = e.value;
                                  final pct = r.total == 0 ? 0 : (r.score / r.total);
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 10),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                e.key,
                                                style: const TextStyle(fontWeight: FontWeight.w700),
                                              ),
                                            ),
                                            Text('${r.score}/${r.total}'),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(10),
                                          child: LinearProgressIndicator(
                                            value: pct.clamp(0.0, 1.0).toDouble(),
                                            minHeight: 7,
                                            backgroundColor: Colors.black12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // History list with formatted date
                      animatedSection(
                        delayMs: 240,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.78),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Historique',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              const SizedBox(height: 10),
                              if (results.isEmpty)
                                const Text('Aucun quiz joué.')
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: results.length,
                                  separatorBuilder: (_, __) => const Divider(),
                                  itemBuilder: (_, i) {
                                    final r = results[i];
                                    return ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: const Icon(Icons.history),
                                      title: Text(
                                        '${r.categoryName} — ${r.score}/${r.total}',
                                        style: const TextStyle(fontWeight: FontWeight.w800),
                                      ),
                                      subtitle: Text(_fmtDate(r.createdAt)),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _badge({required IconData icon, required String text}) {
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
          Text(text, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
        ],
      ),
    );
  }

  static Widget _statCard(BuildContext context, {required String title, required String value, required IconData icon}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white54),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: const LinearGradient(colors: [Color(0xFF7C8DFF), Color(0xFFFFB5A3)]),
            ),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoCard(
    BuildContext context, {
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.78),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white54),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 6),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
          ],
        ],
      ),
    );
  }
}
