import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> setPassword(String token, String newPassword);
  Future<Map<String, dynamic>> login(String email, String password);
  Future<UserModel> getMe();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient dioClient;

  AuthRemoteDataSourceImpl({required this.dioClient});

  @override
  Future<void> setPassword(String token, String newPassword) async {
    try {
      await dioClient.dio.post(
        '/auth/set-password',
        data: {
          "token": token,
          "newPassword": newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Error setting password');
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await dioClient.dio.post(
        '/auth/login',
        data: {
          "email": email,
          "password": password,
        },
      );
      return response.data;
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  @override
  Future<UserModel> getMe() async {
    try {
      final response = await dioClient.dio.get('/auth/me');
      return UserModel.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get user info');
    }
  }
}
