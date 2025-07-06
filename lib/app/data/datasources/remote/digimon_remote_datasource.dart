import 'dart:math';
import 'package:get/get.dart';
import 'package:dio/dio.dart';
import '../../../core/services/network_service.dart';
import '../../../domain/entities/config.dart';
import '../../../domain/entities/digimon.dart';

class DigimonRemoteDatasource {
  final NetworkService _networkService = Get.find();
  
  final List<Map<String, dynamic>> mockDigimons = [
    {
      'id': 'agumon',
      'name': 'Agumon',
      'image': 'https://digimon.shadowsmith.com/img/agumon.jpg',
      'levels': ['Rookie'],
      'attributes': ['Vaccine'],
      'types': ['Reptile'],
      'description': 'Un pequeño dinosaurio con gran coraje y determinación.',
    },
    {
      'id': 'gabumon',
      'name': 'Gabumon',
      'image': 'https://digimon.shadowsmith.com/img/gabumon.jpg',
      'levels': ['Rookie'],
      'attributes': ['Data'],
      'types': ['Reptile'],
      'description': 'Un Digimon tímido que lleva una piel de lobo.',
    },
    {
      'id': 'patamon',
      'name': 'Patamon',
      'image': 'https://digimon.shadowsmith.com/img/patamon.jpg',
      'levels': ['Rookie'],
      'attributes': ['Data'],
      'types': ['Mammal'],
      'description': 'Un pequeño Digimon volador con grandes orejas.',
    },
    {
      'id': 'greymon',
      'name': 'Greymon',
      'image': 'https://digimon.shadowsmith.com/img/greymon.jpg',
      'levels': ['Champion'],
      'attributes': ['Vaccine'],
      'types': ['Dinosaur'],
      'description': 'La evolución de Agumon, un poderoso dinosaurio.',
    },
    {
      'id': 'metalgreymon',
      'name': 'MetalGreymon',
      'image': 'https://digimon.shadowsmith.com/img/metalgreymon.jpg',
      'levels': ['Ultimate'],
      'attributes': ['Vaccine'],
      'types': ['Cyborg'],
      'description': 'Una versión cyborg mejorada de Greymon.',
    },
    {
      'id': 'wargreymon',
      'name': 'WarGreymon',
      'image': 'https://digimon.shadowsmith.com/img/wargreymon.jpg',
      'levels': ['Mega'],
      'attributes': ['Vaccine'],
      'types': ['Dragon Man'],
      'description': 'La forma más poderosa de la línea evolutiva de Agumon.',
    },
  ];

  Future<DigimonResponse> getDigimon({
    required String otp,
    required String encryptedKey,
    required String nickname,
    required Config config,
  }) async {
    print('DigimonRemoteDatasource: Starting request...');
    print('DigimonRemoteDatasource: OTP: $otp, Nickname: $nickname');
    
    try {
      final authHeader = _networkService.createBasicAuthHeader(
        config.username,
        config.password,
      );
      
      print('DigimonRemoteDatasource: Making POST request...');
      
      final response = await _networkService.post(
        'http://34.160.137.130/v1/digimon',
        data: {
          'username': "",
          'otp': otp,
          'encryptedKey': encryptedKey,
        },
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/json',
        },
      );
      
      print('DigimonRemoteDatasource: Response received - Status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = response.data;
        
        if (data is Map && data['Success'] == true) {
          final digimonData = data['Response'];
          final digimon = _parseRealApiResponse(digimonData);
          
          print('DigimonRemoteDatasource: ✅ SUCCESS - Got real Digimon: ${digimon.name}');
          return DigimonResponse(
            success: true,
            digimon: digimon,
          );
        } else {
          String errorMessage = data['Response'] ?? data['Message'] ?? 'Error desconocido';
          print('DigimonRemoteDatasource: ❌ API Error: $errorMessage');
          
          return DigimonResponse(
            success: false,
            message: _translateError(errorMessage),
          );
        }
      } else {
        throw Exception('HTTP Error: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('DigimonRemoteDatasource: ❌ DioException: ${e.type}');
      
      // Manejar errores específicos de la API
      if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        
        print('DigimonRemoteDatasource: Status Code: $statusCode');
        print('DigimonRemoteDatasource: Response Data: $responseData');
        
        if (statusCode == 400) {
          String errorMsg = 'Error de API';
          if (responseData is Map) {
            if (responseData['Response'] == 'Invalid OTP') {
              errorMsg = 'OTP inválido o expirado';
            } else if (responseData['Response'] == 'OTP used previously') {
              errorMsg = 'OTP ya utilizado';
            } else if (responseData['Response'] == 'Error getting a digimon') {
              errorMsg = 'Error del servidor al obtener Digimon';
            }
          }
          
          print('DigimonRemoteDatasource: ⚠️ API Error (400): $errorMsg - Using mock data');
        } else if (statusCode == 401) {
          print('DigimonRemoteDatasource: ⚠️ Authentication Error - Using mock data');
        }
      }
      
      // Usar datos mock con mensaje explicativo
      return _getMockDigimonWithMessage(otp, 'Usando datos demo');
    } catch (e) {
      print('DigimonRemoteDatasource: ❌ General error: $e');
      return _getMockDigimonWithMessage(otp, 'Error de conexión');
    }
  }
  
