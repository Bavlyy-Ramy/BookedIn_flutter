import 'package:bookedin_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bookedin_app/features/auth/domain/entities/user_entity.dart';

import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/network/dio_client.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final DioClient dioClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.dioClient,
  });

  @override
  Future<void> setPassword(String token, String newPassword) {
    return remoteDataSource.setPassword(token, newPassword);
  }

  @override
  Future<UserEntity> login(String email, String password) async {
    final result = await remoteDataSource.login(email, password);
    final token = result['token'];

    // Store token in SharedPreferences and Dio
    dioClient.setAuthToken(token);

    return UserModel.fromJson(result['user']);
  }

  @override
  Future<UserEntity> getMe() {
    return remoteDataSource.getMe();
  }
}
