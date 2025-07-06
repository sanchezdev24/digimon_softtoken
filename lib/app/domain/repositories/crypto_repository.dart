abstract class CryptoRepository {
  Future<String> decrypt(String encryptedData, String key);
  String encrypt(String data, String key);
}