import 'package:get/get.dart';
import 'digimon_detail_controller.dart';

class DigimonDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => DigimonDetailController());
  }
}