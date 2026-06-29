import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:bite_balance/core/utils/app_logger.dart';
import 'package:bite_balance/features/profile/data/models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> getProfile(String userId);
  Future<ProfileModel> saveProfile(ProfileModel profile);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final SupabaseClient client;

  ProfileRemoteDataSourceImpl(this.client);

  @override
  Future<ProfileModel> getProfile(String userId) async {
    try {
      final response = await client
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();

      if (response == null) {
        throw Exception('Profile not found');
      }

      return ProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error('Supabase error: getProfile', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<ProfileModel> saveProfile(ProfileModel profile) async {
    try {
      final response = await client
          .from('profiles')
          .upsert(profile.toJson())
          .select()
          .single();

      return ProfileModel.fromJson(response);
    } catch (e, stackTrace) {
      AppLogger.error('Supabase error: saveProfile', e, stackTrace);
      rethrow;
    }
  }
}
