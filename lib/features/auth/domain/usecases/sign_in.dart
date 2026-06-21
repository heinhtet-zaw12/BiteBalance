import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/auth/domain/entities/user.dart';
import 'package:bite_balance/features/auth/domain/repositories/auth_repository.dart';

class SignIn implements UseCase<User, SignInParams> {
  final AuthRepository repository;

  const SignIn(this.repository);

  @override
  Future<Either<Failure, User>> call(SignInParams params) {
    return repository.signIn(
      email: params.email,
      password: params.password,
    );
  }
}

class SignInParams {
  final String email;
  final String password;

  const SignInParams({
    required this.email,
    required this.password,
  });
}
