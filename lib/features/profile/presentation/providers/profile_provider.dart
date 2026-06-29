import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:bite_balance/features/auth/presentation/providers/auth_provider.dart';
import 'package:bite_balance/features/profile/data/datasources/profile_remote_datasource.dart';

import 'package:bite_balance/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:bite_balance/features/profile/domain/entities/profile.dart';
import 'package:bite_balance/features/profile/domain/entities/calorie_recommendation.dart';
import 'package:bite_balance/features/profile/domain/repositories/profile_repository.dart';
import 'package:bite_balance/features/profile/domain/usecases/calculate_bmi.dart';
import 'package:bite_balance/features/profile/domain/usecases/get_calorie_recommendation.dart';
import 'package:bite_balance/features/profile/domain/usecases/get_profile.dart';
import 'package:bite_balance/features/profile/domain/usecases/save_profile.dart';

// Data source provider
final profileRemoteDataSourceProvider = Provider<ProfileRemoteDataSource>((ref) {
  return ProfileRemoteDataSourceImpl(Supabase.instance.client);
});

// Repository provider
final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(ref.read(profileRemoteDataSourceProvider));
});

// Use case providers
final getProfileProvider = Provider<GetProfile>((ref) {
  return GetProfile(ref.read(profileRepositoryProvider));
});

final saveProfileProvider = Provider<SaveProfile>((ref) {
  return SaveProfile(ref.read(profileRepositoryProvider));
});

final calculateBmiProvider = Provider<CalculateBmi>((ref) {
  return const CalculateBmi();
});

// Profile state notifier
class ProfileNotifier extends AsyncNotifier<Profile?> {
  @override
  Future<Profile?> build() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return null;

    final result = await ref.read(getProfileProvider)(
      GetProfileParams(userId: user.id),
    );

    return result.fold(
      (failure) => null,
      (profile) => profile,
    );
  }

  Future<void> loadProfile() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getProfileProvider)(
        GetProfileParams(userId: user.id),
      );
      return result.fold(
        (failure) => throw failure,
        (profile) => profile,
      );
    });
  }

  Future<void> saveProfile({
    required String fullName,
    required double weight,
    required double height,
    required String goal,
  }) async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final profile = Profile(
        id: user.id,
        fullName: fullName,
        weight: weight,
        height: height,
        goal: goal,
      );

      final result = await ref.read(saveProfileProvider)(
        SaveProfileParams(profile: profile),
      );

      return result.fold(
        (failure) => throw failure,
        (profile) => profile,
      );
    });
  }
}

final profileProvider = AsyncNotifierProvider<ProfileNotifier, Profile?>(
  ProfileNotifier.new,
);

// Get calorie recommendation use case provider
final getCalorieRecommendationProvider = Provider<GetCalorieRecommendation>((ref) {
  return const GetCalorieRecommendation();
});

// Calorie recommendation state notifier
class CalorieRecommendationNotifier extends AsyncNotifier<CalorieRecommendation?> {
  @override
  Future<CalorieRecommendation?> build() async {
    return null;
  }

  Future<void> loadRecommendation({
    required double weightKg,
    required double heightCm,
    required String goal,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(getCalorieRecommendationProvider)(
        GetCalorieRecommendationParams(
          weightKg: weightKg,
          heightCm: heightCm,
          goal: goal,
        ),
      );
      return result.fold(
        (failure) => throw failure,
        (recommendation) => recommendation,
      );
    });
  }
}

final calorieRecommendationProvider =
    AsyncNotifierProvider<CalorieRecommendationNotifier, CalorieRecommendation?>(
        CalorieRecommendationNotifier.new);
