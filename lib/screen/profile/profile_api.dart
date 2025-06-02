// lib/screen/profile/profile_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api/api_service.dart';

class ProfileApi {
  static Future<String?> fetchAddress() async {
    final res = await ApiService.getWithToken('/api/auth/profile');
    if (res.statusCode == 200) {
      final map = jsonDecode(res.body);
      return map['address'] as String?;
    }
    return null;
  }
}