import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart' show StateNotifierProvider;
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_confg_provider.dart';
import '../../../core/network/dio.provider.dart';
import '../../../core/network/session_invalidation_provider.dart';
import '../../../core/storage/secure_storage_provider.dart';
import '../data/auth_api.dart';
import '../data/auth_repository.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

final googleSignInProvider = Provider<GoogleSignIn>((ref) {
  return GoogleSignIn.instance;
});

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final api = ref.watch(authApiProvider);
  return AuthRepository(api);
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final config = ref.watch(appConfigProvider);

  final controller = AuthController(
    repository: ref.watch(authRepositoryProvider),
    storage: ref.watch(secureStorageProvider),
    googleSignIn: ref.watch(googleSignInProvider),
    googleServerClientId: config.googleServerClientId,
  );

  ref.listen<int>(sessionInvalidationProvider, (previous, next) {
    if (previous != next) {
      controller.handleSessionExpired();
    }
  });

  return controller;
});
