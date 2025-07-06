import 'package:get/get.dart';
import '../entities/config.dart';
import '../repositories/config_repository.dart';

class GetConfigUsecase {
  final ConfigRepository _repository = Get.find();

  Future<Config> call() async {
    return await _repository.getConfig();
  }
}