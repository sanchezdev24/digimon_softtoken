import 'package:get/get.dart';
import '../../domain/repositories/otp_repository.dart';
import '../datasources/local/otp_local_datasource.dart';

class OtpRepositoryImpl implements OtpRepository {
  final OtpLocalDatasource _localDatasource = Get.find();

  @override
  Future<String> generateOtp() async {
    return await _localDatasource.generateOtp();
  }

  @override
  Future<void> storeDecryptedKey(String key) async {
    await _localDatasource.storeDecryptedKey(key);
  }

  @override
  Future<String?> getDecryptedKey() async {
    return await _localDatasource.getDecryptedKey();
  }
}