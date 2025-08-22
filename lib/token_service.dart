import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';
  static const String _userRoleKey = 'user_role';

  // Save token and extract user info
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    
    // Decode JWT to extract user info
    try {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      
      // Extract user ID and role from token
      String? userId = decodedToken['id'];
      String? userRole = decodedToken['role'];
      
      if (userId != null) {
        await prefs.setString(_userIdKey, userId);
      }
      
      if (userRole != null) {
        await prefs.setString(_userRoleKey, userRole);
      }
      
      print('Token saved successfully');
      print('User ID: $userId');
      print('User Role: $userRole');
    } catch (e) {
      print('Error decoding token: $e');
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get user ID from stored token
  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userIdKey);
  }

  // Get user role from stored token
  static Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userRoleKey);
  }

  // Check if token is valid (not expired)
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null) return false;
    
    try {
      return !JwtDecoder.isExpired(token);
    } catch (e) {
      print('Error checking token validity: $e');
      return false;
    }
  }

  // Clear all stored authentication data
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userIdKey);
    await prefs.remove(_userRoleKey);
    print('Token cleared successfully');
  }

  // Get authorization header for API requests
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
    }
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }

  // Get authorization header for multipart requests
  static Future<Map<String, String>> getMultipartAuthHeaders() async {
    final token = await getToken();
    if (token != null) {
      return {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'ngrok-skip-browser-warning': '1',
      };
    }
    return {
      'Accept': 'application/json',
      'ngrok-skip-browser-warning': '1',
    };
  }
}
