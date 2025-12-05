import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/pet_model.dart';
import '../models/chat_message_model.dart';

class LocalStorageService {
  static const String _usersBoxName = 'users';
  static const String _petsBoxName = 'pets';
  static const String _chatsBoxName = 'chats';
  static const String _currentUserIdKey = 'currentUserId';

  late Box<UserModel> _usersBox;
  late Box<PetModel> _petsBox;
  late Box<ChatMessageModel> _chatsBox;
  late SharedPreferences _prefs;

  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  Future<void> init() async {
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(ChatMessageModelAdapter());
    }

    // Open boxes
    _usersBox = await Hive.openBox<UserModel>(_usersBoxName);
    _petsBox = await Hive.openBox<PetModel>(_petsBoxName);
    _chatsBox = await Hive.openBox<ChatMessageModel>(_chatsBoxName);
    
    _prefs = await SharedPreferences.getInstance();
    
    // Add dummy data if first launch
    await _initializeDummyData();
  }

  Future<void> _initializeDummyData() async {
    // Add test user for easy login
    if (_usersBox.isEmpty) {
      final testUser = UserModel(
        id: 'test_user_1',
        name: 'Test User',
        email: 'test@test.com',
        password: '123456',
        phone: '+1234567890',
      );
      await _usersBox.put(testUser.id, testUser);
    }
    if (_petsBox.isEmpty) {
      final dummyPets = [
        PetModel(
          id: '1',
          name: 'Golden Retriever Puppy',
          category: 'Dogs',
          age: 3,
          description: 'Friendly and playful golden retriever puppy. Great with kids and fully vaccinated.',
          price: 500.0,
          ownerName: 'John Doe',
          ownerContact: '+1234567890',
          ownerId: 'owner1',
          createdAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
        PetModel(
          id: '2',
          name: 'Persian Cat',
          category: 'Cats',
          age: 2,
          description: 'Beautiful white Persian cat. Very calm and loves to cuddle.',
          price: 350.0,
          ownerName: 'Jane Smith',
          ownerContact: '+1234567891',
          ownerId: 'owner2',
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
        PetModel(
          id: '3',
          name: 'Budgie Parakeet',
          category: 'Birds',
          age: 1,
          description: 'Colorful budgie, loves to sing. Comes with cage and accessories.',
          price: 50.0,
          ownerName: 'Mike Johnson',
          ownerContact: '+1234567892',
          ownerId: 'owner3',
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
        PetModel(
          id: '4',
          name: 'German Shepherd',
          category: 'Dogs',
          age: 5,
          description: 'Well-trained German Shepherd. Excellent guard dog and family companion.',
          price: 800.0,
          ownerName: 'Sarah Wilson',
          ownerContact: '+1234567893',
          ownerId: 'owner4',
          createdAt: DateTime.now().subtract(const Duration(days: 7)),
        ),
        PetModel(
          id: '5',
          name: 'Siamese Cat',
          category: 'Cats',
          age: 1,
          description: 'Playful Siamese kitten with beautiful blue eyes.',
          price: 400.0,
          ownerName: 'Tom Brown',
          ownerContact: '+1234567894',
          ownerId: 'owner5',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        PetModel(
          id: '6',
          name: 'Goldfish',
          category: 'Fish',
          age: 0,
          description: 'Healthy goldfish with aquarium setup included.',
          price: 30.0,
          ownerName: 'Lisa Davis',
          ownerContact: '+1234567895',
          ownerId: 'owner6',
          createdAt: DateTime.now(),
        ),
      ];

      for (var pet in dummyPets) {
        await _petsBox.put(pet.id, pet);
      }
    }
  }

  // User operations
  Future<void> saveUser(UserModel user) async {
    await _usersBox.put(user.id, user);
  }

  UserModel? getUserByEmail(String email) {
    return _usersBox.values.firstWhere(
      (user) => user.email == email,
      orElse: () => UserModel(
        id: '',
        name: '',
        email: '',
        password: '',
        phone: '',
      ),
    ).id.isEmpty
        ? null
        : _usersBox.values.firstWhere((user) => user.email == email);
  }

  UserModel? getUserById(String id) {
    return _usersBox.get(id);
  }

  // Current user operations
  Future<void> setCurrentUserId(String userId) async {
    await _prefs.setString(_currentUserIdKey, userId);
  }

  String? getCurrentUserId() {
    return _prefs.getString(_currentUserIdKey);
  }

  UserModel? getCurrentUser() {
    final userId = getCurrentUserId();
    if (userId == null) return null;
    return getUserById(userId);
  }

  Future<void> logout() async {
    await _prefs.remove(_currentUserIdKey);
  }

  // Pet operations
  Future<void> savePet(PetModel pet) async {
    await _petsBox.put(pet.id, pet);
  }

  List<PetModel> getAllPets() {
    return _petsBox.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  List<PetModel> getPetsByCategory(String category) {
    return _petsBox.values
        .where((pet) => pet.category == category)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  PetModel? getPetById(String id) {
    return _petsBox.get(id);
  }

  List<PetModel> getTopSellingPets({int limit = 5}) {
    final pets = getAllPets();
    return pets.take(limit).toList();
  }

  // Chat operations
  Future<void> saveChatMessage(ChatMessageModel message) async {
    await _chatsBox.put(message.id, message);
  }

  List<ChatMessageModel> getChatMessagesForPet(String petId) {
    return _chatsBox.values
        .where((chat) => chat.petId == petId)
        .toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
  }

  Future<void> clearAllData() async {
    await _usersBox.clear();
    await _petsBox.clear();
    await _chatsBox.clear();
    await _prefs.clear();
  }
}
