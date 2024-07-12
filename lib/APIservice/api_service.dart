import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://endpoints.fagoondigital.com';

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
    required String fullName,
    String? googleId,
    String? facebookId,
    String? profilePictureUrl,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'username': username,
        'full_name': fullName,
        'google_id': googleId,
        'facebook_id': facebookId,
        'profile_picture_url': profilePictureUrl,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/refresh'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $refreshToken',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> getCurrentUser({
    required String accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/user/current'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updatePassword({
    required String accessToken,
    required String newPassword,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/updatepassword'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'password': newPassword}),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> updateProfile({
    required String accessToken,
    required Map<String, dynamic> updateFields,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/user/updateprofile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode(updateFields),
    );
    return jsonDecode(response.body);
  }

  Future<Map<String, dynamic>> addNotification({
    required String accessToken,
    required String title,
    required String content,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/notifications/add'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
      body: jsonEncode({'title': title, 'content': content}),
    );
    return jsonDecode(response.body);
  }

  Future<List<dynamic>> getAllNotifications({
    required String accessToken,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl/notifications/all'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $accessToken',
      },
    );
    return jsonDecode(response.body);
  }
}
