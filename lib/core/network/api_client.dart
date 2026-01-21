import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../utils/constants.dart';

class ApiClient {
  final Dio _dio;

  ApiClient({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.apiBaseUrl,
                connectTimeout: const Duration(seconds: 10),
                receiveTimeout: const Duration(seconds: 10),
                contentType: Headers.jsonContentType,
              ),
            ) {
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ));
    }
  }

  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
