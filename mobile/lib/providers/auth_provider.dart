import 'package:flutter/material.dart';

import '../core/storage/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _user != null;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        email: email,
        password: password,
      );

      await TokenStorage.saveToken(result.token);
      _user = result.user;

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (_) {
      _isLoading = false;
      _errorMessage = 'Login failed. Please check your credentials.';
      notifyListeners();

      return false;
    }
  }

  Future<void> logout() async {
    await TokenStorage.deleteToken();

    _user = null;
    _errorMessage = null;

    notifyListeners();
  }
}