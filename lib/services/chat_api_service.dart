import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ChatApiService {
  String get _baseUrl {
    final configured = dotenv.env['API_BASE_URL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    return 'http://localhost:5001';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> getMessages({
    required String token,
    required String petId,
  }) async {
    try {
      final response = await http.get(
        _uri('/api/chats/$petId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> sendMessage({
    required String token,
    required String petId,
    required String message,
  }) async {
    try {
      final response = await http.post(
        _uri('/api/chats/$petId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'message': message}),
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final Map<String, dynamic> body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    final message = body['message'] as String? ?? 'Request failed';
    throw Exception(message);
  }
}
