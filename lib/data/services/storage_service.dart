import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Secure storage service for auth tokens
class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  StorageService(this._secureStorage, this._prefs);

  /// Save auth token securely
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  /// Get auth token
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  /// Delete auth token
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save user ID
  Future<void> saveUserId(int userId) async {
    await _prefs.setInt(_userIdKey, userId);
  }

  /// Get user ID
  int? getUserId() {
    return _prefs.getInt(_userIdKey);
  }

  /// Clear all storage
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}

/// Provider for FlutterSecureStorage
final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});

/// Provider for StorageService
final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(
    ref.watch(secureStorageProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