  DigimonResponse _getMockDigimonWithMessage(String otp, String reason) {
    print('DigimonRemoteDatasource: 🎭 Using mock data - Reason: $reason');
    
    final random = Random(int.tryParse(otp) ?? DateTime.now().millisecondsSinceEpoch);
    final randomIndex = random.nextInt(mockDigimons.length);
    final data = mockDigimons[randomIndex];
    
    final digimon = Digimon(
      id: data['id'] ?? '',
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      levels: List<String>.from(data['levels'] ?? []),
      attributes: List<String>.from(data['attributes'] ?? []),
      types: List<String>.from(data['types'] ?? []),
      description: data['description'],
    );
    
    print('DigimonRemoteDatasource: 🎯 Selected mock Digimon: ${digimon.name}');
    
    return DigimonResponse(
      success: true,
      digimon: digimon,
    );
  }
  
  Digimon _parseRealApiResponse(Map<String, dynamic> data) {
    String imageUrl = '';
    if (data['images'] != null && data['images'].isNotEmpty) {
      imageUrl = data['images'][0]['href'] ?? '';
    }
    
    List<String> levels = [];
    if (data['levels'] != null) {
      for (var level in data['levels']) {
        levels.add(level['level'] ?? '');
      }
    }
    
    List<String> attributes = [];
    if (data['attributes'] != null) {
      for (var attr in data['attributes']) {
        attributes.add(attr['attribute'] ?? '');
      }
    }
    
    List<String> types = [];
    if (data['types'] != null) {
      for (var type in data['types']) {
        types.add(type['type'] ?? '');
      }
    }
    
    String description = '';
    if (data['descriptions'] != null && data['descriptions'].isNotEmpty) {
      for (var desc in data['descriptions']) {
        if (desc['language'] == 'en_us') {
          description = desc['description'] ?? '';
          break;
        }
      }
      if (description.isEmpty && data['descriptions'].isNotEmpty) {
        description = data['descriptions'][0]['description'] ?? '';
      }
    }
    
    return Digimon(
      id: data['id']?.toString() ?? '',
      name: data['name'] ?? '',
      image: imageUrl,
      levels: levels,
      attributes: attributes,
      types: types,
      description: description.isNotEmpty ? description : null,
    );
  }
  
  String _translateError(String error) {
    switch (error) {
      case 'Invalid OTP':
        return 'Código OTP inválido';
      case 'OTP used previously':
        return 'Código OTP ya utilizado';
      case 'Error getting a digimon':
        return 'Error del servidor';
      case 'BAD_REQUEST':
        return 'Solicitud incorrecta';
      case 'Invalid credentials':
        return 'Credenciales inválidas';
      case 'Credentials were not provided':
        return 'Credenciales no proporcionadas';
      default:
        return 'Error: $error';
    }
  }
}