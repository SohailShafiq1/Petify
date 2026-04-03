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
  bool _isLoading = false;
  String? _errorMessage;

  PetsProvider(this._storageService) {
    loadPets();
  }

  List<PetModel> get allPets => _allPets;
  List<PetModel> get myPets => _myPets;
  List<PetModel> get myOrders => _myOrders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
    required int age,
    required String description,
    required double price,
    required String ownerContact,
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
        age: age,
        description: description,
        price: price,
        ownerContact: ownerContact,
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
}
