import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthSwitch extends StatelessWidget {
  final bool isLogin; // true si on est dans LoginScreen

  const AuthSwitch({super.key, required this.isLogin});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isLogin ? null : () => context.go('/login'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: isLogin
                      ? const LinearGradient(colors: [Color(0xFF7C8DFF), Color(0xFFFFB5A3)])
                      : null,
                ),
                child: Text(
                  'Login',
                  style: TextStyle(
                    color: isLogin ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: isLogin ? () => context.go('/register') : null,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: !isLogin
                      ? const LinearGradient(colors: [Color(0xFF7C8DFF), Color(0xFFFFB5A3)])
                      : null,
                ),
                child: Text(
                  'Register',
                  style: TextStyle(
                    color: !isLogin ? Colors.white : Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
