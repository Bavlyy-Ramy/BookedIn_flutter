class LoginResponseModel {
  final String token;
  final String type;
  final UserModel user;

  LoginResponseModel({
    required this.token,
    required this.type,
    required this.user,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      token: json["token"],
      type: json["type"],
      user: UserModel.fromJson(json["user"]),
    );
  }
}

class UserModel {
  final int id;
  final String email;
  final String role;

  UserModel({required this.id, required this.email, required this.role});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json["id"],
      email: json["email"],
      role: json["role"],
    );
  }
}
