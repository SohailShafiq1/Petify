import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_api_service.dart';
import '../services/local_storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  final AuthApiService _authApiService = AuthApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider(this._storageService) {
    _loadCurrentUser();
  }

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null && _storageService.getAuthToken() != null;
  String? get authToken => _storageService.getAuthToken();

  Future<void> _loadCurrentUser() async {
    final token = _storageService.getAuthToken();
    _currentUser = _storageService.getCurrentUser();

    if (token != null && token.isNotEmpty) {
      try {
        final meResponse = await _authApiService.me(token);
        final userJson = meResponse['user'] as Map<String, dynamic>?;
        if (userJson != null) {
          final syncedUser = _mapUserJson(userJson);
          await _storageService.saveUser(syncedUser);
          await _storageService.setCurrentUserId(syncedUser.id);
          _currentUser = syncedUser;
        }
      } catch (_) {
        await logout();
      }
    }

    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _authApiService.login(
        email: email,
        password: password,
      );

      final token = response['token'] as String;
      final userJson = response['user'] as Map<String, dynamic>;
      final user = _mapUserJson(userJson);

      await _storageService.setAuthToken(token);
      await _storageService.saveUser(user);
      await _storageService.setCurrentUserId(user.id);
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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
      final response = await _authApiService.signup(
        name: name,
        email: email,
        password: password,
      );

      final token = response['token'] as String;
      final userJson = response['user'] as Map<String, dynamic>;
      final newUser = _mapUserJson(userJson, fallbackPhone: phone);

      await _storageService.setAuthToken(token);
      await _storageService.saveUser(newUser);
      await _storageService.setCurrentUserId(newUser.id);
      _currentUser = newUser;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
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

  UserModel _mapUserJson(
    Map<String, dynamic> userJson, {
    String fallbackPhone = '',
  }) {
    final userId = (userJson['id'] ?? userJson['_id'] ?? '').toString();

    return UserModel(
      id: userId,
      name: (userJson['name'] ?? '').toString(),
      email: (userJson['email'] ?? '').toString(),
      password: '',
      phone: fallbackPhone,
      imagePath: null,
    );
  }
}
