import 'package:get/get.dart';
import '../../../core/services/network_service.dart';
import '../../../domain/entities/config.dart';

class SofttokenRemoteDatasource {
  final NetworkService _networkService = Get.find();
  
  Future<String> getEncryptedKey(Config config) async {
    try {
      print('SofttokenRemoteDatasource: Attempting to get encrypted key from real API...');
      
      final authHeader = _networkService.createBasicAuthHeader(
        config.username,
        config.password,
      );
      
      final response = await _networkService.get(
        'http://34.160.137.130/v1/softtoken', // URL real de la API
        headers: {
          'Authorization': authHeader,
        },
      );
      
      print('SofttokenRemoteDatasource: API Response - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        if (data['Success'] == true) {
          final encryptedKey = data['Response'];
          print('SofttokenRemoteDatasource: Got encrypted key from API: $encryptedKey');
          return encryptedKey;
        } else {
          throw Exception('API Error: ${data['Message'] ?? 'Unknown error'}');
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } catch (e) {
      print('SofttokenRemoteDatasource: API call failed: $e');
      
      // Fallback to mock data
      print('SofttokenRemoteDatasource: Using mock encrypted key');
      await Future.delayed(Duration(milliseconds: 800));
      
      // Mock realista basado en el formato real: base64:base64
      return 'WsTUj1J9M7Aru+Ko/wgH8w==:5DdVWwWo5djJk9V+P9qGo4mhQQi4ZpywOxl9uNS58eE=';
    }
  }
}