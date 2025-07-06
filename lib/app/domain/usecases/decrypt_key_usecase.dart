import 'package:get/get.dart';
import '../repositories/crypto_repository.dart';

class DecryptKeyUsecase {
  final CryptoRepository _repository = Get.find();

  Future<String> call(String encryptedKey, String key) async {
    return await _repository.decrypt(encryptedKey, key);
  }
}