import 'package:get/get.dart';
import '../entities/config.dart';
import '../repositories/softtoken_repository.dart';

class GetEncryptedKeyUsecase {
  final SofttokenRepository _repository = Get.find();

  Future<String> call(Config config) async {
    return await _repository.getEncryptedKey(config);
  }
}