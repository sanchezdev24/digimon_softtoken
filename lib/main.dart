import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'app/routes/app_pages.dart';
import 'app/routes/app_routes.dart';
import 'app/bindings/initial_binding.dart';
import 'app/core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Remote Config
  await _initializeRemoteConfig();

  runApp(MyApp());
}

Future<void> _initializeRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;

  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(minutes: 1),
    minimumFetchInterval: const Duration(hours: 1),
  ));

  // Set default values
  await remoteConfig.setDefaults({
    'key_request': '8ab8305c9e074ea1283abded33064415',
    'key_response': '44724c66b53e3eae3445ffc941ccabf3',
    'username': 'SoftToken-Strat',
    'password': 'db2aee8dac1fb3ad1fa6ba3dbd7622e0',
  });

  try {
    await remoteConfig.fetchAndActivate();
  } catch (e) {
    print('Error fetching remote config: $e');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Digimon SoftToken',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.routes,
      initialBinding: InitialBinding(),
      debugShowCheckedModeBanner: false,
    );
  }
}