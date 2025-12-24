import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'presentation/providers/auth_provider.dart';
import 'presentation/screens/rounds_screen.dart';
import 'presentation/screens/login_screen.dart';
import 'presentation/screens/register_screen.dart';
import 'presentation/screens/quiz_screen.dart';
import 'presentation/screens/result_screen.dart';
import 'presentation/screens/profile_screen.dart';
import 'presentation/screens/splash_screen.dart';

GoRouter buildRouter(BuildContext context) {
  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: context.read<AuthProvider>(),
    redirect: (ctx, state) {
      final auth = ctx.read<AuthProvider>();
      final logged = auth.isLoggedIn;

      final goingToAuth = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/splash';

      if (!logged && !goingToAuth) return '/login';
      if (logged && (state.matchedLocation == '/login' || state.matchedLocation == '/register')) {
        return '/rounds';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/splash', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/rounds', builder: (_, __) => const RoundsScreen()),
      GoRoute(path: '/quiz', builder: (_, __) => const QuizScreen()),
      GoRoute(path: '/result', builder: (_, __) => const ResultScreen()),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
}
