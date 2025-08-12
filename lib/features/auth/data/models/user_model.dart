import 'package:bookedin_app/features/auth/domain/entities/user_entity.dart';



class UserModel extends UserEntity {
  const UserModel({
    required int id,
    required String email,
    required String role,
  }) : super(id: id, email: email, role: role);

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "role": role,
    };
  }
}
