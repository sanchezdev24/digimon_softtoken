import 'package:dio/dio.dart';
import 'dart:convert';

class NetworkService {
  late Dio _dio;

  NetworkService() {
    _dio = Dio();
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (obj) => print(obj),
    ));
  }

  Future<Response> get(String url, {Map<String, dynamic>? headers}) async {
    return await _dio.get(url, options: Options(headers: headers));
  }

  Future<Response> post(String url, {
    dynamic data,
    Map<String, dynamic>? headers,
  }) async {
    return await _dio.post(url, data: data, options: Options(headers: headers));
  }

  String createBasicAuthHeader(String username, String password) {
    final credentials = '$username:$password';
    final encoded = base64Encode(utf8.encode(credentials));
    return 'Basic $encoded';
  }
}