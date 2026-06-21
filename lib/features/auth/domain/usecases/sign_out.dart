import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/auth/domain/repositories/auth_repository.dart';

class SignOut implements UseCase<void, NoParams> {
  final AuthRepository repository;

  const SignOut(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) {
    return repository.signOut();
  }
}
