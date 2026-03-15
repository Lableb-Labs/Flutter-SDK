import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Abstraction over secure storage for Zid-related sensitive data.
abstract interface class ZidSecureStorage {
  Future<void> saveToken(String token);

  Future<String?> readToken();

  Future<void> clearToken();
}

class ZidSecureStorageImpl implements ZidSecureStorage {
  static const _tokenKey = 'lableb_zid_token';

  final FlutterSecureStorage _storage;

  ZidSecureStorageImpl([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override
  Future<void> saveToken(String token) async {
    if (token.trim().isEmpty) return;
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> readToken() => _storage.read(key: _tokenKey);

  @override
  Future<void> clearToken() => _storage.delete(key: _tokenKey);
}

