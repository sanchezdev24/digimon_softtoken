import 'package:get/get.dart';
import '../../domain/repositories/crypto_repository.dart';
import '../datasources/local/crypto_local_datasource.dart';

class CryptoRepositoryImpl implements CryptoRepository {
  final CryptoLocalDatasource _localDatasource = Get.find();

  @override
  Future<String> decrypt(String encryptedData, String key) async {
    return await _localDatasource.decrypt(encryptedData, key);
  }

  @override
  String encrypt(String data, String key) {
    return _localDatasource.encrypt(data, key);
  }
}