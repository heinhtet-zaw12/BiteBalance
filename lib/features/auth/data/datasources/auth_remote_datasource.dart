import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signIn({
    required String email,
    required String password,
  });

  Future<UserModel> signUp({
    required String email,
    required String password,
  });

  Future<void> signOut();

  UserModel? get currentUser;
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient client;

  AuthRemoteDataSourceImpl(this.client);

  @override
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Login failed: No user returned');
    }

    return UserModel.fromSupabaseUser(response.user!);
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
    );

    if (response.user == null) {
      throw Exception('Registration failed: No user returned');
    }

    return UserModel.fromSupabaseUser(response.user!);
  }

  @override
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  @override
  UserModel? get currentUser {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }
}
