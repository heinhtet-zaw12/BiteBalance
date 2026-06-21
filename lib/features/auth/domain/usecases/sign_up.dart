import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/auth/domain/entities/user.dart';
import 'package:bite_balance/features/auth/domain/repositories/auth_repository.dart';

class SignUp implements UseCase<User, SignUpParams> {
  final AuthRepository repository;

  const SignUp(this.repository);

  @override
  Future<Either<Failure, User>> call(SignUpParams params) {
    return repository.signUp(
      email: params.email,
      password: params.password,
    );
  }
}

class SignUpParams {
  final String email;
  final String password;

  const SignUpParams({
    required this.email,
    required this.password,
  });
}
