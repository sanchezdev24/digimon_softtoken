import 'package:get/get.dart';
import '../../domain/entities/config.dart';
import '../../domain/repositories/config_repository.dart';
import '../datasources/remote/config_remote_datasource.dart';

class ConfigRepositoryImpl implements ConfigRepository {
  final ConfigRemoteDatasource _remoteDatasource = Get.find();

  @override
  Future<Config> getConfig() async {
    return await _remoteDatasource.getConfig();
  }
}