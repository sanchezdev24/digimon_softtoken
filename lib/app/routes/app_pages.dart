import 'package:get/get.dart';
import 'app_routes.dart';
import '../modules/splash/splash_page.dart';
import '../modules/splash/splash_binding.dart';
import '../modules/home/home_page.dart';
import '../modules/home/home_binding.dart';
import '../modules/digimon_detail/digimon_detail_page.dart';
import '../modules/digimon_detail/digimon_detail_binding.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashPage(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomePage(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.DIGIMON_DETAIL,
      page: () => DigimonDetailPage(),
      binding: DigimonDetailBinding(),
    ),
  ];
}