import 'package:get/get.dart';
import '../../domain/entities/digimon.dart';
import '../../domain/entities/config.dart';
import '../../domain/repositories/digimon_repository.dart';
import '../datasources/remote/digimon_remote_datasource.dart';

class DigimonRepositoryImpl implements DigimonRepository {
  final DigimonRemoteDatasource _remoteDatasource = Get.find();

  @override
  Future<DigimonResponse> getDigimon({
    required String otp,
    required String encryptedKey,
    required String nickname,
    required Config config,
  }) async {
    return await _remoteDatasource.getDigimon(
      otp: otp,
      encryptedKey: encryptedKey,
      nickname: nickname,
      config: config,
    );
  }
}