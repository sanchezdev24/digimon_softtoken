import 'package:shared_preferences/shared_preferences.dart';

class StorageLocalDatasource {
  static const String _decryptedKeyKey = 'decrypted_key';

  Future<void> storeDecryptedKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_decryptedKeyKey, key);
  }

  Future<String?> getDecryptedKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_decryptedKeyKey);
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}