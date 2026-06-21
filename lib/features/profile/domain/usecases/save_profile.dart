import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/usecases/usecase.dart';
import 'package:bite_balance/features/profile/domain/entities/profile.dart';
import 'package:bite_balance/features/profile/domain/repositories/profile_repository.dart';

class SaveProfile implements UseCase<Profile, SaveProfileParams> {
  final ProfileRepository repository;

  const SaveProfile(this.repository);

  @override
  Future<Either<Failure, Profile>> call(SaveProfileParams params) {
    return repository.saveProfile(params.profile);
  }
}

class SaveProfileParams {
  final Profile profile;

  const SaveProfileParams({required this.profile});
}
