import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wedding/data/di_preference.dart';
import 'package:wedding/data/repository/greeting_repository.dart';
import 'package:wedding/data/repository/member_repository.dart';
import 'package:wedding/data/repository/quiz_repository.dart';

final memberRepositoryProvider = Provider<MemberRepository>((ref) {
  final prefsValue = ref.watch(sharedPreferencesProvider);
  return prefsValue.when(
    data: (prefs) => MemberRepository(prefs),
    loading: () => throw UnimplementedError("SharedPreferences not initialized"),
    error: (err, stack) => throw Exception("Failed to initialize SharedPreferences"),
  );
});

final greetingRepositoryProvider = Provider<GreetingRepository>((ref) {
  final prefsValue = ref.watch(sharedPreferencesProvider);
  return prefsValue.when(
    data: (prefs) => GreetingRepository(prefs),
    loading: () => throw UnimplementedError("SharedPreferences not initialized"),
    error: (err, stack) => throw Exception("Failed to initialize SharedPreferences"),
  );
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  final prefsValue = ref.watch(sharedPreferencesProvider);
  return prefsValue.when(
    data: (prefs) => QuizRepository(prefs),
    loading: () => throw UnimplementedError("SharedPreferences not initialized"),
    error: (err, stack) => throw Exception("Failed to initialize SharedPreferences"),
  );
});
