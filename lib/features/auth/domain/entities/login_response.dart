import 'package:equatable/equatable.dart';

class LoginResponse extends Equatable {
  final String token;
  final String type;
  final String email;
  final String role;

  const LoginResponse({
    required this.token,
    required this.type,
    required this.email,
    required this.role,
  });

  @override
  List<Object?> get props => [token, type, email, role];
}
