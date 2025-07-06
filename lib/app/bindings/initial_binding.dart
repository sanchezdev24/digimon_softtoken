import 'package:get/get.dart';
import '../data/repositories/config_repository_impl.dart';
import '../data/repositories/crypto_repository_impl.dart';
import '../data/repositories/softtoken_repository_impl.dart';
import '../data/repositories/digimon_repository_impl.dart';
import '../data/repositories/otp_repository_impl.dart';
import '../data/datasources/remote/config_remote_datasource.dart';
import '../data/datasources/remote/softtoken_remote_datasource.dart';
import '../data/datasources/remote/digimon_remote_datasource.dart';
import '../data/datasources/local/storage_local_datasource.dart';
import '../data/datasources/local/crypto_local_datasource.dart';
import '../data/datasources/local/otp_local_datasource.dart';
import '../domain/repositories/config_repository.dart';
import '../domain/repositories/crypto_repository.dart';
import '../domain/repositories/softtoken_repository.dart';
import '../domain/repositories/digimon_repository.dart';
import '../domain/repositories/otp_repository.dart';
import '../domain/usecases/get_config_usecase.dart';
import '../domain/usecases/get_encrypted_key_usecase.dart';
import '../domain/usecases/decrypt_key_usecase.dart';
import '../domain/usecases/generate_otp_usecase.dart';
import '../domain/usecases/get_digimon_usecase.dart';
import '../domain/usecases/encrypt_key_usecase.dart';
import '../core/services/network_service.dart';
import '../core/services/crypto_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Services
    Get.put<NetworkService>(NetworkService(), permanent: true);
    Get.put<CryptoService>(CryptoService(), permanent: true);

    // Data sources
    Get.put<ConfigRemoteDatasource>(ConfigRemoteDatasource(), permanent: true);
    Get.put<SofttokenRemoteDatasource>(SofttokenRemoteDatasource(), permanent: true);
    Get.put<DigimonRemoteDatasource>(DigimonRemoteDatasource(), permanent: true);
    Get.put<StorageLocalDatasource>(StorageLocalDatasource(), permanent: true);
    Get.put<CryptoLocalDatasource>(CryptoLocalDatasource(), permanent: true);
    Get.put<OtpLocalDatasource>(OtpLocalDatasource(), permanent: true);

    // Repositories
    Get.put<ConfigRepository>(ConfigRepositoryImpl(), permanent: true);
    Get.put<CryptoRepository>(CryptoRepositoryImpl(), permanent: true);
    Get.put<SofttokenRepository>(SofttokenRepositoryImpl(), permanent: true);
    Get.put<DigimonRepository>(DigimonRepositoryImpl(), permanent: true);
    Get.put<OtpRepository>(OtpRepositoryImpl(), permanent: true);

    // Use cases
    Get.put(GetConfigUsecase(), permanent: true);
    Get.put(GetEncryptedKeyUsecase(), permanent: true);
    Get.put(DecryptKeyUsecase(), permanent: true);
    Get.put(GenerateOtpUsecase(), permanent: true);
    Get.put(GetDigimonUsecase(), permanent: true);
    Get.put(EncryptKeyUsecase(), permanent: true);
  }
}