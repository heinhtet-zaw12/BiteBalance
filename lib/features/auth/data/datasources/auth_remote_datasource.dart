import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/features/auth/data/models/user_model.dart';
import 'package:bite_balance/features/auth/domain/exceptions/email_confirmation_needed.dart';

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
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Login failed: No user returned');
      }

      return UserModel.fromSupabaseUser(response.user!);
    } catch (e, stackTrace) {
      AppLogger.error('Supabase error: signIn', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<UserModel> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Registration failed: No user returned');
      }

      // Check if user already exists (identities array is empty for existing users)
      final identities = response.user!.identities;
      if (identities != null && identities.isEmpty) {
        throw AuthException('An account with this email already exists.');
      }

      if (response.session == null) {
        throw EmailConfirmationNeededException(email);
      }

      return UserModel.fromSupabaseUser(response.user!);
    } catch (e, stackTrace) {
      AppLogger.error('Supabase error: signUp', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e, stackTrace) {
      AppLogger.error('Supabase error: signOut', e, stackTrace);
      rethrow;
    }
  }

  @override
  UserModel? get currentUser {
    final user = client.auth.currentUser;
    if (user == null) return null;
    return UserModel.fromSupabaseUser(user);
  }
}
