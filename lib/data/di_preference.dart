import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = AsyncNotifierProvider<SharedPreferencesNotifier, SharedPreferences>(() {
  return SharedPreferencesNotifier();
});

class SharedPreferencesNotifier extends AsyncNotifier<SharedPreferences> {
  @override
  Future<SharedPreferences> build() async {
    return await SharedPreferences.getInstance();
  }
}