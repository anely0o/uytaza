import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/profile/user_config.dart';
import 'api_routes.dart';

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

  // --------- New Methods Added Here ---------
  // Avatar upload
  static Future<void> uploadAvatar(File file) async {
    final req = await multipartPost(ApiRoutes.avatarUpload);
    req.files.add(await filePart(file, 'file'));
    final streamResp = await req.send();
    if (streamResp.statusCode < 200 || streamResp.statusCode >= 300) {
      throw Exception('Avatar upload failed (${streamResp.statusCode})');
    }
  }

  /// PUT /auth/profile (name, surname, address – email is immutable)
  static Future<void> updateProfile(Map<String, dynamic> body) async {
    final resp = await putWithToken(ApiRoutes.profileUpdate, body);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw Exception('Profile update failed (${resp.statusCode})');
    }
  }

  /// Change password knowing the old one
  static Future<void> changePassword(String oldPwd, String newPwd) async {
    await putWithToken(ApiRoutes.passwordChange, {
      'old_password': oldPwd,
      'new_password': newPwd,
    });
  }

  /// "Forgot password" - trigger email
  static Future<void> resetPassword(String email) async {
    await post(ApiRoutes.passwordReset, {'email': email});
  }
  // ------------------------------------------

  // --------- Media & Review Methods ---------
  /// Fetch list of photo URLs for an order
  static Future<http.Response> getMediaByOrder(String orderId) async {
    return await getWithToken('${ApiRoutes.mediaByOrder}/$orderId');
  }

  static Future<List<String>> uploadMediaAndGetUrls(
      String orderId, List<File> files) async {
    final token = await getToken();
    final uri = Uri.parse('$baseUrl${ApiRoutes.mediaUpload}/$orderId');
    List<String> urls = [];

    for (var f in files) {
      final req = http.MultipartRequest('POST', uri)
        ..headers['Authorization'] = 'Bearer $token'
        ..files.add(await http.MultipartFile.fromPath('file', f.path));

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (resp.statusCode < 200 || resp.statusCode >= 300) {
        throw Exception('Upload failed (${resp.statusCode}): ${resp.body}');
      }

      final Map<String, dynamic> body = jsonDecode(resp.body);
      if (body['url'] == null) {
        throw Exception('No URL returned from media-service');
      }
      urls.add(body['url'].toString());
    }

    return urls;
  }

  static Future<double> getRating() async {
    final res = await getWithToken(ApiRoutes.rating);
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      return (data['rating'] as num).toDouble();
    } else {
      throw Exception('Failed to load rating (${res.statusCode})');
    }
  }
  // ------------------------------------------

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

      String payload = parts[1]
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

      String payload = parts[1]
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
    final token = await getToken();
    if (token == null) throw Exception('Token missing');

    final uri = Uri.parse('$baseUrl$endpoint');
    final req = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';

    req.fields[fileField] = fileField;
    req.files.add(await http.MultipartFile.fromPath(fileField, file.path));
    if (fields != null) fields.forEach((k, v) => req.fields[k] = v);

    final streamed = await req.send();
    return await http.Response.fromStream(streamed);
  }

  static Future<http.MultipartRequest> multipartPost(String endpoint, {String? orderId}) async {
    final token = await getToken();
    if (token == null) throw Exception('Token missing');
    final uri = Uri.parse('$baseUrl$endpoint${orderId != null ? '/$orderId' : ''}');
    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';
    return request;
  }

  static Future<http.MultipartFile> filePart(File file, String field) async {
    return await http.MultipartFile.fromPath(field, file.path);
  }

  static Future<http.Response> confirmCompletion(
      String orderId, String photoUrl) async {
    final endpoint = '${ApiRoutes.finishOrder}/$orderId/confirm';
    final token = await getToken();
    print('[CONFIRM] PUT $baseUrl$endpoint  body={photo_url: $photoUrl}');
    return http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'photo_url': photoUrl}),
    );
  }
  /// Set password for first-time login (temporary password)
  static Future<void> setInitialPassword(String tempPass, String newPass) async {
    final res = await putWithToken('/auth/set-initial-password', {
      'old_password': tempPass,
      'new_password': newPass,
    });

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to set initial password (${res.statusCode}): ${res.body}');
    }
  }

  /// Resend temporary password to user's email
  static Future<void> resendPassword(String email) async {
    final res = await post('/auth/resend-password', {
      'email': email,
    });

    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Failed to resend password (${res.statusCode}): ${res.body}');
    }
  }
  static Future<String> getEmail() async {
    final payload = await getTokenPayload();
    if (payload == null || payload['email'] == null) {
      throw Exception('Email not found in token');
    }
    return payload['email'];
  }

  static dynamic decodeJson(http.Response response) {
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } catch (e) {
      print('JSON decode error: $e');
      return null;
    }
  }
}