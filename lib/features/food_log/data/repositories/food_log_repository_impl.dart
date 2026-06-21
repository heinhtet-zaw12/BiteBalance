import 'package:fpdart/fpdart.dart';
import 'package:bite_balance/core/errors/failures.dart';
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
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FoodLog>>> getDailyLogs(
      String userId, DateTime date) async {
    try {
      final logs = await remoteDataSource.getDailyLogs(userId, date);
      return Right(logs);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteFoodLog(
      String userId, String id) async {
    try {
      await remoteDataSource.deleteFoodLog(userId, id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
