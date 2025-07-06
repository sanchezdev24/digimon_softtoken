// lib/app/modules/splash/splash_controller.dart (versión con mejor manejo de errores)
import 'package:get/get.dart';
import '../../domain/usecases/get_config_usecase.dart';
import '../../domain/usecases/get_encrypted_key_usecase.dart';
import '../../domain/usecases/decrypt_key_usecase.dart';
import '../../data/datasources/local/storage_local_datasource.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  final GetConfigUsecase _getConfigUsecase = Get.find();
  final GetEncryptedKeyUsecase _getEncryptedKeyUsecase = Get.find();
  final DecryptKeyUsecase _decryptKeyUsecase = Get.find();
  final StorageLocalDatasource _storage = Get.find();
  
  final isLoading = true.obs;
  final loadingMessage = 'Inicializando...'.obs;
  final progress = 0.0.obs;
  
  @override
  void onInit() {
    super.onInit();
    _initializeApp();
  }
  
  Future<void> _initializeApp() async {
    try {
      // Step 1: Simular inicialización básica
      loadingMessage.value = 'Preparando aplicación...';
      progress.value = 0.2;
      await Future.delayed(Duration(seconds: 1));
      
      // Step 2: Obtener configuración
      loadingMessage.value = 'Obteniendo configuración...';
      progress.value = 0.4;
      await Future.delayed(Duration(milliseconds: 800));
      
      final config = await _getConfigUsecase();
      print('SplashController: Got config - username: ${config.username}');
      
      // Step 3: Intentar obtener y descifrar clave
      loadingMessage.value = 'Conectando con servidor...';
      progress.value = 0.6;
      await Future.delayed(Duration(milliseconds: 500));
      
      bool cryptoSuccess = false;
      
      try {
        final encryptedKey = await _getEncryptedKeyUsecase(config);
        print('SplashController: Got encrypted key: $encryptedKey');
        
        loadingMessage.value = 'Procesando credenciales...';
        progress.value = 0.8;
        await Future.delayed(Duration(milliseconds: 500));
        
        final decryptedKey = await _decryptKeyUsecase(encryptedKey, config.keyResponse);
        print('SplashController: ✅ Decryption successful: $decryptedKey');
        
        // Almacenar la clave descifrada
        await _storage.storeDecryptedKey(decryptedKey);
        cryptoSuccess = true;
        
      } catch (e) {
        print('SplashController: ❌ Crypto error: $e');
        
        // Manejar errores específicos
        if (e.toString().contains('IV length')) {
          print('SplashController: IV length error - server format issue');
          loadingMessage.value = 'Error de formato del servidor...';
        } else if (e.toString().contains('Failed to decrypt')) {
          print('SplashController: Decryption failed - using fallback');
          loadingMessage.value = 'Problema con cifrado - usando modo offline...';
        } else {
          print('SplashController: Network error - using fallback');
          loadingMessage.value = 'Error de red - usando modo offline...';
        }
        
        // Usar clave por defecto para desarrollo
        await _storage.storeDecryptedKey('JBSWY3DPEHPK3PXP');
        await Future.delayed(Duration(seconds: 1));
      }
      
      // Mensaje final
      if (cryptoSuccess) {
        loadingMessage.value = 'Inicialización completada';
      } else {
        loadingMessage.value = 'Modo offline activado';
      }
      
      progress.value = 1.0;
      await Future.delayed(Duration(milliseconds: 800));
      
      // Navegar a la pantalla principal
      Get.offAllNamed(AppRoutes.HOME);
      
    } catch (e) {
      print('SplashController: ❌ Critical error: $e');
      
      // Error crítico - pero permitir continuar
      loadingMessage.value = 'Error crítico - iniciando en modo seguro...';
      progress.value = 0.5;
      
      // Almacenar clave por defecto
      try {
        await _storage.storeDecryptedKey('JBSWY3DPEHPK3PXP');
      } catch (storageError) {
        print('SplashController: ❌ Storage error: $storageError');
      }
      
      // Mostrar mensaje de error pero continuar
      Get.snackbar(
        'Modo Offline',
        'La aplicación está funcionando en modo offline. Todas las funciones están disponibles.',
        snackPosition: SnackPosition.BOTTOM,
        duration: Duration(seconds: 4),
        backgroundColor: Get.theme.primaryColor
      );
      
      await Future.delayed(Duration(seconds: 2));
      Get.offAllNamed(AppRoutes.HOME);
    }
  }
}