import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:bite_balance/core/utils/error_handler.dart';
import 'package:bite_balance/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_balance/features/food_log/data/datasources/food_log_remote_datasource.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_client.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_datasource.dart';
import 'package:bite_balance/features/food_log/data/datasources/gemini_vision_datasource.dart';
import 'package:bite_balance/features/food_log/data/repositories/food_log_repository_impl.dart';
import 'package:bite_balance/features/food_log/domain/entities/food_log.dart';
import 'package:bite_balance/features/food_log/domain/repositories/food_log_repository.dart';
import 'package:bite_balance/features/food_log/domain/usecases/analyze_food.dart';
import 'package:bite_balance/features/food_log/domain/usecases/analyze_food_image.dart';
import 'package:bite_balance/features/food_log/domain/usecases/get_daily_logs.dart';
import 'package:bite_balance/features/food_log/domain/usecases/log_food.dart';

// Data source providers
final foodLogRemoteDataSourceProvider = Provider<FoodLogRemoteDataSource>((ref) {
  return FoodLogRemoteDataSourceImpl(Supabase.instance.client);
});

final geminiClientProvider = Provider<GeminiClient>((ref) {
  return GeminiClient([
    dotenv.get('GEMINI_API_KEY_1'),
    dotenv.get('GEMINI_API_KEY_2'),
    dotenv.get('GEMINI_API_KEY_3'),
  ]);
});

final geminiDataSourceProvider = Provider<GeminiDataSource>((ref) {
  return GeminiDataSourceImpl(ref.read(geminiClientProvider));
});

final geminiVisionDataSourceProvider = Provider<GeminiVisionDataSource>((ref) {
  return GeminiVisionDataSourceImpl(ref.read(geminiClientProvider));
});

// Repository provider
final foodLogRepositoryProvider = Provider<FoodLogRepository>((ref) {
  return FoodLogRepositoryImpl(ref.read(foodLogRemoteDataSourceProvider));
});

// Use case providers
final logFoodProvider = Provider<LogFood>((ref) {
  return LogFood(ref.read(foodLogRepositoryProvider));
});

final getDailyLogsProvider = Provider<GetDailyLogs>((ref) {
  return GetDailyLogs(ref.read(foodLogRepositoryProvider));
});

final analyzeFoodProvider = Provider<AnalyzeFood>((ref) {
  return AnalyzeFood(ref.read(geminiDataSourceProvider));
});

final analyzeFoodImageProvider = Provider<AnalyzeFoodImage>((ref) {
  return AnalyzeFoodImage(ref.read(geminiVisionDataSourceProvider));
});

// Food log state
class FoodLogState {
  final FoodAnalysisResult? analysis;
  final bool isAnalyzing;
  final bool isSaving;
  final String? error;

  const FoodLogState({
    this.analysis,
    this.isAnalyzing = false,
    this.isSaving = false,
    this.error,
  });

  FoodLogState copyWith({
    FoodAnalysisResult? analysis,
    bool? isAnalyzing,
    bool? isSaving,
    String? error,
  }) {
    return FoodLogState(
      analysis: analysis ?? this.analysis,
      isAnalyzing: isAnalyzing ?? this.isAnalyzing,
      isSaving: isSaving ?? this.isSaving,
      error: error,
    );
  }
}

// Food log notifier
class FoodLogNotifier extends Notifier<FoodLogState> {
  @override
  FoodLogState build() => const FoodLogState();

  Future<void> analyzeFood(String foodDescription) async {
    state = state.copyWith(isAnalyzing: true, error: null, analysis: null);

    final result = await ref.read(analyzeFoodProvider)(
      AnalyzeFoodParams(foodDescription: foodDescription),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isAnalyzing: false,
        error: ErrorHandler.message(failure),
      ),
      (analysis) => state = state.copyWith(
        isAnalyzing: false,
        analysis: analysis,
      ),
    );
  }

  Future<void> analyzeFoodImage(File imageFile) async {
    state = state.copyWith(isAnalyzing: true, error: null, analysis: null);

    final result = await ref.read(analyzeFoodImageProvider)(
      AnalyzeFoodImageParams(imageFile: imageFile),
    );

    result.fold(
      (failure) => state = state.copyWith(
        isAnalyzing: false,
        error: ErrorHandler.message(failure),
      ),
      (analysis) => state = state.copyWith(
        isAnalyzing: false,
        analysis: analysis,
      ),
    );
  }

  Future<bool> saveFoodLog(String mealType) async {
    final analysis = state.analysis;
    if (analysis == null) return false;

    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return false;

    state = state.copyWith(isSaving: true, error: null);

    final foodLog = FoodLog(
      id: '',
      userId: user.id,
      foodName: analysis.foodName,
      calories: analysis.calories,
      isJunk: analysis.isJunk,
      mealType: mealType,
      createdAt: DateTime.now(),
    );

    final result = await ref.read(logFoodProvider)(
      LogFoodParams(foodLog: foodLog),
    );

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          error: ErrorHandler.message(failure),
        );
        return false;
      },
      (_) {
        state = const FoodLogState();
        return true;
      },
    );
  }

  void reset() {
    state = const FoodLogState();
  }
}

final foodLogProvider =
    NotifierProvider<FoodLogNotifier, FoodLogState>(FoodLogNotifier.new);

// Daily logs provider
class DailyLogsNotifier extends AsyncNotifier<List<FoodLog>> {
  @override
  Future<List<FoodLog>> build() async {
    return [];
  }

  Future<void> loadLogs(DateTime date) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getDailyLogsProvider)(
        GetDailyLogsParams(userId: user.id, date: date),
      );
      return result.fold(
        (failure) => throw failure,
        (logs) => logs,
      );
    });
  }
}

final dailyLogsProvider =
    AsyncNotifierProvider<DailyLogsNotifier, List<FoodLog>>(
        DailyLogsNotifier.new);
