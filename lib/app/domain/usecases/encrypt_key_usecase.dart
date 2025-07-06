import 'package:get/get.dart';
import '../repositories/crypto_repository.dart';
import '../../core/services/crypto_service.dart';

class EncryptKeyUsecase {
  final CryptoRepository _repository = Get.find();
  final CryptoService _cryptoService = Get.find();
  
  Future<String> callAsync(String data, String key) async {
    print('EncryptKeyUsecase: 🔐 Encrypting data async: $data with key: $key');
    
    try {
      // Intentar cifrado nativo primero
      final result = await _cryptoService.encryptNative(data, key);
      print('EncryptKeyUsecase: ✅ Native encryption result: $result');
      return result;
    } catch (e) {
      print('EncryptKeyUsecase: ❌ Native encryption failed: $e');
      // Fallback a repository
      final result = _repository.encrypt(data, key);
      print('EncryptKeyUsecase: ✅ Fallback result: $result');
      return result;
    }
  }
  
  // Método síncrono para compatibilidad
  String call(String data, String key) {
    print('EncryptKeyUsecase: 🔐 Encrypting data sync: $data with key: $key');
    final result = _repository.encrypt(data, key);
    print('EncryptKeyUsecase: ✅ Result: $result');
    return result;
  }
}