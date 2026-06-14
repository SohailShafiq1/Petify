import 'dart:async';

import 'package:flutter/foundation.dart';

import '../providers/auth_provider.dart';
import '../services/chat_api_service.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._authProvider);

  final ChatApiService _chatApiService = ChatApiService();
  final NotificationService _notificationService = NotificationService.instance;
  AuthProvider _authProvider;

  Timer? _pollTimer;
  bool _isPolling = false;
  bool _hasSeededThreads = false;
  String? _activeUserId;
  final Map<String, String> _latestMessageIds = {};

  void syncAuth(AuthProvider authProvider) {
    _authProvider = authProvider;

    final token = authProvider.authToken;
    final userId = authProvider.currentUser?.id;
    if (token == null || token.isEmpty || userId == null) {
      _stopPolling(resetCache: true);
      return;
    }

    final userChanged = _activeUserId != userId;
    _activeUserId = userId;

    if (userChanged) {
      _latestMessageIds.clear();
      _hasSeededThreads = false;
    }

    _startPollingIfNeeded();
  }

  void _startPollingIfNeeded() {
    if (_pollTimer != null) {
      return;
    }

    _pollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _pollForIncomingMessages();
    });

    _pollForIncomingMessages();
  }

  void _stopPolling({bool resetCache = false}) {
    _pollTimer?.cancel();
    _pollTimer = null;
    _isPolling = false;
    if (resetCache) {
      _latestMessageIds.clear();
      _hasSeededThreads = false;
      _activeUserId = null;
    }
  }

  Future<void> _pollForIncomingMessages() async {
    if (_isPolling) {
      return;
    }

    final token = _authProvider.authToken;
    final userId = _authProvider.currentUser?.id;
    if (token == null || token.isEmpty || userId == null) {
      _stopPolling(resetCache: true);
      return;
    }

    _isPolling = true;

    try {
      final response = await _chatApiService.getMyThreads(token: token);
      final threads = (response['threads'] as List?) ?? [];

      for (final thread in threads) {
        final threadMap = thread as Map<String, dynamic>;
        final petJson = (threadMap['pet'] as Map<String, dynamic>?) ?? {};
        final lastMessage = (threadMap['lastMessage'] as Map<String, dynamic>?) ?? {};
        final petId = (petJson['id'] ?? petJson['_id'] ?? '').toString();
        final lastMessageId = (lastMessage['id'] ?? lastMessage['_id'] ?? '').toString();
        final senderId = (lastMessage['senderId'] ?? '').toString();

        if (petId.isEmpty || lastMessageId.isEmpty) {
          continue;
        }

        final previousMessageId = _latestMessageIds[petId];
        _latestMessageIds[petId] = lastMessageId;

        if (!_hasSeededThreads) {
          continue;
        }

        if (previousMessageId != null && previousMessageId != lastMessageId && senderId != userId) {
          final senderName = (lastMessage['senderName'] ?? 'Someone').toString();
          final petName = (petJson['name'] ?? 'a pet').toString();
          final message = (lastMessage['message'] ?? '').toString();

          await _notificationService.showIncomingChatMessage(
            senderName: senderName,
            petName: petName,
            message: message,
          );
        }
      }

      _hasSeededThreads = true;
    } catch (_) {
      // Keep polling; transient network errors should not stop notifications.
    } finally {
      _isPolling = false;
    }
  }

  @override
  void dispose() {
    _stopPolling(resetCache: true);
    super.dispose();
  }
}
