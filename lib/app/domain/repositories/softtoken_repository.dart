import '../entities/config.dart';

abstract class SofttokenRepository {
  Future<String> getEncryptedKey(Config config);
}