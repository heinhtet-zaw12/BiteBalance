import 'package:bite_balance/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    super.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String?,
    );
  }

  factory UserModel.fromSupabaseUser(dynamic supabaseUser) {
    return UserModel(
      id: supabaseUser.id as String,
      email: supabaseUser.email as String?,
    );
  }
}
