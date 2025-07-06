import '../entities/digimon.dart';
import '../entities/config.dart';

abstract class DigimonRepository {
  Future<DigimonResponse> getDigimon({
    required String otp,
    required String encryptedKey,
    required String nickname,
    required Config config,
  });
}