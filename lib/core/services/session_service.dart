import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Session Service - Manages user session with INFINITE duration
/// 
/// Session Configuration:
/// - Duration: INFINITE (no expiration)
/// - Storage: Encrypted secure storage (flutter_secure_storage)
/// - Auto-logout: Manual only (user must click logout)
/// - Remember Me: Persists even after logout
/// 
/// User Flow:
/// 1. Login → saveSession()
/// 2. App restart → isSessionActive() checks for token
/// 3. Session remains valid until user logout
/// 4. Logout → clearSession() removes only token, preserves Remember Me
class SessionService {
  static const String _tokenKey = 'access_token';
  static const String _userIdKey = 'user_id';
  static const String _userNameKey = 'user_name';
  static const String _userEmailKey = 'user_email';
  static const String _sessionStartKey = 'session_start_time';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  Future<bool> saveSession({
    required String token,
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    try {
      _logger.i('Saving session for user: $userEmail');
      final now = DateTime.now().toIso8601String();
      await Future.wait([
        _storage.write(key: _tokenKey, value: token),
        _storage.write(key: _userIdKey, value: userId),
        _storage.write(key: _userNameKey, value: userName),
        _storage.write(key: _userEmailKey, value: userEmail),
        _storage.write(key: _sessionStartKey, value: now),
      ]);
      _logger.i('Session saved successfully at: $now');
      return true;
    } catch (e) {
      _logger.e('Failed to save session: $e');
      return false;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      _logger.d('Retrieved token: ${token != null ? '${token.substring(0, 20)}...' : 'null'}');
      return token;
    } catch (e) {
      _logger.e('Failed to get token: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _userIdKey);
    } catch (e) {
      _logger.e('Failed to get user id: $e');
      return null;
    }
  }

  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _userNameKey);
    } catch (e) {
      _logger.e('Failed to get user name: $e');
      return null;
    }
  }

  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _userEmailKey);
    } catch (e) {
      _logger.e('Failed to get user email: $e');
      return null;
    }
  }

  Future<bool> isSessionActive() async {
    try {
      final token = await getToken();
      final isActive = token != null && token.isNotEmpty;
      _logger.d('Session active: $isActive');
      return isActive;
    } catch (e) {
      _logger.e('Failed to check session: $e');
      return false;
    }
  }

  Future<bool> clearSession() async {
    try {
      _logger.i('Clearing session');
      await Future.wait([
        _storage.delete(key: _tokenKey),
        _storage.delete(key: _userIdKey),
        _storage.delete(key: _userNameKey),
        _storage.delete(key: _userEmailKey),
        _storage.delete(key: _sessionStartKey),
      ]);
      _logger.i('Session cleared successfully');
      return true;
    } catch (e) {
      _logger.e('Failed to clear session: $e');
      return false;
    }
  }

  Future<String?> getSessionStartTime() async {
    try {
      return await _storage.read(key: _sessionStartKey);
    } catch (e) {
      _logger.e('Failed to get session start time: $e');
      return null;
    }
  }

  Future<String> getSessionInfo() async {
    try {
      final startTime = await getSessionStartTime();
      final userName = await getUserName();
      final userEmail = await getUserEmail();
      
      if (startTime != null) {
        return 'User: $userName ($userEmail)\nSession Start: $startTime\nDuration: INFINITE (no expiration)';
      }
      return 'No active session';
    } catch (e) {
      _logger.e('Failed to get session info: $e');
      return 'Error getting session info';
    }
  }
}
