import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/local_storage_service.dart';

class ProfileProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  UserModel? _userProfile;

  ProfileProvider(this._storageService) {
    loadProfile();
  }

  UserModel? get userProfile => _userProfile;

  void loadProfile() {
    _userProfile = _storageService.getCurrentUser();
    notifyListeners();
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? imagePath,
  }) async {
    if (_userProfile == null) return;

    final updatedUser = UserModel(
      id: _userProfile!.id,
      name: name ?? _userProfile!.name,
      email: _userProfile!.email,
      password: _userProfile!.password,
      phone: phone ?? _userProfile!.phone,
      imagePath: imagePath ?? _userProfile!.imagePath,
    );

    await _storageService.saveUser(updatedUser);
    _userProfile = updatedUser;
    notifyListeners();
  }

  Future<void> updateProfileImage(String imagePath) async {
    await updateProfile(imagePath: imagePath);
  }
}
