import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bite_balance/features/auth/domain/entities/user.dart';
import 'package:bite_balance/features/auth/domain/exceptions/email_confirmation_needed.dart';
import 'package:bite_balance/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signIn(
        email: email,
        password: password,
      );
      return Right(user);
    } on AuthException catch (e) {
      AppLogger.error('Failed to signIn', e);
      return Left(AuthFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to signIn: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to signIn', e, stackTrace);
      return Left(AuthFailure('Authentication failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final user = await remoteDataSource.signUp(
        email: email,
        password: password,
      );
      return Right(user);
    } on EmailConfirmationNeededException {
      rethrow;
    } on AuthException catch (e) {
      AppLogger.error('Failed to signUp', e);
      return Left(AuthFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to signUp: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to signUp', e, stackTrace);
      return Left(AuthFailure('Registration failed. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      return const Right(null);
    } on AuthException catch (e) {
      AppLogger.error('Failed to signOut', e);
      return Left(AuthFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to signOut: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to signOut', e, stackTrace);
      return Left(AuthFailure('Sign out failed. Please try again.'));
    }
  }

  @override
  User? get currentUser => remoteDataSource.currentUser;
}
