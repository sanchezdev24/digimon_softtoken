// lib/app/modules/home/home_controller.dart (versión simplificada)
import 'package:get/get.dart';
import 'dart:async';
import '../../domain/entities/digimon.dart';
import '../../domain/usecases/generate_otp_usecase.dart';
import '../../domain/usecases/get_digimon_usecase.dart';
import '../../domain/usecases/get_config_usecase.dart';
import '../../domain/usecases/get_encrypted_key_usecase.dart';
//import '../../domain/usecases/encrypt_key_usecase.dart';
import '../../routes/app_routes.dart';

class HomeController extends GetxController {
  final GenerateOtpUsecase _generateOtpUsecase = Get.find();
  final GetDigimonUsecase _getDigimonUsecase = Get.find();
  final GetConfigUsecase _getConfigUsecase = Get.find();
  final GetEncryptedKeyUsecase _getEncryptedKeyUsecase = Get.find();
  //final EncryptKeyUsecase _encryptKeyUsecase = Get.find();
  
  final currentOtp = '------'.obs;
  final timeRemaining = 30.obs;
  final currentDigimon = Rxn<Digimon>();
  final isLoading = false.obs;
  final nickname = 'DigiTrainer'.obs;
  final lastUpdate = ''.obs;
  final errorMessage = ''.obs;
  final apiStatus = 'Inicializando'.obs;
  
  Timer? _otpTimer;
  Timer? _digimonTimer;
  Timer? _countdownTimer;
  
  String? _storedEncryptedKey;
  
  @override
  void onInit() {
    super.onInit();
    _initializeController();
  }
  
  @override
  void onClose() {
    _otpTimer?.cancel();
    _digimonTimer?.cancel();
    _countdownTimer?.cancel();
    super.onClose();
  }
  
  Future<void> _initializeController() async {
    print('HomeController: Initializing...');
    
    // Iniciar timers básicos inmediatamente
    _startOtpGeneration();
    _startCountdown();
    
    // Cargar primer Digimon automáticamente
    await _loadFirstDigimon();
    
    // Iniciar actualizaciones automáticas
    _startDigimonFetching();
  }
  
  Future<void> _loadFirstDigimon() async {
    print('HomeController: Loading first Digimon...');
    
    try {
      apiStatus.value = 'Cargando...';
      
      // Obtener configuración
      final config = await _getConfigUsecase();
      
      // Obtener clave encriptada
      _storedEncryptedKey = await _getEncryptedKeyUsecase(config);
      
      // Cargar primer Digimon
      await _fetchDigimon();
      
      apiStatus.value = 'Listo';
      
    } catch (e) {
      print('HomeController: Error loading first Digimon: $e');
      apiStatus.value = 'Error';
      
      // Usar datos mock para el primer Digimon
      _storedEncryptedKey = 'WsTUj1J9M7Aru+Ko/wgH8w==:5DdVWwWo5djJk9V+P9qGo4mhQQi4ZpywOxl9uNS58eE=';
      await _fetchDigimon();
    }
  }
  
  void _startOtpGeneration() {
    _generateNewOtp();
    _otpTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _generateNewOtp();
    });
  }
  
  void _startDigimonFetching() {
    // Actualizar Digimon cada 30 segundos
    _digimonTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _fetchDigimon();
    });
  }
  
  void _startCountdown() {
    _countdownTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (timeRemaining.value > 0) {
        timeRemaining.value--;
      } else {
        timeRemaining.value = 30;
      }
    });
  }
  
  Future<void> _generateNewOtp() async {
    try {
      final otp = await _generateOtpUsecase();
      currentOtp.value = otp;
      print('HomeController: Generated new OTP: $otp');
    } catch (e) {
      print('HomeController: Error generating OTP: $e');
      // Generar OTP mock
      final random = DateTime.now().millisecondsSinceEpoch % 900000 + 100000;
      currentOtp.value = random.toString();
    }
  }
  
  Future<void> _fetchDigimon() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      
      final config = await _getConfigUsecase();
      
      // Asegurar que tenemos una clave encriptada
      if (_storedEncryptedKey == null) {
        _storedEncryptedKey = await _getEncryptedKeyUsecase(config);
      }
      
      final digimonResponse = await _getDigimonUsecase(
        otp: currentOtp.value,
        encryptedKey: _storedEncryptedKey!,
        nickname: nickname.value,
        config: config,
      );
      
      if (digimonResponse.success && digimonResponse.digimon != null) {
        currentDigimon.value = digimonResponse.digimon;
        lastUpdate.value = DateTime.now().toString().substring(11, 19);
        apiStatus.value = 'Conectado';
        errorMessage.value = '';
        print('HomeController: Got Digimon: ${digimonResponse.digimon!.name}');
      } else {
        errorMessage.value = digimonResponse.message ?? 'Error obteniendo Digimon';
        apiStatus.value = 'Error de API';
      }
      
    } catch (e) {
      print('HomeController: Error fetching Digimon: $e');
      errorMessage.value = 'Error de conexión';
      apiStatus.value = 'Sin conexión';
    } finally {
      isLoading.value = false;
    }
  }
  
  void updateNickname(String newNickname) {
    nickname.value = newNickname;
    print('HomeController: Updated nickname to: $newNickname');
  }
  
  void refreshDigimon() {
    print('HomeController: Manual refresh requested');
    _fetchDigimon();
  }
  
  void viewDigimonDetail() {
    if (currentDigimon.value != null) {
      Get.toNamed(AppRoutes.DIGIMON_DETAIL, arguments: currentDigimon.value);
    }
  }
  
  String get formattedTimeRemaining {
    final minutes = timeRemaining.value ~/ 60;
    final seconds = timeRemaining.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}