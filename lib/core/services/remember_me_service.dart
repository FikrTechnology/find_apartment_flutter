import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

class RememberMeService {
  static const String _emailKey = 'remembered_email';
  static const String _passwordKey = 'remembered_password';
  static const String _rememberKey = 'remember_me';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final Logger _logger = Logger();

  Future<bool> saveCredentials({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      _logger.i('Saving credentials: rememberMe=$rememberMe');
      if (rememberMe) {
        await Future.wait([
          _storage.write(key: _emailKey, value: email),
          _storage.write(key: _passwordKey, value: password),
          _storage.write(key: _rememberKey, value: 'true'),
        ]);
        _logger.i('Credentials saved with remember me enabled');
      } else {
        await clearCredentials();
        _logger.i('Credentials cleared - remember me disabled');
      }
      return true;
    } catch (e) {
      _logger.e('Failed to save credentials: $e');
      return false;
    }
  }

  Future<Map<String, String>?> getCredentials() async {
    try {
      final rememberMe = await _storage.read(key: _rememberKey);
      if (rememberMe == 'true') {
        final email = await _storage.read(key: _emailKey);
        final password = await _storage.read(key: _passwordKey);
        if (email != null && password != null) {
          _logger.i('Retrieved saved credentials for: $email');
          return {
            'email': email,
            'password': password,
          };
        }
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get credentials: $e');
      return null;
    }
  }

  Future<bool> isRememberMeEnabled() async {
    try {
      final rememberMe = await _storage.read(key: _rememberKey);
      return rememberMe == 'true';
    } catch (e) {
      _logger.e('Failed to check remember me: $e');
      return false;
    }
  }

  Future<bool> clearCredentials() async {
    try {
      _logger.i('Clearing saved credentials');
      await Future.wait([
        _storage.delete(key: _emailKey),
        _storage.delete(key: _passwordKey),
        _storage.delete(key: _rememberKey),
      ]);
      _logger.i('Credentials cleared successfully');
      return true;
    } catch (e) {
      _logger.e('Failed to clear credentials: $e');
      return false;
    }
  }
}
