import 'package:flutter_riverpod/legacy.dart' show StateProvider;

final sessionInvalidationProvider = StateProvider<int>((ref) {
  return 0;
});
