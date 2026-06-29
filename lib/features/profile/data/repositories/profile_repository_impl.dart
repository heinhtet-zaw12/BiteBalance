import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
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
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to getProfile', e);
      return Left(ServerFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to getProfile: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to getProfile', e, stackTrace);
      return Left(ServerFailure('Unable to load profile. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, Profile>> saveProfile(Profile profile) async {
    try {
      final profileModel = ProfileModel.fromEntity(profile);
      final savedProfile = await remoteDataSource.saveProfile(profileModel);
      return Right(savedProfile);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to saveProfile', e);
      return Left(ServerFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to saveProfile: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to saveProfile', e, stackTrace);
      return Left(ServerFailure('Unable to save profile. Please try again.'));
    }
  }
}
