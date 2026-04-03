import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class AuthApiService {
  String get _baseUrl {
    final configured = dotenv.env['API_BASE_URL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    return 'http://localhost:5001';
  }

  void _logRequest(String method, String path) {
    assert(() {
      // Debug-only visibility to ensure app is using backend endpoints.
      // ignore: avoid_print
      print('AuthApiService -> $method $_baseUrl$path');
      return true;
    }());
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  Future<Map<String, dynamic>> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _logRequest('POST', '/api/auth/signup');
      final response = await http.post(
        _uri('/api/auth/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': email,
          'password': password,
        }),
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      _logRequest('POST', '/api/auth/login');
      final response = await http.post(
        _uri('/api/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> me(String token) async {
    try {
      _logRequest('GET', '/api/auth/me');
      final response = await http.get(
        _uri('/api/auth/me'),
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
