import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<Failure, User>> signUp({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  User? get currentUser;
}
