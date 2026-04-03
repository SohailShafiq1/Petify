import 'package:flutter/foundation.dart';
import '../models/chat_message_model.dart';
import '../providers/auth_provider.dart';
import '../services/chat_api_service.dart';

class ChatProvider extends ChangeNotifier {
  final ChatApiService _chatApiService = ChatApiService();
  AuthProvider _authProvider;
  Map<String, List<ChatMessageModel>> _chatsByPetId = {};
  bool _isLoading = false;
  String? _errorMessage;

  ChatProvider(this._authProvider);

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  List<ChatMessageModel> getChatMessages(String petId) {
    return _chatsByPetId[petId] ?? [];
  }

  Future<void> loadMessages(String petId, {bool silent = false}) async {
    final token = _authProvider.authToken;
    final currentUserId = _authProvider.currentUser?.id;
    if (token == null || token.isEmpty || currentUserId == null) {
      return;
    }

    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final response = await _chatApiService.getMessages(
        token: token,
        petId: petId,
      );
      final messages = (response['messages'] as List?) ?? [];
      _chatsByPetId[petId] = messages
          .map((message) => ChatMessageModel.fromApi(
                message as Map<String, dynamic>,
                currentUserId: currentUserId,
              ))
          .toList();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendMessage({
    required String petId,
    required String message,
  }) async {
    final token = _authProvider.authToken;
    final currentUserId = _authProvider.currentUser?.id;
    if (token == null || token.isEmpty || currentUserId == null) {
      return false;
    }

    try {
      final response = await _chatApiService.sendMessage(
        token: token,
        petId: petId,
        message: message,
      );

      final chatMessage = response['chatMessage'] as Map<String, dynamic>;
      final parsed = ChatMessageModel.fromApi(
        chatMessage,
        currentUserId: currentUserId,
      );

      if (!_chatsByPetId.containsKey(petId)) {
        _chatsByPetId[petId] = [];
      }
      _chatsByPetId[petId]!.add(parsed);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshMessages(String petId) async {
    await loadMessages(petId, silent: true);
  }
}
