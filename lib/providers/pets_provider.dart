import 'package:flutter/foundation.dart';
import '../models/pet_model.dart';
import '../services/local_storage_service.dart';

class PetsProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  List<PetModel> _allPets = [];
  bool _isLoading = false;

  PetsProvider(this._storageService) {
    loadPets();
  }

  List<PetModel> get allPets => _allPets;
  bool get isLoading => _isLoading;

  List<PetModel> get topSellingPets {
    return _storageService.getTopSellingPets(limit: 5);
  }

  void loadPets() {
    _isLoading = true;
    notifyListeners();

    _allPets = _storageService.getAllPets();
    _isLoading = false;
    notifyListeners();
  }

  List<PetModel> getPetsByCategory(String category) {
    return _storageService.getPetsByCategory(category);
  }

  PetModel? getPetById(String id) {
    return _storageService.getPetById(id);
  }

  Future<void> addPet(PetModel pet) async {
    await _storageService.savePet(pet);
    loadPets();
  }

  Future<void> refreshPets() async {
    loadPets();
  }
}
