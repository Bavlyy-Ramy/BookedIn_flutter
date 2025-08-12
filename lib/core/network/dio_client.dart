import 'dart:io'; // ⬅ Required for HttpClient & X509Certificate
import 'package:dio/dio.dart';
import 'package:dio/io.dart'; // ⬅ Required for DefaultHttpClientAdapter
import '../utils/token_storage.dart';

class DioClient {
  final Dio _dio;

  DioClient({String? baseUrl})
    : _dio = Dio(
        BaseOptions(
          baseUrl:
              baseUrl ??
              'https://ec2-51-20-148-254.eu-north-1.compute.amazonaws.com/api',
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          responseType: ResponseType.json,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ) {
    // ⬅ Add this to bypass SSL verification (DEV ONLY)
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (HttpClient client) {
          client.badCertificateCallback =
              (X509Certificate cert, String host, int port) => true;
          return client;
        };

    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestBody: true,
        requestHeader: true,
        responseBody: true,
        responseHeader: false,
      ),
    );

    // Load token from SharedPreferences when creating DioClient
    _loadToken();
  }

  Dio get dio => _dio;

  Future<void> _loadToken() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
    TokenStorage.saveToken(token); // Save token persistently
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
    TokenStorage.clearToken();
  }
}
