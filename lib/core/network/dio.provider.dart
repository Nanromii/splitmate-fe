import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:splitmate/core/config/app_confg_provider.dart';

import '../storage/secure_storage_provider.dart';
import 'dio_client.dart';
import 'session_invalidation_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(appConfigProvider);
  final storage = ref.watch(secureStorageProvider);
  final invalidation = ref.read(sessionInvalidationProvider.notifier);

  return DioClient.create(
    config,
    storage: storage,
    onSessionExpired: () {
      invalidation.update((value) => value + 1);
    },
  );
});
