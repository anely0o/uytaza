import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../profile/user_config.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2:8080";

  static Future<http.Response> post(String endpoint, dynamic body) async {
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
  }
  static Future<http.Response> getWithToken(String endpoint) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    print("GET Request to: $baseUrl$endpoint");
    return await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> postWithToken(String endpoint, dynamic body) async {
    final token = await getToken();
    return await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<http.Response> deleteWithToken(String endpoint) async {
    final token = await getToken();
    return await http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  static Future<http.Response> putWithToken(String endpoint, dynamic body) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final encodedBody = jsonEncode(body);
    print("PUT Request to: $baseUrl$endpoint");
    print("Headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${token.substring(0, 4)}...'}");
    print("Body: $encodedBody");

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: encodedBody,
    );
  }
  static Future<http.Response> putWithTokenSub(String endpoint, dynamic body) async {
    final token = await getToken();
    if (token == null) {
      throw Exception('Authentication token not found');
    }

    final encodedBody = jsonEncode(body);
    print("PUT Request to: $baseUrl$endpoint");
    print("Headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${token.substring(0, 4)}...'}");
    print("Body: $encodedBody");

    return await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Future<UserRole?> getUserRole() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      payload = payload
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64.decode(payload));
      final payloadMap = jsonDecode(decoded);
      final roleString = payloadMap['role']?.toString();

      if (roleString == null) return null;

      return UserRole.fromString(roleString);
    } catch (e) {
      print('Error decoding JWT: $e');
      throw Exception('Failed to get user role');
    }
  }

  static Future<Map<String, dynamic>?> getTokenPayload() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      String payload = parts[1];
      payload = payload
          .replaceAll('-', '+')
          .replaceAll('_', '/');

      switch (payload.length % 4) {
        case 2:
          payload += '==';
          break;
        case 3:
          payload += '=';
          break;
      }

      final decoded = utf8.decode(base64.decode(payload));
      return jsonDecode(decoded);
    } catch (e) {
      print('Error decoding JWT: $e');
      return null;
    }
  }

  // Дополнительные методы для работы с токеном
  static Future<bool> isBanned() async {
    final payload = await getTokenPayload();
    return payload?['banned'] == true;
  }

  static Future<bool> isPasswordResetRequired() async {
    final payload = await getTokenPayload();
    return payload?['reset_required'] == true;
  }
  static Future<http.Response> postMultipart(
      String endpoint, {
        required String fileField,
        required File file,
        Map<String, String>? fields,
      }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer ${await getToken()}';
    req.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    fields?.forEach((k, v) => req.fields[k] = v);
    final streamed = await req.send();
    return http.Response.fromStream(streamed);
  }

}