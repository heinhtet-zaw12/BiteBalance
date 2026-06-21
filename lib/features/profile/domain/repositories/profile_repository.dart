import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/features/profile/domain/entities/profile.dart';

abstract class ProfileRepository {
  Future<Either<Failure, Profile>> getProfile(String userId);
  Future<Either<Failure, Profile>> saveProfile(Profile profile);
}
