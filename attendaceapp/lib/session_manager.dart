import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
  static String? accessToken;
  static String? refreshToken;
  static String? name;
  static String? email;
  static String? index;
  static String? graduation_year;

  static Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = prefs.getString("access_token");
    refreshToken = prefs.getString("refresh_token");
    name = prefs.getString("name");
    email = prefs.getString("email");
    index = prefs.getString("index");
    graduation_year=prefs.getString("graduation_year");
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static bool isLoggedIn() {
    return accessToken != null;
  }
}
