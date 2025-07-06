import 'package:get/get.dart';
import '../../domain/entities/config.dart';
import '../../domain/repositories/softtoken_repository.dart';
import '../datasources/remote/softtoken_remote_datasource.dart';

class SofttokenRepositoryImpl implements SofttokenRepository {
  final SofttokenRemoteDatasource _remoteDatasource = Get.find();

  @override
  Future<String> getEncryptedKey(Config config) async {
    return await _remoteDatasource.getEncryptedKey(config);
  }
}