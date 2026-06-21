import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:bite_balance/features/profile/data/models/profile_model.dart';
import 'package:bite_balance/features/profile/domain/entities/profile.dart';
import 'package:bite_balance/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, Profile>> getProfile(String userId) async {
    try {
      final profile = await remoteDataSource.getProfile(userId);
      return Right(profile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Profile>> saveProfile(Profile profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final savedProfile = await remoteDataSource.saveProfile(profileModel);
      return Right(savedProfile);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
