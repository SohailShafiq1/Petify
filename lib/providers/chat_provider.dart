import 'package:flutter/foundation.dart';
import '../models/chat_message_model.dart';
import '../services/local_storage_service.dart';

class ChatProvider extends ChangeNotifier {
  final LocalStorageService _storageService;
  Map<String, List<ChatMessageModel>> _chatsByPetId = {};

  ChatProvider(this._storageService);

  List<ChatMessageModel> getChatMessages(String petId) {
    if (!_chatsByPetId.containsKey(petId)) {
      _chatsByPetId[petId] = _storageService.getChatMessagesForPet(petId);
    }
    return _chatsByPetId[petId] ?? [];
  }

  Future<void> sendMessage({
    required String petId,
    required String senderId,
    required String senderName,
    required String message,
    required bool isCurrentUser,
  }) async {
    final chatMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      senderId: senderId,
      senderName: senderName,
      message: message,
      timestamp: DateTime.now(),
      isCurrentUser: isCurrentUser,
    );

    await _storageService.saveChatMessage(chatMessage);
    
    // Update local cache
    if (!_chatsByPetId.containsKey(petId)) {
      _chatsByPetId[petId] = [];
    }
    _chatsByPetId[petId]!.add(chatMessage);
    notifyListeners();

    // Simulate owner response after 2 seconds
    if (isCurrentUser) {
      Future.delayed(const Duration(seconds: 2), () {
        _simulateOwnerResponse(petId);
      });
    }
  }

  Future<void> _simulateOwnerResponse(String petId) async {
    final responses = [
      "Thanks for your interest! The pet is still available.",
      "Hello! Yes, I'm happy to answer any questions.",
      "The pet is in great condition and ready for a new home!",
      "Feel free to come visit and meet the pet anytime.",
      "I can provide more photos if you'd like!",
    ];

    final randomResponse = responses[DateTime.now().millisecond % responses.length];

    final ownerMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      petId: petId,
      senderId: 'owner',
      senderName: 'Pet Owner',
      message: randomResponse,
      timestamp: DateTime.now(),
      isCurrentUser: false,
    );

    await _storageService.saveChatMessage(ownerMessage);
    
    if (!_chatsByPetId.containsKey(petId)) {
      _chatsByPetId[petId] = [];
    }
    _chatsByPetId[petId]!.add(ownerMessage);
    notifyListeners();
  }

  void loadMessages(String petId) {
    _chatsByPetId[petId] = _storageService.getChatMessagesForPet(petId);
    notifyListeners();
  }
}
