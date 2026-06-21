import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/profile/domain/entities/profile.dart';
import 'package:bite_balance/features/profile/domain/repositories/profile_repository.dart';

class GetProfile implements UseCase<Profile, GetProfileParams> {
  final ProfileRepository repository;

  const GetProfile(this.repository);

  @override
  Future<Either<Failure, Profile>> call(GetProfileParams params) {
    return repository.getProfile(params.userId);
  }
}

class GetProfileParams {
  final String userId;

  const GetProfileParams({required this.userId});
}
