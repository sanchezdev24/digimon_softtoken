import 'package:get/get.dart';
import '../entities/digimon.dart';
import '../entities/config.dart';
import '../repositories/digimon_repository.dart';

class GetDigimonUsecase {
  final DigimonRepository _repository = Get.find();

  Future<DigimonResponse> call({
    required String otp,
    required String encryptedKey,
    required String nickname,
    required Config config,
  }) async {
    return await _repository.getDigimon(
      otp: otp,
      encryptedKey: encryptedKey,
      nickname: nickname,
      config: config,
    );
  }
}