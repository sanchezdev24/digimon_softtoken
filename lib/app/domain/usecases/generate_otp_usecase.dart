import 'package:get/get.dart';
import '../repositories/otp_repository.dart';

class GenerateOtpUsecase {
  final OtpRepository _repository = Get.find();

  Future<String> call() async {
    return await _repository.generateOtp();
  }
}