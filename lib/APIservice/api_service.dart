import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  static Future<Map<String, dynamic>> signup(
      String email,
      String password,
      String username,
      String fullName,
      String googleId,
      String facebookId,
      String profilePictureUrl) async {
    try {
      final response = await http.post(
        Uri.parse('https://endpoints.fagoondigital.com/auth/signup'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'username': username,
          'full_name': fullName,
          'google_id': googleId,
          'facebook_id': facebookId,
          'profile_picture_url': profilePictureUrl,
        }),
      );

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        print('Signup failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {'message': 'Failed to sign up'};
      }
    } catch (e) {
      print('Error during signup: $e');
      return {'message': 'An error occurred'};
    }
  }
}
