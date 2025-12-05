import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._storageService) {
    _loadCurrentUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  void _loadCurrentUser() {
    _currentUser = _storageService.getCurrentUser();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

      final user = _storageService.getUserByEmail(email);
      
      if (user == null) {
        _errorMessage = 'User not found. Please sign up.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (user.password != password) {
        _errorMessage = 'Incorrect password.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      await _storageService.setCurrentUserId(user.id);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'An error occurred during login.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signup({
    required String name,
    required String email,
    required String password,
    required String phone,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500)); // Simulate loading

      // Check if user already exists
      final existingUser = _storageService.getUserByEmail(email);
      if (existingUser != null) {
        _errorMessage = 'User with this email already exists.';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Create new user
      final newUser = UserModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        password: password,
        phone: phone,
      );

      await _storageService.saveUser(newUser);
      await _storageService.setCurrentUserId(newUser.id);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'An error occurred during signup.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storageService.logout();
    _currentUser = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
