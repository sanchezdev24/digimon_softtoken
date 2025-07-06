import 'package:get/get.dart';
import '../../domain/entities/digimon.dart';

class DigimonDetailController extends GetxController {
  late Digimon digimon;

  @override
  void onInit() {
    super.onInit();
    digimon = Get.arguments as Digimon;
  }
}