import 'package:otp/otp.dart';
import 'package:ntp/ntp.dart';
import 'package:get/get.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'dart:math';
import 'storage_local_datasource.dart';

class OtpLocalDatasource {
  final StorageLocalDatasource _storage = Get.find();
  
  Future<String> generateOtp() async {
    try {
      String secret = await _getSecret();
      
      // Obtener tiempo sincronizado
      DateTime currentTime = await _getSyncedTime();
      
      // Generar múltiples OTPs con diferentes offsets de tiempo
      List<String> possibleOtps = [];
      
      // Generar OTPs para diferentes ventanas de tiempo
      for (int offset = -2; offset <= 2; offset++) {
        final adjustedTime = currentTime.add(Duration(seconds: offset * 30));
        final otp = _generateTotpForTime(secret, adjustedTime);
        possibleOtps.add(otp);
        
        print('OtpLocalDatasource: Generated OTP for offset $offset: $otp');
      }
      
      // Usar el OTP del tiempo actual (offset 0)
      final mainOtp = possibleOtps[2]; // índice 2 es offset 0
      
      print('OtpLocalDatasource: 🔢 Selected main OTP: $mainOtp');
      print('OtpLocalDatasource: 🕐 Current time: $currentTime');
      print('OtpLocalDatasource: 🔑 Secret: $secret');
      
      return mainOtp;
      
    } catch (e) {
      print('OtpLocalDatasource: ❌ Error generating OTP: $e');
      // Fallback a OTP simple basado en tiempo
      return _generateFallbackOtp();
    }
  }
  
  Future<DateTime> _getSyncedTime() async {
    try {
      final ntpTime = await NTP.now();
      print('OtpLocalDatasource: 🌐 Using NTP time: $ntpTime');
      return ntpTime;
    } catch (e) {
      print('OtpLocalDatasource: ⚠️ NTP failed, using system time: $e');
      return DateTime.now();
    }
  }
  
  String _generateTotpForTime(String secret, DateTime time) {
    try {
      final timeStep = (time.millisecondsSinceEpoch / 1000 / 30).floor();
      
      // Probar diferentes formatos de secret
      String otp = '';
      
      // Formato 1: Secret directo
      try {
        otp = OTP.generateTOTPCodeString(
          secret,
          timeStep * 30 * 1000,
          length: 6,
          interval: 30,
          algorithm: Algorithm.SHA1,
        );
        if (otp.isNotEmpty) return otp;
      } catch (e) {
        print('OtpLocalDatasource: Format 1 failed: $e');
      }
      
      // Formato 2: Secret como base32
      try {
        final base32Secret = _convertToBase32(secret);
        otp = OTP.generateTOTPCodeString(
          base32Secret,
          timeStep * 30 * 1000,
          length: 6,
          interval: 30,
          algorithm: Algorithm.SHA1,
        );
        if (otp.isNotEmpty) return otp;
      } catch (e) {
        print('OtpLocalDatasource: Format 2 failed: $e');
      }
      
      // Formato 3: Hash del secret
      try {
        final hashedSecret = sha1.convert(utf8.encode(secret)).toString();
        otp = OTP.generateTOTPCodeString(
          hashedSecret,
          timeStep * 30 * 1000,
          length: 6,
          interval: 30,
          algorithm: Algorithm.SHA1,
        );
        if (otp.isNotEmpty) return otp;
      } catch (e) {
        print('OtpLocalDatasource: Format 3 failed: $e');
      }
      
      // Formato 4: Implementación manual
      return _generateManualTotp(secret, timeStep);
      
    } catch (e) {
      print('OtpLocalDatasource: ❌ All TOTP formats failed: $e');
      return _generateSimpleOtp(time);
    }
  }
  
  String _generateManualTotp(String secret, int timeStep) {
    try {
      // Implementación manual de TOTP
      final keyBytes = utf8.encode(secret);
      final timeBytes = _intToBytes(timeStep);
      
      // HMAC-SHA1
      final hmac = Hmac(sha1, keyBytes);
      final hash = hmac.convert(timeBytes).bytes;
      
      // Dynamic truncation
      final offset = hash[hash.length - 1] & 0x0F;
      final truncatedHash = ((hash[offset] & 0x7F) << 24) |
                           ((hash[offset + 1] & 0xFF) << 16) |
                           ((hash[offset + 2] & 0xFF) << 8) |
                           (hash[offset + 3] & 0xFF);
      
      final otp = (truncatedHash % 1000000).toString().padLeft(6, '0');
      print('OtpLocalDatasource: 🔧 Manual TOTP: $otp');
      return otp;
      
    } catch (e) {
      print('OtpLocalDatasource: ❌ Manual TOTP failed: $e');
      return _generateSimpleOtp(DateTime.now());
    }
  }
  
  String _generateSimpleOtp(DateTime time) {
    // OTP simple basado en tiempo
    final timeStep = (time.millisecondsSinceEpoch / 1000 / 30).floor();
    final otp = (timeStep % 900000 + 100000).toString();
    print('OtpLocalDatasource: 🎲 Simple OTP: $otp');
    return otp;
  }
  
  String _generateFallbackOtp() {
    // OTP de emergencia
    final random = Random();
    final otp = (random.nextInt(900000) + 100000).toString();
    print('OtpLocalDatasource: 🆘 Fallback OTP: $otp');
    return otp;
  }
  
  List<int> _intToBytes(int value) {
    return [
      (value >> 56) & 0xFF,
      (value >> 48) & 0xFF,
      (value >> 40) & 0xFF,
      (value >> 32) & 0xFF,
      (value >> 24) & 0xFF,
      (value >> 16) & 0xFF,
      (value >> 8) & 0xFF,
      value & 0xFF,
    ];
  }
  
  String _convertToBase32(String input) {
    // Conversión simple a formato base32-like
    final bytes = utf8.encode(input);
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    String result = '';
    
    for (int i = 0; i < bytes.length; i++) {
      result += chars[bytes[i] % chars.length];
    }
    
    // Pad to minimum length
    while (result.length < 16) {
      result += chars[result.length % chars.length];
    }
    
    return result;
  }
  
  Future<String> _getSecret() async {
    String? storedKey = await _storage.getDecryptedKey();
    if (storedKey != null) {
      print('OtpLocalDatasource: 🔑 Using stored key: $storedKey');
      return storedKey;
    }
    
    // Default secret para desarrollo
    const defaultSecret = 'JBSWY3DPEHPK3PXP';
    await _storage.storeDecryptedKey(defaultSecret);
    print('OtpLocalDatasource: 🔑 Using default secret: $defaultSecret');
    return defaultSecret;
  }
  
  Future<void> storeDecryptedKey(String key) async {
    await _storage.storeDecryptedKey(key);
  }
  
  Future<String?> getDecryptedKey() async {
    return await _storage.getDecryptedKey();
  }
}