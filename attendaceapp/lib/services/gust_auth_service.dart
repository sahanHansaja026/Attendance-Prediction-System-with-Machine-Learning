import 'dart:convert';
import 'package:attendaceapp/config/api.dart';
import 'package:http/http.dart' as http;
import 'token_service.dart';

class GustAuthService {
  final String baseUrl = "$API_URL"; // your backend IP

  Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse("$baseUrl/gust_login");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // Save tokens in shared preferences
      await TokenService.saveTokens(
        data["access_token"],
        data["refresh_token"],
      );

      return data;
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }
}
