import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import 'package:bite_balance/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bite_balance/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bite_balance/features/auth/domain/entities/user.dart';
import 'package:bite_balance/features/auth/domain/repositories/auth_repository.dart';
import 'package:bite_balance/features/auth/domain/usecases/sign_in.dart';
import 'package:bite_balance/features/auth/domain/usecases/sign_up.dart';
import 'package:bite_balance/features/auth/domain/usecases/sign_out.dart';
import 'package:bite_balance/core/usecases/usecase.dart';

// Data source provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(Supabase.instance.client);
});

// Repository provider
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.read(authRemoteDataSourceProvider));
});

// Use case providers
final signInProvider = Provider<SignIn>((ref) {
  return SignIn(ref.read(authRepositoryProvider));
});

final signUpProvider = Provider<SignUp>((ref) {
  return SignUp(ref.read(authRepositoryProvider));
});

final signOutProvider = Provider<SignOut>((ref) {
  return SignOut(ref.read(authRepositoryProvider));
});

// Auth state notifier
class AuthNotifier extends AsyncNotifier<User?> {
  @override
  Future<User?> build() async {
    return ref.read(authRepositoryProvider).currentUser;
  }

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(signInProvider)(
        SignInParams(email: email, password: password),
      );
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }

  Future<void> signUp(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(signUpProvider)(
        SignUpParams(email: email, password: password),
      );
      return result.fold(
        (failure) => throw failure,
        (user) => user,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await ref.read(signOutProvider)(const NoParams());
      return result.fold(
        (failure) => throw failure,
        (_) => null,
      );
    });
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);

/// Listenable that notifies GoRouter when auth state changes.
/// GoRouter uses this to re-evaluate its redirect function.
final authRefreshProvider = Provider<AuthRefreshNotifier>((ref) {
  final notifier = AuthRefreshNotifier();

  // 1. Handle already-restored session (Supabase.initialize runs before
  //    runApp, so currentSession is set before this provider is created,
  //    but onAuthStateChange only emits *future* events — the restore
  //    event already fired and was missed).
  if (Supabase.instance.client.auth.currentSession != null) {
    // Schedule a microtask so the router is fully built before the
    // notification triggers a redirect re-evaluation.
    Future.microtask(() => notifier.notifyListeners());
  }

  // 2. React to future auth events (login, logout, token refresh).
  final sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
    if (event.event == AuthChangeEvent.signedOut) {
      notifier.notifyListeners();
    } else if (event.event == AuthChangeEvent.signedIn ||
        event.event == AuthChangeEvent.tokenRefreshed) {
      notifier.notifyListeners();
    }
  });

  // 3. When authProvider finishes loading (resolves persisted session),
  //    notify GoRouter so the redirect uses the real auth state instead
  //    of AsyncLoading (which returns null → would redirect to /login).
  ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
    if (previous?.isLoading == true && !next.isLoading) {
      notifier.notifyListeners();
    }
  });

  ref.onDispose(() => sub.cancel());
  return notifier;
});

/// A ChangeNotifier that GoRouter listens to for redirect re-evaluation.
class AuthRefreshNotifier extends ChangeNotifier {
  @override
  void notifyListeners() {
    super.notifyListeners();
  }
}
