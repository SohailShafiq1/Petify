import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../services/local_storage_service.dart';
import '../services/pet_api_service.dart';

class PetsProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  final PetApiService _petApiService = PetApiService();
  List<PetModel> _allPets = [];
  List<PetModel> _myPets = [];
  List<PetModel> _myOrders = [];
  List<PetModel> _mySales = [];
  List<PetModel> _searchResults = [];
  List<PetModel> _favorites = [];
  Set<String> _favoriteIds = {};
  bool _isSearching = false;
  bool _isLoading = false;
  String? _errorMessage;

  PetsProvider(this._storageService) {
    loadPets();
  }

  List<PetModel> get allPets => _allPets;
  List<PetModel> get myPets => _myPets;
  List<PetModel> get myOrders => _myOrders;
  List<PetModel> get mySales => _mySales;
  List<PetModel> get searchResults => _searchResults;
  List<PetModel> get favorites => _favorites;
  bool get isSearching => _isSearching;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final Map<String, List<Map<String, dynamic>>> _commentsCache = {};

  List<Map<String, dynamic>> getCommentsCache(String petId) => _commentsCache[petId] ?? [];

  bool isFavorite(String petId) => _favoriteIds.contains(petId);

  List<PetModel> get topSellingPets {
    return _allPets.take(5).toList();
  }

  Future<void> loadPets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.getAllPets();
      final petsList = response['pets'] as List;
      _allPets = petsList.map((pet) => PetModel.fromJson(pet as Map<String, dynamic>)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyPets(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.getMyPets(token);
      final petsList = response['pets'] as List;
      _myPets = petsList.map((pet) => PetModel.fromJson(pet as Map<String, dynamic>)).toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMyOrders(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.getMyOrders(token);
      final petsList = response['pets'] as List;
      _myOrders = petsList
          .map((pet) => PetModel.fromJson(pet as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMySales(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.getMySales(token);
      final petsList = response['pets'] as List;
      _mySales = petsList
          .map((pet) => PetModel.fromJson(pet as Map<String, dynamic>))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPets(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.searchPets(trimmed);
      final petsList = response['pets'] as List;
      _searchResults = petsList
          .map((pet) => PetModel.fromJson(pet as Map<String, dynamic>))
          .toList();
      _isSearching = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isSearching = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites(String token) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.getFavorites(token);
      final petsList = response['pets'] as List;
      _favorites = petsList
          .map((pet) => PetModel.fromJson(pet as Map<String, dynamic>))
          .toList();
      _favoriteIds = _favorites.map((pet) => pet.id).toSet();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite({
    required String token,
    required PetModel pet,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.toggleFavorite(
        token: token,
        petId: pet.id,
      );

      final isFavorite = response['isFavorite'] as bool? ?? false;
      if (isFavorite) {
        _favoriteIds.add(pet.id);
        if (!_favorites.any((item) => item.id == pet.id)) {
          _favorites.insert(0, pet);
        }
      } else {
        _favoriteIds.remove(pet.id);
        _favorites.removeWhere((item) => item.id == pet.id);
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePetAvailability({
    required String token,
    required PetModel pet,
    required bool isAvailable,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _petApiService.updatePet(
        token: token,
        petId: pet.id,
        name: pet.name,
        category: pet.category,
        age: pet.age,
        description: pet.description,
        price: pet.price,
        ownerContact: pet.ownerContact,
        isAvailable: isAvailable,
      );

      await loadMyPets(token);
      await loadPets();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  void clearSearch() {
    _searchResults = [];
    _isSearching = false;
    _errorMessage = null;
    notifyListeners();
  }

  List<PetModel> getPetsByCategory(String category) {
    return _allPets.where((pet) => pet.category == category).toList();
  }

  PetModel? getPetById(String id) {
    try {
      return _allPets.firstWhere((pet) => pet.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> addPet({
    required String token,
    required String name,
    required String category,
    required String breed,
    required int age,
    required String description,
    required double price,
    required String ownerContact,
    required String city,
    String? imagePath,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petApiService.createPet(
        token: token,
        name: name,
        category: category,
        breed: breed,
        age: age,
        description: description,
        price: price,
        ownerContact: ownerContact,
        city: city,
        imagePath: imagePath,
      );

      await loadPets();
      await loadMyPets(token);
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

  Future<void> refreshPets() async {
    await loadPets();
  }

  Future<bool> buyPet({
    required String token,
    required String petId,
    required String buyerName,
    required String buyerContact,
    required String buyerAddress,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petApiService.buyPet(
        token: token,
        petId: petId,
        buyerName: buyerName,
        buyerContact: buyerContact,
        buyerAddress: buyerAddress,
      );
      await loadPets();
          await loadMyPets(token);
          await loadMyOrders(token);
      await loadMySales(token);
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

  Future<bool> completeDelivery({
    required String token,
    required String petId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petApiService.completeDelivery(token: token, petId: petId);
      await loadMySales(token);
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

  Future<bool> addReview({
    required String token,
    required String petId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _petApiService.addReview(
        token: token,
        petId: petId,
        rating: rating,
        comment: comment,
      );

      await loadMyOrders(token);
      await loadPets();
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

  Future<List<Map<String, dynamic>>> fetchComments(String petId) async {
    try {
      final response = await _petApiService.getComments(petId: petId);
      final comments = (response['comments'] as List?) ?? [];
      final parsed = comments.map((c) => c as Map<String, dynamic>).toList();
      _commentsCache[petId] = parsed;
      notifyListeners();
      return parsed;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return [];
    }
  }

  Future<bool> postComment({
    required String token,
    required String petId,
    required String comment,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _petApiService.addComment(
        token: token,
        petId: petId,
        comment: comment,
      );

      final newComment = (response['comment'] as Map<String, dynamic>?) ?? {};
      final existing = _commentsCache[petId] ?? [];
      existing.insert(0, newComment);
      _commentsCache[petId] = existing;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePet({
    required String token,
    required String petId,
  }) async {
    _errorMessage = null;
    notifyListeners();

    try {
      await _petApiService.deletePet(token: token, petId: petId);
      await loadPets();
      await loadMyPets(token);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }
}
