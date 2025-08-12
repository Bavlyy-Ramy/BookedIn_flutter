import 'package:bookedin_app/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bookedin_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:bookedin_app/core/utils/token_storage.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;

  AuthCubit({required this.loginUseCase}) : super(AuthInitial());

  /// Attempt to log in
  Future<void> login(String email, String password) async {
    emit(AuthLoading());
    try {
      final UserEntity user = await loginUseCase(email, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  /// Check if token exists on app start
  Future<void> checkAuthStatus() async {
    final token = await TokenStorage.getToken();
    if (token != null) {
      // Token exists → Ideally call /auth/me here to fetch user
      emit(AuthAuthenticated(UserEntity(id: 0, email: '', role: '')));
    } else {
      emit(AuthLoggedOut());
    }
  }

  /// Log out
  Future<void> logout() async {
    await TokenStorage.clearToken();
    emit(AuthLoggedOut());
  }
}
