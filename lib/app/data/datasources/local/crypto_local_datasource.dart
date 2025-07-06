import 'package:get/get.dart';
import '../../../core/services/crypto_service.dart';

class CryptoLocalDatasource {
  final CryptoService _cryptoService = Get.find();

  Future<String> decrypt(String encryptedData, String key) async {
    return await _cryptoService.decryptNative(encryptedData, key);
  }

  String encrypt(String data, String key) {
    return _cryptoService.encryptData(data, key);
  }
}