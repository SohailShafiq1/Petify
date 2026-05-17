import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';

class PetAnalysisService {
  final String baseUrl;

  PetAnalysisService({
    String? baseUrl,
  }) : baseUrl = baseUrl ?? (dotenv.env['API_BASE_URL'] ?? 'http://localhost:5001');

  /// Analyze a pet image using Grok AI
  /// Returns pet details: {petName, breed, expectedAge, origin}
  Future<Map<String, dynamic>> analyzePetImage(File imageFile) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/pets/analyze-image'),
      );

      // Determine MIME type based on file extension
      final fileExt = imageFile.path.split('.').last.toLowerCase();
      String mimeType = 'image/jpeg';
      
      switch (fileExt) {
        case 'jpg':
        case 'jpeg':
          mimeType = 'image/jpeg';
          break;
        case 'png':
          mimeType = 'image/png';
          break;
        case 'gif':
          mimeType = 'image/gif';
          break;
        case 'webp':
          mimeType = 'image/webp';
          break;
      }

      // Add image file with explicit MIME type
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: http.MediaType.parse(mimeType),
        ),
      );

      final response = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Image analysis request timed out');
        },
      );

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseBody);

        if (jsonResponse['petDetails'] != null) {
          return {
            'success': true,
            'petName': jsonResponse['petDetails']['petName'] ?? 'Unknown',
            'breed': jsonResponse['petDetails']['breed'] ?? 'Unknown',
            'expectedAge': jsonResponse['petDetails']['expectedAge'] ?? 'Unknown',
            'origin': jsonResponse['petDetails']['origin'] ?? 'Unknown',
          };
        }
        throw Exception('Invalid response format');
      } else {
        final errorBody = await response.stream.bytesToString();
        throw Exception(
          'Failed to analyze image: ${response.statusCode} - $errorBody',
        );
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Search pets by category or name
  Future<List<dynamic>> searchPets(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/pets/search?q=$query'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        return jsonResponse['pets'] ?? [];
      }
      throw Exception('Failed to search pets');
    } catch (e) {
      return [];
    }
  }
}
