import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  static Future<void> setLoginStatus(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', value);
  }

  static Future<Map<String, String?>> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {'uid': prefs.getString('uid'), 'name': prefs.getString('name'), 'email': prefs.getString('email'), 'phone': prefs.getString('phone')};
  }

  static Future<void> updateUser(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    data.forEach((key, value) {
      prefs.setString(key, value.toString());
    });
  }

  static Future<void> saveUser(String uid, String name, String email, {String phone = ''}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('name', name);
    await prefs.setString('email', email);
    await prefs.setString('phone', phone);
  }
}
