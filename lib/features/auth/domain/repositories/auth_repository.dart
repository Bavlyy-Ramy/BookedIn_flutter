import 'package:bookedin_app/features/auth/domain/entities/user_entity.dart';


abstract class AuthRepository {
  Future<void> setPassword(String token, String newPassword);
  Future<UserEntity> login(String email, String password);
  Future<UserEntity> getMe();
}
