import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/core/errors/failures.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/features/food_log/data/datasources/food_log_remote_datasource.dart';
import 'package:bite_balance/features/food_log/data/models/food_log_model.dart';
import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';
import 'package:bite_balance/features/food_log/domain/repositories/food_log_repository.dart';

class FoodLogRepositoryImpl implements FoodLogRepository {
  final FoodLogRemoteDataSource remoteDataSource;

  FoodLogRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, FoodLog>> logFood(FoodLog foodLog) async {
    try {
      final model = FoodLogModel.fromEntity(foodLog);
      final result = await remoteDataSource.logFood(model);
      return Right(result);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to logFood', e);
      return Left(ServerFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to logFood: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to logFood', e, stackTrace);
      return Left(ServerFailure('Unable to save food log. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, List<FoodLog>>> getDailyLogs(
      String userId, DateTime date) async {
    try {
      final logs = await remoteDataSource.getDailyLogs(userId, date);
      return Right(logs);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to getDailyLogs', e);
      return Left(ServerFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to getDailyLogs: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to getDailyLogs', e, stackTrace);
      return Left(ServerFailure('Unable to load food logs. Please try again.'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFoodLog(
      String userId, String id) async {
    try {
      await remoteDataSource.deleteFoodLog(userId, id);
      return const Right(null);
    } on PostgrestException catch (e) {
      AppLogger.error('Failed to deleteFoodLog', e);
      return Left(ServerFailure(e.message));
    } on SocketException catch (e, stackTrace) {
      AppLogger.error('Failed to deleteFoodLog: no internet', e, stackTrace);
      return const Left(
        NetworkFailure('Please check your internet connection and try again.'),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Failed to deleteFoodLog', e, stackTrace);
      return Left(ServerFailure('Unable to delete food log. Please try again.'));
    }
  }
}
