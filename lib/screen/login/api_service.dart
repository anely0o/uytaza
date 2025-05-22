import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// class ApiService {
//   static const String baseUrl = "http://10.0.2.2:8000";
//
//   static Future<http.Response> post(String endpoint, dynamic body) async {
//     return await http.post(
//       Uri.parse('$baseUrl$endpoint'),
//       headers: {'Content-Type': 'application/json'},
//       body: jsonEncode(body),
//     );
//   }
//
//   static Future<String?> getToken() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getString('auth_token');
//   }
//
//   static Future<void> saveToken(String token) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('auth_token', token);
//   }
//
//   static Future<void> logout() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.remove('auth_token');
//   }
// }
class ApiService {
  static const String baseUrl = "http://10.0.2.2:8000";

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
}