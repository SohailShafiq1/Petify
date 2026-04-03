import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../services/chat_api_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final ChatApiService _chatApiService = ChatApiService();
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _threads = [];

  String _getImageUrl(String imagePath) {
    if (imagePath.startsWith('/')) {
      final baseUrl = dotenv.env['API_BASE_URL']?.trim() ?? 'http://localhost:5001';
      return '$baseUrl$imagePath';
    }

    return imagePath;
  }

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads() async {
    final token = context.read<AuthProvider>().authToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _isLoading = false;
        _error = 'Please log in to view chats.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await _chatApiService.getMyThreads(token: token);
      final threads = (response['threads'] as List?) ?? [];
      setState(() {
        _threads = threads.cast<Map<String, dynamic>>();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _loadThreads,
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_threads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No chats yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _threads.length,
      itemBuilder: (context, index) {
        final thread = _threads[index];
        final petJson = (thread['pet'] as Map<String, dynamic>?) ?? {};
        final lastMessage = (thread['lastMessage'] as Map<String, dynamic>?) ?? {};
        final petId = (petJson['id'] ?? petJson['_id'] ?? '').toString();
        final petName = (petJson['name'] ?? 'Chat').toString();
        final imagePath = petJson['imageUrl']?.toString();

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blue.shade50,
              backgroundImage: imagePath != null
                  ? NetworkImage(_getImageUrl(imagePath))
                  : null,
              child: imagePath == null
                  ? const Icon(Icons.pets, color: Colors.blue)
                  : null,
            ),
            title: Text(petName),
            subtitle: Text(
              lastMessage['message']?.toString() ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              context.push('/chat/$petId');
            },
          ),
        );
      },
    );
  }
}
