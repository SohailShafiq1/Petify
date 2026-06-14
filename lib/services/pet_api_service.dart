import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class PetApiService {
  String get _baseUrl {
    final configured = dotenv.env['API_BASE_URL']?.trim();
    if (configured != null && configured.isNotEmpty) {
      return configured;
    }
    return 'http://localhost:5001';
  }

  Uri _uri(String path) => Uri.parse('$_baseUrl$path');

  String _getMimeType(String filePath) {
    final extension = filePath.toLowerCase().split('.').last;
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'jpg':
      case 'jpeg':
      default:
        return 'image/jpeg';
    }
  }

  Future<Map<String, dynamic>> createPet({
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
    try {
      final request = http.MultipartRequest(
        'POST',
        _uri('/api/pets'),
      );

      request.headers.addAll({
        'Authorization': 'Bearer $token',
      });

      request.fields['name'] = name;
      request.fields['category'] = category;
      request.fields['breed'] = breed;
      request.fields['age'] = age.toString();
      request.fields['description'] = description;
      request.fields['price'] = price.toString();
      request.fields['ownerContact'] = ownerContact;
      request.fields['city'] = city;

      if (imagePath != null && imagePath.isNotEmpty) {
        final mimeType = _getMimeType(imagePath);
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imagePath,
            contentType: http.MediaType('image', mimeType.split('/')[1]),
          ),
        );
      }

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      return _parseMultipartResponse(response.statusCode, responseBody);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> getAllPets() async {
    try {
      final response = await http.get(
        _uri('/api/pets'),
        headers: {'Content-Type': 'application/json'},
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> getMyPets(String token) async {
    try {
      final response = await http.get(
        _uri('/api/pets/my-pets'),
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

  Future<Map<String, dynamic>> getMyOrders(String token) async {
    try {
      final response = await http.get(
        _uri('/api/pets/my-orders'),
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

  Future<Map<String, dynamic>> getMySales(String token) async {
    try {
      final response = await http.get(
        _uri('/api/pets/my-sales'),
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

  Future<Map<String, dynamic>> completeDelivery({
    required String token,
    required String petId,
  }) async {
    try {
      final response = await http.post(
        _uri('/api/pets/$petId/complete-delivery'),
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

  Future<Map<String, dynamic>> getPetById(String petId) async {
    try {
      final response = await http.get(
        _uri('/api/pets/$petId'),
        headers: {'Content-Type': 'application/json'},
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> getPetsByCategory(String category) async {
    try {
      final response = await http.get(
        _uri('/api/pets/category/$category'),
        headers: {'Content-Type': 'application/json'},
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> getOwnerSummary(String ownerId) async {
    try {
      final response = await http.get(
        _uri('/api/pets/owner/$ownerId/summary'),
        headers: {'Content-Type': 'application/json'},
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> searchPets(String query) async {
    try {
      final response = await http.get(
        _uri('/api/pets/search?q=${Uri.encodeQueryComponent(query)}'),
        headers: {'Content-Type': 'application/json'},
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> getFavorites(String token) async {
    try {
      final response = await http.get(
        _uri('/api/pets/favorites'),
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

  Future<Map<String, dynamic>> toggleFavorite({
    required String token,
    required String petId,
  }) async {
    try {
      final response = await http.post(
        _uri('/api/pets/$petId/favorite'),
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

  Future<Map<String, dynamic>> updatePet({
    required String token,
    required String petId,
    required String name,
    required String category,
    required int age,
    required String description,
    required double price,
    required String ownerContact,
    required bool isAvailable,
  }) async {
    try {
      final response = await http.put(
        _uri('/api/pets/$petId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'category': category,
          'age': age,
          'description': description,
          'price': price,
          'ownerContact': ownerContact,
          'isAvailable': isAvailable,
        }),
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> deletePet({
    required String token,
    required String petId,
  }) async {
    try {
      final response = await http.delete(
        _uri('/api/pets/$petId'),
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

  Future<Map<String, dynamic>> buyPet({
    required String token,
    required String petId,
    required String buyerName,
    required String buyerContact,
    required String buyerAddress,
  }) async {
    try {
      final response = await http.post(
        _uri('/api/pets/$petId/buy'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'buyerName': buyerName,
          'buyerContact': buyerContact,
          'buyerAddress': buyerAddress,
        }),
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> addReview({
    required String token,
    required String petId,
    required int rating,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        _uri('/api/pets/$petId/reviews'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rating': rating,
          'comment': comment,
        }),
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> getComments({
    required String petId,
  }) async {
    try {
      final response = await http.get(
        _uri('/api/pets/$petId/comments'),
        headers: {'Content-Type': 'application/json'},
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Future<Map<String, dynamic>> addComment({
    required String token,
    required String petId,
    required String comment,
  }) async {
    try {
      final response = await http.post(
        _uri('/api/pets/$petId/comments'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'comment': comment}),
      );

      return _parseResponse(response);
    } on SocketException {
      throw Exception('Cannot reach backend. Check API_BASE_URL and backend server status.');
    }
  }

  Map<String, dynamic> _parseResponse(http.Response response) {
    final String trimmedBody = response.body.trim();

    // If the server returned HTML (e.g., an index.html page), surface a clearer error
    if (trimmedBody.startsWith('<')) {
      // Log for debug
      assert(() {
        // ignore: avoid_print
        print('API returned HTML instead of JSON: ${response.statusCode}');
        print(trimmedBody.substring(0, trimmedBody.length > 400 ? 400 : trimmedBody.length));
        return true;
      }());

      throw Exception('Received HTML from server (check API_BASE_URL and that the backend is running).');
    }

    final Map<String, dynamic> body = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    }

    // Log actual response for debugging
    assert(() {
      // ignore: avoid_print
      print('API Error Response: statusCode=${response.statusCode}, body=${response.body}');
      return true;
    }());

    final message = body['message'] as String? ?? 'Request failed';
    throw Exception(message);
  }

  Map<String, dynamic> _parseMultipartResponse(int statusCode, String body) {
    final String trimmed = body.trim();

    if (trimmed.startsWith('<')) {
      assert(() {
        // ignore: avoid_print
        print('Multipart API returned HTML instead of JSON: statusCode=$statusCode body=${trimmed.substring(0, trimmed.length > 400 ? 400 : trimmed.length)}');
        return true;
      }());

      throw Exception('Received HTML from server (check API_BASE_URL and that the backend is running).');
    }

    final Map<String, dynamic> parsedBody = body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(body) as Map<String, dynamic>;

    if (statusCode >= 200 && statusCode < 300) {
      return parsedBody;
    }

    assert(() {
      // ignore: avoid_print
      print('API Error Response: statusCode=$statusCode, body=$body');
      return true;
    }());

    final message = parsedBody['message'] as String? ?? 'Request failed';
    throw Exception(message);
  }
}
