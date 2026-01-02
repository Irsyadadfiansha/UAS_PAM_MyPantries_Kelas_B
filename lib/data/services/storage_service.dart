import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StorageService {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'user_id';

  StorageService(this._secureStorage, this._prefs);


  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }


  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }


  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

 
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }


  Future<void> saveUserId(int userId) async {
    await _prefs.setInt(_userIdKey, userId);
  }


  int? getUserId() {
    return _prefs.getInt(_userIdKey);
  }

  
  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
    await _prefs.clear();
  }
}


final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
});


final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});


final storageServiceProvider = Provider<StorageService>((ref) {
  return StorageService(
    ref.watch(secureStorageProvider),
    ref.watch(sharedPreferencesProvider),
  );
});
