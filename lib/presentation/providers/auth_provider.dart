import 'package:flutter/material.dart';

import '../../core/services/local_storage_service.dart';
import '../../core/utils/security.dart';
import '../../data/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  String? _email;
  String? get email => _email;
  bool get isLoggedIn => _email != null;

  Future<void> loadSession() async {
    _email = LocalStorageService.prefs.getString(LocalStorageService.kLoggedEmail);
    notifyListeners();
  }

  Future<String?> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final box = LocalStorageService.usersBox;
    final exists = box.values.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) return 'Cet email existe déjà.';

    final user = UserModel(
      email: email.toLowerCase().trim(),
      passwordHash: sha256Hash(password),
      fullName: fullName.trim(),
    );

    await box.add(user);
    return null; // success
  }

  Future<String?> login({
    required String email,
    required String password,
  }) async {
    final box = LocalStorageService.usersBox;
    final user = box.values.cast<UserModel?>().firstWhere(
      (u) => u != null && u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => null,
    );

    if (user == null) return 'Compte introuvable.';
    if (user.passwordHash != sha256Hash(password)) return 'Mot de passe incorrect.';

    _email = user.email;
    await LocalStorageService.prefs.setString(LocalStorageService.kLoggedEmail, _email!);
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _email = null;
    await LocalStorageService.prefs.remove(LocalStorageService.kLoggedEmail);
    notifyListeners();
  }

  String? getFullName() {
    if (_email == null) return null;
    final box = LocalStorageService.usersBox;
    final user = box.values.firstWhere(
      (u) => u.email == _email,
      orElse: () => UserModel(email: _email!, passwordHash: '', fullName: ''),
    );
    return user.fullName.isEmpty ? null : user.fullName;
  }
}
