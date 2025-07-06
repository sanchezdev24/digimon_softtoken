abstract class OtpRepository {
  Future<String> generateOtp();
  Future<void> storeDecryptedKey(String key);
  Future<String?> getDecryptedKey();
}